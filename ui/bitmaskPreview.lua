local ui = require("ui.base.ui")
local bitmaskPreview = setmetatable({}, ui)
bitmaskPreview.__index = bitmaskPreview

local lg = love.graphics
local insert = table.insert
local ceil, floor = math.ceil, math.floor

bitmaskPreview.tileBits = {
    128, 1, 16,
      8, 0,  2,
     64, 4, 32
}
-- Highest to lowest value
bitmaskPreview.tileOrder = {
    1, 7, 9, 3, 4, 8, 6, 2, 5
}

bitmaskPreview.new = function(anchor)
    local self = setmetatable(ui.new(anchor), bitmaskPreview)
    
    self.tileActive = {
        false, false, false,
        false, false, false,
        false, false, false,
    }
    
    self.evenDraw = false
    
    self.image = nil
    self.quads = {}
    self.id = -1
    self.currentTime = 0
    self.negative = false
    return self
end

bitmaskPreview.setBackgroundColor = function(self, color)
    self.backgroundColor = color
end

bitmaskPreview.setImage = function(self, image)
    self.image = image
end

bitmaskPreview.addQuad = function(self, quad, time)
    insert(self.quads, {quad = quad, time = time or -1})
    self.id = 1
    self.currentTime = 0
end

bitmaskPreview.drawEvenDirectionsOnly = function(self, bool)
    self.evenDraw = bool
end

bitmaskPreview.reset = function(self)
    for i=1, 9 do
        self.tileActive[i] = false
    end
    self:resetQuads()
end

bitmaskPreview.resetQuads = function(self)
    self.quads = {}
    self.id = -1
    self.currentTime = 0
end

bitmaskPreview.updateElement = function(self, dt)
    if self.active and self.id ~= -1 and self.quads[self.id].time ~= -1 then
        self.currentTime = self.currentTime + dt
        while self.currentTime > self.quads[self.id].time do
            self.currentTime = self.currentTime - self.quads[self.id].time
            self.id = self.id + 1
            if self.id > #self.quads then
                self.id = 1
            end
        end
    end
end

bitmaskPreview.drawElement = function(self)
    local rx, ry, w, h = self.anchor:getRect()
    if self.backgroundColor then
        lg.setColor(self.backgroundColor)
        lg.rectangle("fill", rx,ry, w,h)
    end
    if self.active then
        local lenW, lenH = w / 3, h / 3
        for i = 1, 9 do
            if i ~= 5 and (not self.evenDraw or i % 2 == 0)then
                if self.tileActive[i] then
                    local x, y =self:tileToPoint(i)
                    if i % 2 == 0 then
                        if self.negative then
                            lg.setColor(.5,.1,.2)
                        else
                            lg.setColor(.1,.5,.3)
                        end
                    else
                        if self.negative then
                            lg.setColor(.4,.1,.15)
                        else
                            lg.setColor(.1,.4,.25)
                        end
                    end
                    lg.rectangle("fill", rx+x, ry+y, lenW, lenH)
                end
            end
        end
        if self.id ~= -1 then
            local quad = self.quads[self.id].quad
            
            local _,_, tw,th = quad:getViewport()
            local quadLen = tw > th and tw or th
            local s = (lenW > lenH and lenW or lenH) / quadLen
            lg.setColor(1,1,1)
            local x = floor(lenW/2) - floor((tw*s)/2)
            local y = floor(lenH/2) - floor((th*s)/2)
            lg.draw(self.image, quad, rx+lenW+x, ry+lenH+y, 0, s, s)
        end
    end
end

bitmaskPreview.sumActiveTiles = function(self)
    local sum = 0
    for i=1, 9 do
        if self.tileActive[i] then
            sum = sum + self.tileBits[i]
        end
    end
    return sum
end

bitmaskPreview.setActiveTiles = function(self, sum)
    for _, key in ipairs(self.tileOrder) do
        if sum - self.tileBits[key] >= 0 then
            sum = sum - self.tileBits[key]
            self.tileActive[key] = true
        else
            self.tileActive[key] = false
        end
    end
    if self.valueChangedCallback then
        self:valueChangedCallback(self:sumActiveTiles())
    end
end

bitmaskPreview.tileToPoint = function(self, tile)
    local _,_, w, h = self.anchor:getRect()
    local y = ceil(tile / 3) - 1
    local x = tile - (3 * y) - 1
    local w, h = w / 3, h / 3
    return x * w, y * h
end

bitmaskPreview.pointToTile = function(self, x, y)
    local rx, ry, w, h = self.anchor:getRect()
    x, y = x - rx, y - ry
    if x < 0 or x > w or y < 0 or y > h then
        return -1
    end
    local lenW, lenH = w / 3, h / 3
    return (ceil(y / lenH) - 1) * 3 + ceil(x / lenW)
end

bitmaskPreview.touchpressedElement = function(self, id, x, y, ...)
    if self.active then
        local tile = self:pointToTile(x, y)
        if tile == -1 then
            return false
        end
        if not self.evenDraw or tile % 2 == 0 then
            self.tileActive[tile] = not self.tileActive[tile]
            if self.valueChangedCallback then
                self:valueChangedCallback(self:sumActiveTiles())
            end
        end
        return true
    end
end

return bitmaskPreview