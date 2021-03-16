local tabWindow = require("ui.tabWindow")

return function(font, controller)
local tabAnimation = tabWindow.new("Bitmask", font)

tabAnimation.createUI = function(self)
    
end

return tabAnimation
end