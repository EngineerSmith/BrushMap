local scene = {}
local lg = love.graphics

scene.background = require("background.circles")

local anchor = require("ui.anchor")
local anchorManager = require("ui.anchorManager")
local button = require("ui.button")

scene.load = function()
    scene.background.load(7)
    
    scene.anchorManager = anchorManager.new()
    
    local _, _, width, height = love.window.getSafeArea()
    
    --TODO brain storm and review how buttons and being made
    
    --Ui manager?
    --pass manager into constructor to let it add itself?
    
    local anchor = anchor.new("Center", -120, -20, 200, 100)
    scene.anchorManager:add(anchor, width, height)
    
    scene.buttonNew2D = button.new(anchor)
    scene.buttonNew2D:addText("New 2D Map")
    scene.buttonNew2D:setOutline(true, 2, 1)
    scene.buttonNew2D:setRoundCorner(7)
    
    local anchor = anchor.new("Center", 120, -20, 200, 100)
    scene.anchorManager:add(anchor, width, height)
    
    scene.buttonNew3D = button.new(anchor)
    scene.buttonNew3D:addText("New 3D Map")
    scene.buttonNew3D:setOutline(true, 2, 1)
    scene.buttonNew3D:setRoundCorner(7)
    
    local anchor = anchor.new("Center", 0, 120, 200, 100)
    scene.anchorManager:add(anchor, width, height)
    
    scene.buttonLoad = button.new(anchor)
    scene.buttonLoad:addText("Load Map")
    scene.buttonLoad:setOutline(true, 2, 1)
    scene.buttonLoad:setRoundCorner(7)
    
    local anchor = anchor.new("SouthWest", 15, 15, 100, 100)
    scene.anchorManager:add(anchor, width, height)
    
    scene.buttonLanguage = button.new(anchor)
    scene.buttonLanguage:addText("Language")
    scene.buttonLanguage:setOutline(true, 2, 1)
    scene.buttonLanguage:setRoundCorner(7)
    
    local anchor = anchor.new("SouthEast", 15, 15, 100, 100)
    scene.anchorManager:add(anchor, width, height)
    
    scene.buttonHelp = button.new(anchor)
    scene.buttonHelp:addText("Help")
    scene.buttonHelp:setOutline(true, 2, 1)
    scene.buttonHelp:setRoundCorner(7)
    
    local anchor = anchor.new("North", 0, 30, 500, 100)
    scene.anchorManager:add(anchor, width, height)
    
    scene.buttonTitle = button.new(anchor, {0.15,0.15,0.15})
    scene.buttonTitle:addText("BrushMap")
    
end

scene.update = function(dt) 
    scene.background.update(dt)
end

scene.draw = function()
    scene.background.draw()
    lg.setColor(1,1,1,1)
    lg.print("BrushMap 0.1", 5, 30)
    
    scene.buttonNew2D:draw()
    scene.buttonNew3D:draw()
    scene.buttonLoad:draw()
    scene.buttonLanguage:draw()
    scene.buttonHelp:draw()
    scene.buttonTitle:draw()
end

scene.resize = function(windowWidth, windowHeight)
    scene.background.resize(windowHeight, windowHeight)
    local _, _, width, height = love.window.getSafeArea()
    scene.anchorManager:resize(width, height) 
end

return scene