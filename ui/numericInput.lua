local ui = require("ui.base.ui")
local numericInput = setmetatable({}, ui)
numericInput.__index = numericInput

local lg = love.graphics

local insert, remove = table.insert, table.remove
local floor = math.floor
local aabb = require("utilities.aabb")

local buttonWidth = 40
local halfButtonWidth = floor(buttonWidth/2)

numericInput.new = function(anchor, min, max, baseValue, font, increment)
    local self = setmetatable(ui.new(anchor), numericInput)
    
    self.value = baseValue or min
    self.basevalue = self.value
    self.min, self.max = min, max
    self.font = font or lg.getFont()
    self.increment = increment or 1
    self.active = true
    self.touches = {}
    return self
end

numericInput.reset = function(self)
    self.value = self.basevalue
end

numericInput.updateValue = function(self, value, min, max)
    self.value = value or self.value
    self.min = min or self.min
    self.max = max or self.max
    self:checkValue(self.value < self.min, self.min)
    self:checkValue(self.value > self.max, self.max)
end

numericInput.setValueChangedCallback = function(self, callback)
    self.valueChangedCallback = callback
    if self.valueChangedCallback then
        self:valueChangedCallback(self.value)
    end
end

numericInput.setClone = function(self, numericInput)
    if self.clone then
        self.clone.active = true
    end
    self.clone = numericInput
    if self.clone then
        self.clone.active = false
        self.clone.value = self.value
        if self.clone.valueChangedCallback then
            self.clone:valueChangedCallback(self.clone.value)
        end
    end
end

local updateTouch = function(touch)
    local lastX, lastY = touch.x, touch.y
    local dx,dy = 0,0
    for k, move in ipairs(touch.moved) do
        dx = dx + (move.x - lastX)
        dy = dy + (move.y - lastY)
        lastX, lastY = move.x, move.y
        touch.moved[k] = nil
    end
    touch.x = lastX
    touch.y = lastY
    return dx, dy
end

numericInput.updateElement = function(self, dt)
    for _, touch in ipairs(self.touches) do
        updateTouch(touch)
        local t = love.timer.getTime()
        local time = t - touch.time
        while time > 0.4 do
            local oldvalue = self.value
            local x,y,w,h = self.anchor:getRect()
            if touch.side == "-" and aabb(touch.x,touch.y, x,y,buttonWidth,h) then
                self.value = self.value - self.increment
                if not self:checkValue(self.value < self.min, self.min) then
                    self.value = oldvalue
                    break
                end
            elseif touch.side == "+" and aabb(touch.x,touch.y, x+w-buttonWidth,y,buttonWidth,h) then
                self.value = self.value + self.increment
                if not self:checkValue(self.value > self.max, self.max) then
                    self.value = oldvalue
                    break
                end
            end
            touch.time = touch.time + 0.1
            time = t - touch.time
        end
    end
end

numericInput.triangleUp =   {  0,-10, -10, 10, 10,10}
numericInput.triangleDown = {-10,-10,  10,-10,  0,10}

numericInput.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    
    lg.setColor(.4,.4,.4)
    lg.rectangle("fill", x,y,w,h)
    
    if self.active then
        lg.setColor(.5,.5,.5)
        lg.rectangle("fill", x,y, buttonWidth, h)
        lg.rectangle("fill", x+w-buttonWidth,y,buttonWidth,h)
        
        lg.push()
        lg.translate(x+halfButtonWidth,y+floor(h/2))
        if self.value == self.min then
            lg.setColor(.7,.7,.7)
        else
            lg.setColor(1,1,1)
        end
        lg.polygon("fill", numericInput.triangleDown)
        lg.translate(w-buttonWidth,0)
        if self.value == self.max then
            lg.setColor(.7,.7,.7)
        else
            lg.setColor(1,1,1)
        end
        lg.polygon("fill", numericInput.triangleUp)
        lg.pop()
    end
    
    local str = tostring(self.value)
    local width, height = self.font:getWidth(str), self.font:getHeight()
    lg.setColor(1,1,1)
    lg.print(str, self.font, x+floor(w/2)-floor(width/2),y+floor(h/2)-floor(height/2))
end

numericInput.checkValue = function(self, bool, value)
    local triggerCloneCallback = false
    if bool then
        self.value = value
    elseif self.valueChangedCallback then
        if not self:valueChangedCallback(self.value) then
            return false
        end
        triggerCloneCallback = true
    end
    if self.clone then
        self.clone.value = self.value
        if triggerCloneCallback and self.clone.valueChangedCallback then
            self.clone:valueChangedCallback(self.value)
        end
    end
    return true
end

local getTouch = function(touches, id)
    for k,v in ipairs(touches) do
        if v.id == id then return k,v end
    end
    return -1
end

numericInput.touchpressedElement = function(self, id, pressedX, pressedY, ...)
    local oldvalue = self.value
    if self.active then
        local x,y,w,h = self.anchor:getRect()
        if aabb(pressedX, pressedY, x,y,buttonWidth,h) then
            self.value = self.value - self.increment
            if not self:checkValue(self.value < self.min, self.min) then
                self.value = oldvalue
            end
            insert(self.touches, {id=id, x=pressedX, y=pressedY, side="-", moved={}, time=love.timer.getTime()})
            return true
        end
        if aabb(pressedX, pressedY, x+w-buttonWidth,y,buttonWidth,h) then
            self.value = self.value + self.increment
            if not self:checkValue(self.value > self.max, self.max) then
                self.value = oldvalue
            end
            insert(self.touches, {id=id, x=pressedX, y=pressedY, side="+", moved={}, time=love.timer.getTime()})
            return true
        end
    end
    return false
end

numericInput.touchmovedElement = function(self, id, x, y, ...)
    local key, touch = getTouch(self.touches, id)
    if key ~= -1 then
        insert(touch.moved, {x=x, y=y})
    end
end

numericInput.touchreleasedElement = function(self, id, ...)
    local key = getTouch(self.touches, id)
    if key ~= -1 then
        remove(self.touches, key)
    end
end

return numericInput