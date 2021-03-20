local global = require("global")

local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local imageAnimation = require("ui.imageAnimation")
local frameSelect = require("ui.frameSelect")
local text = require("ui.text")
local numericInput = require("ui.numericInput")
local button = require("ui.button")

return function(font, controller)
local tabAnimation = tabWindow.new("Animation", font)

tabAnimation.reset = function(self)
    self.preview:reset()
    self.frameSelect:reset()
    self.time:reset()
    self.deleteFrame:setActive(false)
    self.create:setActive(false)
    self.delete:setActive(false)
end

tabAnimation.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,-2, 20,0)
    self.preview = imageAnimation.new(anchor)
    self.preview:setBackgroundColor({0,0,0})
    self:addChild(self.preview)
    
    local x,y,w,h = self.preview.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, w,w/3, 20,0)
    self.frameSelect = frameSelect.new(anchor, global.assets["font.robotoReg25"], global.assets["icon.plus"])
    self.frameSelect.indexedChangedCallback = controller.animationIndexedChanged
    self:addChild(self.frameSelect)
    
    local x,y,w,h = self.frameSelect.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, -1,20, 20,0)
    local titleTime = text.new(anchor, "Time (Seconds)", font)
    local anchor = anchor.new("NorthWest", 10, 40+height, -1,40, 20,0)
    self.time = numericInput.new(anchor, 0.05, 3000, 0.2, font, 0.05)
    self.time:setValueChangedCallback(controller.animationTimeChanged)
    self:addChild(titleTime)
    self:addChild(self.time)
    
    local anchor = anchor.new("NorthWest", 10,100+height, -1,40, 20,0)
    self.deleteFrame = button.new(anchor, nil, controller.animationDeleteFrameButton)
    self.deleteFrame:setText("Delete Frame", nil, font)
    self:addChild(self.deleteFrame)
    self.deleteFrame:setActive(false)
    
    local anchor = anchor.new("NorthWest", 10,150+height, -1,40, 20,0)
    self.create = button.new(anchor, nil, controller.animationCreateButton)
    self.create:setText("Create Tile", nil, font)
    self:addChild(self.create)
    self.create:setActive(false)
    
    local anchor = anchor.new("NorthWest", 10,200+height, -1,40, 20,0)
    self.delete = button.new(anchor, nil, controller.animationDeleteButton)
    self.delete:setText("Delete Title", nil, font)
    self:addChild(self.delete)
    self.delete:setActive(false)
end

return tabAnimation
end