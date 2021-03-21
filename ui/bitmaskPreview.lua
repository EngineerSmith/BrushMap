local ui = require("ui.base.ui")
local bitmaskPreview = setmetatable({}, ui)
bitmaskPreview.__index = bitmaskPreview

local lg = love.graphics
local ceil = math.ceil

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
    
    return self
end

bitmaskPreview.setBackgroundColor = function(self, color)
    self.backgroundColor = color
end

bitmaskPreview.setImage = function(self, image)
    self.image = image
end

bitmaskPreview.drawEvenDirectionsOnly = function(self, bool)
    self.evenDraw = bool
end

bitmaskPreview.reset = function(self)
    for i=1, 9 do
        self.tileActive[i] = false
    end
end

bitmaskPreview.drawElement = function(self)
    local rx, ry, w, h = self.anchor:getRect()
    if self.backgroundColor then
        lg.setColor(self.backgroundColor)
        lg.rectangle("fill", rx,ry, w,h)
    end
    local lenW, lenH = w / 3, h / 3
    lg.setColor(.1,.5,.3)
    for i = 1, 9 do
        if i ~= 5 and (not self.evenDraw or i % 2 == 0)then
            if self.tileActive[i] then
                local x, y =self:tileToPoint(i)
                lg.rectangle("fill", rx+x, ry+y, lenW, lenH)
            end
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

return bitmaskPreview