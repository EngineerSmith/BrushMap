local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local image = require("ui.image")
local text = require("ui.text")
local numericInput = require("ui.numericInput")
local button = require("ui.button")

local maxNum = 9999

return function(font, controller)
local tabStatic = tabWindow.new("Static", font)

tabStatic.updateLimits = function(self, maxW, maxH)
    self.w:updateValue(nil,nil, maxW)
    self.h:updateValue(nil,nil, maxH)
end

tabStatic.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,-2, 20,0)
    self.preview = image.new(anchor)
    self.preview:setBackgroundColor({0,0,0})
    self:addChild(self.preview)
    
    local rect = self.preview.anchor.rect
    local height = rect[2] + rect[4]
    
    local anchor = anchor.new("NorthWest", 10,20+height, 20,40)
    local textX = text.new(anchor, "X", font)
    local anchor = anchor.new("NorthWest", 30,10+height, -1,40, 40,0)
    self.x = numericInput.new(anchor, 0, maxNum, 0, font)
    self.x:setValueChangedCallback(controller.staticXCallback)
    self:addChild(textX)
    self:addChild(self.x)
    
    local anchor = anchor.new("NorthWest", 10,70+height, 20,40)
    local textY = text.new(anchor, "Y", font)
    local anchor = anchor.new("NorthWest", 30,60+height, -1,40, 40,0)
    self.y = numericInput.new(anchor, 0, maxNum, 0, font)
    self.y:setValueChangedCallback(controller.staticYCallback)
    self:addChild(textY)
    self:addChild(self.y)
    
    local anchor = anchor.new("NorthWest", 8,122+height, 20,40)
    local textW = text.new(anchor, "W", font)
    local anchor = anchor.new("NorthWest", 30,110+height, -1,40, 40,0)
    self.w = numericInput.new(anchor, 4, maxNum, 4, font)
    self.w:setValueChangedCallback(controller.staticWCallback)
    self:addChild(textW)
    self:addChild(self.w)
    
    
    local anchor = anchor.new("NorthWest", 10,168+height, 20,40)
    local textH = text.new(anchor, "H", font)
    local anchor = anchor.new("NorthWest", 30,160+height, -1,40, 40,0)
    self.h = numericInput.new(anchor, 4, maxNum, 4, font)
    self.h:setValueChangedCallback(controller.staticHCallback)
    self:addChild(textH)
    self:addChild(self.h)
    
    local anchor = anchor.new("NorthWest", 10,220+height, -1,40, 20,0)
    self.create = button.new(anchor, nil, controller.staticCreateButton)
    self.create:setText("Add Tile", nil, font)
    self:addChild(self.create)
    
    local anchor = anchor.new("NorthWest", 10,270+height, -1,40, 20,0)
    self.delete = button.new(anchor, nil, controller.staticDeleteButton)
    self.delete:setText("Delete Tile", nil, font)
    self:addChild(self.delete)
    self.delete.enabled = false
end

return tabStatic 
end