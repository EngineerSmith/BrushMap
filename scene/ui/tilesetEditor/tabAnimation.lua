local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local imageAnimation = require("ui.imageAnimation")

return function(font, controller)
local tabAnimation = tabWindow.new("Animation", font)

tabAnimation.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,-2, 20,0)
    self.preview = imageAnimation.new(anchor)
    self.preview:setBackgroundColor({0,0,0})
    self:addChild(self.preview)
    
    local rect = self.preview.anchor.rect
    local height = rect[2] + rect[4]
end

return tabAnimation
end