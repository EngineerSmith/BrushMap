local controller = {}
controller.__index = controller

local insert, remove = table.insert, table.remove
local sqrt, min, max = math.sqrt, math.min, math.max

local function inbetween(low, high, value)
    return min(high, max(low, value))
end

controller.new = function()
    return setmetatable({
        x = 0, y = 0, scale = 1,
        width, height = 1,1,
        pressedDelay = 0.2,
        lastDist,
        prevWidth, prevHeight,
        touches = {}
    }, controller)
end

controller.reset = function(self)
    self.x = 0
    self.y = 0
    self.scale = 1
    self.prevWidth, self.prevHeight = self.width, self.height
end

controller.setPressedCallback = function(self, callback, pressedDelay)
    self.pressedCallback = callback or nil
    self.pressedDelay = pressedDelay or 0.2
end

controller.setDimensions = function(self, width, height)
    self.width, self.height = width, height
    self.prevWidth, self.prevHeight = width, height
end

controller.setLimitScale = function(self, low, high)
    self.scaleLimit = {
        low = low or 0.1,
        high = high or 2
    }
end

controller.getRect = function(self)
    return self.x, self.y, self.width / self.scale, self.height / self.scale
end

controller.touchToWorld = function(self, x, y)
    x = (x / self.scale) - self.x
    y = (y / self.scale) - self.y
    return x, y
end

controller.updateTouch = function(self, touch)
    local lastX, lastY = touch.x, touch.y
    local dx,dy = 0,0
    for k, move in ipairs(touch.moved) do
        dx = dx + (move.x - lastX) / self.scale
        dy = dy + (move.y - lastY) / self.scale
        lastX, lastY = move.x, move.y
        touch.moved[k] = nil
    end
    touch.x = lastX
    touch.y = lastY
    return dx, dy
end

local A, B = {}, {}

controller.update = function(self)
    if #self.touches == 1 then
        local dx, dy = self:updateTouch(self.touches[1])
        
        self.x = self.x + dx
        self.y = self.y + dy
    elseif #self.touches == 2 then
        if #self.touches[1].moved > 0 or #self.touches[2].moved > 0 then
            self:updateTouch(self.touches[1])
            self:updateTouch(self.touches[2])
            A.x, A.y = self.touches[1].x, self.touches[1].y
            B.x, B.y = self.touches[2].x, self.touches[2].y
            --Scale
            local dx,dy = B.x - A.x, B.y - A.y
            local dist = sqrt(dx*dx+dy*dy)
            
            self.scale = self.scale * (dist/self.lastDist)
            if self.scaleLimit then
                if self.scale > self.scaleLimit.high then
                    self.scale = self.scaleLimit.high
                elseif self.scale < self.scaleLimit.low then
                    self.scale = self.scaleLimit.low
                else
                    self.lastDist = dist
                end
            else
                self.lastDist = dist
            end
            --Translate
            A.x, A.y = A.x / self.scale, A.y / self.scale
            B.x, B.y = B.x / self.scale, B.y / self.scale
            
            local focalX = (A.x + B.x) / 2
            local focalY = (A.y + B.y) / 2
            local nextWidth = self.width * self.scale
            local nextHeight= self.height * self.scale
            
            self.x = self.x + (-focalX * ((nextWidth - self.prevWidth) / nextWidth))
            self.y = self.y + (-focalY * ((nextHeight - self.prevHeight) / nextHeight))
            
            self.prevWidth, self.prevHeight = nextWidth, nextHeight
        end
    end
end

controller.getTouch = function(self, id)
    for k,v in ipairs(self.touches) do
        if v.id == id then return k,v end
    end
    return -1
end

controller.touchpressed = function(self, id, x, y, dx, dy, pressure)
    insert(self.touches, {id=id, x=x, y=y, moved={}, time=love.timer.getTime()})
    if #self.touches == 2 then
        local dx, dy = self.touches[2].x - self.touches[1].x, self.touches[2].y - self.touches[1].y
        self.lastDist = sqrt(dx*dx+dy*dy)
    end
end

controller.touchmoved = function(self, id, x, y, dx, dy, pressure)
    local key, touch = self:getTouch(id)
    if key ~= -1 then
        insert(touch.moved, {x=x, y=y})
    end
end

controller.touchreleased = function(self, id, x, y, dx, dy, pressure)
    local key, touch = self:getTouch(id)
    if key ~= -1 then
        local time = love.timer.getTime() - touch.time
        if self.pressedCallback and time < self.pressedDelay then
            self.pressedCallback(x, y)
        end
        remove(self.touches, key)
    end
end

return controller