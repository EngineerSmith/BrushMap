local scene = {}
local lg = love.graphics

scene.background = require("background.circles")

local anchor = require("ui.anchor")
local anchorManager = require("ui.anchorManager")
local button = require("ui.button")

scene.load = function()
    scene.background.load(7)
    
    scene.anchorManager = anchorManager.new()
    
    local anchor = anchor.new("Center", 0, 0, 100, 100)
    scene.anchorManager:add(anchor, lg.getWidth(), lg.getHeight())
    
    scene.button = button.new(anchor)
    scene.button:addText("Hello World")
end

scene.update = function(dt) 
    scene.background.update(dt)
end

scene.draw = function()
    scene.background.draw()
    lg.setColor(1,1,1,1)
    lg.print("BrushMap 0.1", 5, 30)
    
    scene.button:draw()
end

scene.resize = function(windowWidth, windowHeight)
    scene.anchorManager:resize(windowWidth, windowHeight
        ) 
end

return scene