local ui = require("ui.base.ui")
local colorPicker = setmetatable({}, ui)
colorPicker.__index = colorPicker

local anchor = require("ui.base.anchor")

local shape = require("ui.shape")
local slider = require("ui.slider")

colorPicker.new = function()
    local anchor = anchor.new("NorthWest", 0,0, -1,-1)
    local self = setmetatable(ui.new(anchor), colorPicker)
    
    local anchor = anchor.new("Center", 0,-100, {min=20,max=200},{min=20,max=200})
    self.previewShape = shape.new(anchor, "Rectangle", nil, "fill", 3)
    
    self:addChild(self.previewShape)
    
    local achor = anchor.new("Center", -50, 50, 100, 30)
    self.redSlider = slider.new(anchor, 255, 0, {0.5,0.1,0.1})
    local anchor = anchor.new("Center", -50, 90, 100, 30)
    self.greenSlider = slider.new(anchor, 255, 0, {0.1,0.5,0.1})
    local anchor = anchor.new("Center", -50, 130, 100, 30)
    self.blueSlider = slider.new(anchor, 255, 0, {0.1,0.1,0.5})
    
    self:addChild(self.redSlider)
    self:addChild(self.greenSlider)
    self:addChild(self.blueSlider)
    
    self.redSlider.valueChangedCallback = self.callback
    self.greenSlider.valueChangedCallback = self.callback
    self.blue.valueChangedCallback = self.callback
    
    return self
end

colorPicker.callback = function(self, value)
    local r = self.redSlider.ratio
    local g = self.greenSlider.ratio
    local b = self.blueSlider.ratio
    self.previewShape:setColor(r,g,b)
end

return colorPicker