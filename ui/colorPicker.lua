local ui = require("ui.base.ui")
local colorPicker = setmetatable({}, ui)
colorPicker.__index = colorPicker

local anchor = require("ui.base.anchor")

local shape = require("ui.shape")
local slider = require("ui.slider")

colorPicker.new = function()
    local anchor = anchor.new("NorthWest", 0,0, -1,-1)
    local self = setmetatable(ui.new(anchor), colorPicker)
    
    local anchor = anchor.new("Center", 0,-50, {min=20,max=200},{min=20,max=200})
    self.previewShape = shape.new(anchor, "Rectangle", nil, "fill", 3)
    
    self:addChild(self.previewShape)
    
    local anchor = anchor.new("Center", 0, 100, 200, 30)
    self.redSlider = slider.new(anchor, 255, 0, {0.5,0.1,0.1})
    local anchor = anchor.new("Center", 0, 150, 200, 30)
    self.greenSlider = slider.new(anchor, 255, 0, {0.1,0.5,0.1})
    local anchor = anchor.new("Center", 0, 200, 200, 30)
    self.blueSlider = slider.new(anchor, 255, 0, {0.1,0.1,0.5})
    
    self:addChild(self.redSlider)
    self:addChild(self.greenSlider)
    self:addChild(self.blueSlider)
    
    self.callback = function(_, value)
        local r = self.redSlider.ratio
        local g = self.greenSlider.ratio
        local b = self.blueSlider.ratio
        self.previewShape:setColor(r,g,b)
    end
    
    self.redSlider.valueChangedCallback = self.callback
    self.greenSlider.valueChangedCallback = self.callback
    self.blueSlider.valueChangedCallback = self.callback
    
    return self
end

return colorPicker