local tabWindow = require("ui.tabWindow")

local anchor = require("ui.base.anchor")
local button = require("ui.button")
local shape = require("ui.shape")

return function(font, controller, window)
local tabLayers = tabWindow.new("Layers", font, controller)

tabLayers.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,40, 20,0)
    local newLayer = button.new(anchor, nil, function()
    end)
    newLayer:setText("New Layer", nil, font)
    self:addChild(newLayer)
        
    local anchor = anchor.new("NorthWest", 10,80, -1,5, 20,0)
    self:addChild(shape.new(anchor, "Rectangle", {.4,.4,.4}, "fill"))
end

return tabLayers
end