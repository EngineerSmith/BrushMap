local tabWindow = require("ui.tabWindow")

local anchor = require("ui.base.anchor")
local button = require("ui.button")
local shape = require("ui.shape")
local scrollView = require("ui.scrollView")
local layerPreview = require("ui.layerPreview")

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
    
    local anchor = anchor.new("NorthWest", 0, 100, -1,-1, 0,100)
    local sv = scrollView.new(anchor, 0, 240*0.75+15)
    sv.activeShape = false
    self:addChild(sv)
    local width = 240
    
    local layerTest = layerPreview.new(nil, width)
    sv:addChild(layerTest)
    local layerTest = layerPreview.new(nil, width)
    sv:addChild(layerTest)
    local layerTest = layerPreview.new(nil, width)
    sv:addChild(layerTest)
    local layerTest = layerPreview.new(nil, width)
    sv:addChild(layerTest)
end

return tabLayers
end