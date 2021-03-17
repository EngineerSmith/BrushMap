local global = require("global")

local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local imageAnimation = require("ui.imageAnimation")
local buttonFrameSelect = require("ui.buttonFrameSelect")

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
end

return tabAnimation
end