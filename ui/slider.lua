local ui = require("ui.base.ui")
local slider = setmetatable({}, ui)
slider.__index = slider

local lg = love.graphics

local aabb = require("utilities.aabb")

slider.new = function(anchor, maxValue, startingValue, color)
    local self = setmetatable(ui.new(anchor), slider)
    
    self.maxValue = maxValue or error("Slider required maxValue")
    self.value = startingValue or 0
    self.color = color or {0.8,0.8,0.8}
    
    self.active = false
    
    self.ratio = self.value / self.maxValue
    self:limitRatio()
    
    return self
end

slider.setValue = function(self, value)
    self.value = value
    self.ratio = value / self.maxValue
    self:limitRatio()
    if self.valueChangedCallback then
        self:valueChangedCallback(self.value)
    end
end

slider.setRatio = function(self, value)
    self.ratio = value
    self:limitRatio()
    self.value = self.ratio * self.maxValue
    if self.valueChangedCallback then
        self:valueChangedCallback(self.value)
    end
end

slider.limitRatio = function(self)
    if self.ratio > 1 then
        self.ratio = 1
    end
    if self.ratio < 0 then
        self.ratio = 0
    end
end

slider.calculateValue = function(self, pressedX)
    local x,y,w,h = self.anchor:getRect()
    pressedX = pressedX - x
    local ratio = pressedX / w
    self.ratio = ratio
    self:limitRatio()
    self.value = self.maxValue * ratio
    if self.valueChangedCallback then
        self:valueChangedCallback(self.value)
    end
end

slider.touchpressedElement = function(self, id, x, y, dx, dy, pressure)
    if aabb(x, y, self.anchor:getRect()) then
        self.active = true
        self:calculateValue(x)
        return true
    end
    return false
end

slider.touchmovedElement = function(self, id, x, y, dx, dy, pressure)
    if self.active then
        self:calculateValue(x)
    end
end

slider.touchreleasedElement = function(self, ...)
    self.active = false
end

slider.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    
    lg.setColor(self.color)
    lg.setLineWidth(2)
    lg.rectangle("line", x,y,w,h)
    lg.rectangle("fill", x,y,w*self.ratio,h)
    lg.setLineWidth(1)
end

return slider