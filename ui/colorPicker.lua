local ui = require("ui.base.ui")
local colorPicker = setmetatable({}, ui)
colorPicker.__index = colorPicker

local lg = love.graphics

local anchor = require("ui.base.anchor")

local shape = require("ui.shape")
local slider = require("ui.slider")
local button = require("ui.button")
local image = require("ui.image")

local setPreset = function(colorPicker, button)
    local c = button.shape.color
    colorPicker.selectedButton = button
    colorPicker.redSlider:setRatio(c[1])
    colorPicker.greenSlider:setRatio(c[2])
    colorPicker.blueSlider:setRatio(c[3])
    
    colorPicker.bgImage.enabled = button == colorPicker.buttonPreset2
end

colorPicker.new = function(texture)
    local anchor = anchor.new("NorthWest", 0,0, -1,-1)
    local self = setmetatable(ui.new(anchor), colorPicker)
    
    local anchor = anchor.new("Center", 0,-100, {min=20,max=200},{min=20,max=200})
    self.previewShape = shape.new(anchor, "Rectangle", nil, "fill", 3)
    self.previewShape:setOutline(true, 0, 2, {1,1,1})
    
    self:addChild(self.previewShape)
    
    local anchor = anchor.new("Center", -75, 40, 50, 50)
    local buttonPreset1 = button.new(anchor, {0,0,0}, function(button) setPreset(self, button) end)
    buttonPreset1:setRoundCorner(3)
    buttonPreset1:setOutline(true, 0, 2, {1,1,1})
    self:addChild(buttonPreset1)
    local anchor = anchor.new("Center", 0, 40, 50, 50)
    local buttonPreset2 = button.new(anchor, {1,1,1}, function(button) setPreset(self, button) end)
    buttonPreset2:setRoundCorner(3)
    buttonPreset2:setOutline(true, 0, 2, {1,1,1})
    buttonPreset2:setImage(texture, buttonPreset2.shape.color, true)
    self:addChild(buttonPreset2)
    local anchor = anchor.new("Center", 75, 40, 50, 50)
    local buttonPreset3 = button.new(anchor, {1,1,1}, function(button) setPreset(self, button) end)
    buttonPreset3:setRoundCorner(3)
    buttonPreset3:setOutline(true, 0, 2, {1,1,1})
    self:addChild(buttonPreset3)
    
    self.buttonPreset2 = buttonPreset2
    
    local w, h = texture:getDimensions()
    local anchor = anchor.new("NorthWest", 0,0, -1,-1)
    self.bgImage = image.new(anchor, texture, buttonPreset2.shape.color, lg.newQuad(0,0, w*3,h*3, w,h))
    
    self.bgImage.enabled = false
    self.previewShape:addChild(self.bgImage)
    
    local anchor = anchor.new("Center", 0, 100, 200, 30)
    self.redSlider = slider.new(anchor, 255, 0, {0.5,0.1,0.1})
    local anchor = anchor.new("Center", 0, 150, 200, 30)
    self.greenSlider = slider.new(anchor, 255, 0, {0.1,0.5,0.1})
    local anchor = anchor.new("Center", 0, 200, 200, 30)
    self.blueSlider = slider.new(anchor, 255, 0, {0.1,0.1,0.5})
    
    self:addChild(self.redSlider)
    self:addChild(self.greenSlider)
    self:addChild(self.blueSlider)
    
    self.callback = function(slider)
        local bool = self.selectedButton == buttonPreset2
        if slider == self.redSlider then
            self.previewShape.color[1] = slider.ratio
            if bool then buttonPreset2.shape.color[1] = slider.ratio end
        elseif slider == self.greenSlider then
            self.previewShape.color[2] = slider.ratio
            if bool then buttonPreset2.shape.color[2] = slider.ratio end
        elseif slider == self.blueSlider then
            self.previewShape.color[3] = slider.ratio
            if bool then buttonPreset2.shape.color[3] = slider.ratio end
        end
    end
    
    self.callback() --INIT shape colour
    
    self.redSlider.valueChangedCallback = self.callback
    self.greenSlider.valueChangedCallback = self.callback
    self.blueSlider.valueChangedCallback = self.callback
    
    return self
end

colorPicker.getColor = function(self)
    return self.redSlider.ratio, self.greenSlider.ratio, self.blueSlider.ratio
end

return colorPicker