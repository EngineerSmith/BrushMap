local global = require("global")

local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local imageAnimation = require("ui.imageAnimation")
local buttonFrameSelect = require("ui.buttonFrameSelect")
local text = require("ui.text")
local numericInput = require("ui.numericInput")

return function(font, controller)
local tabAnimation = tabWindow.new("Animation", font)

tabAnimation.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,-2, 20,0)
    self.preview = imageAnimation.new(anchor)
    self.preview:setBackgroundColor({0,0,0})
    self:addChild(self.preview)
    
    local x,y,w,h = self.preview.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, w,w/3, 20,0)
    self.frameSelect = buttonFrameSelect.new(anchor, global.assets["font.robotoReg25"], global.assets["icon.plus"])
    self:addChild(self.frameSelect)
    
    local x,y,w,h = self.frameSelect.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, -1,20, 20,0)
    local titleTime = text.new(anchor, "Time (Seconds)", font)
    local anchor = anchor.new("NorthWest", 10, 40+height, -1,40, 20,0)
    self.time = numericInput.new(anchor, 0.05, 3000, 0.2, font, 0.05)
    self:addChild(titleTime)
    self:addChild(self.time)
    
end

return tabAnimation
end