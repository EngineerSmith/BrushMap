local ui = require("ui.base.ui")
local checkbox = setmetatable({}, ui)
checkbox.__index = checkbox

local lg = love.graphics

local aabb = require("utilities.aabb")

checkbox.new = function(anchor, selected)
    local self = setmetatable(ui.new(anchor), checkbox)
    self.selected = selected or false
    return self
end

checkbox.setValueChangedCallback = function(self, callback)
    self.valueChangedCallback = callback
    if self.valueChangedCallback then
        self:valueChangedCallback(self.selected)
    end
end

checkbox.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    lg.setColor(.4,.4,.4)
    lg.rectangle("fill", x,y,w,h)
    lg.setColor(.3,.3,.3)
    lg.rectangle("fill",x+3,y+3,w-6,h-6)
    if self.selected then
        lg.setColor(.6,.6,.6)
        lg.rectangle("fill", x+6,y+6,w-12,h-12)
    end
end

checkbox.touchpressedElement = function(self, id, x,y)
    if aabb(x,y, self.anchor:getRect()) then
        self.selected = not self.selected
        if self.valueChangedCallback then
            self:valueChangedCallback(self.selected)
        end
        return true
    end
end

return checkbox