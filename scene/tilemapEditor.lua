local scene = {}

local global = require("global")

local lg = love.graphics

local editorWindow = require("scene.ui.tilemapEditor")
local touchController = require("input.touch").new()
local grid = require("utilities.tilemapGrid").new(16, 16)

scene.load = function()
    local _,_, w,h = love.window.getSafeArea()
    touchController:setDimensions(w, h)
    touchController:setLimitScale(0.8, 2)
    touchController.y = h/2
    touchController.x = w/2
    
    editorWindow.controllerWest:setActive(false, "all")
end

scene.update = function(dt)
    global.editorSession:update(dt)
    
    editorWindow:update(dt)
    
    if editorWindow.selectedTool == "move" then
        touchController:update()
    end
end

scene.draw = function()
    local s = touchController.scale
    local x = touchController.x * s
    local y = touchController.y * s
    local w,h = love.graphics.getDimensions()
    
    global.editorSession.tilemap:draw(x, y, s)
    
    grid:draw(x, y, w, h, s)
    
    editorWindow:draw()
    
    lg.setColor(1,1,1)
    local str = str2 or "" -- debug, global str
    lg.print(str, 100,50)
end

scene.touchpressed = function(...)
    if editorWindow:touchpressed(...) then
        return end
    if editorWindow.selectedTool == "move" then
        touchController:touchpressed(...)
    end
    if editorWindow.selectedTool == "brush" then
        local l = global.editorSession.tilemap.activeLayer
        if l and editorWindow.selectedTile then
            l:setTile(0, 0, editorWindow.selectedTile)
        else
            str2 = "No tile selected!"
        end
    end
end

scene.touchmoved = function(...)
    if editorWindow.selectedTool == "move" then
        touchController:touchmoved(...)
    end
    if editorWindow:touchmoved(...) then
        return end
end

scene.touchreleased = function(...)
    if editorWindow.selectedTool == "move" then
        touchController:touchreleased(...)
    end
    if editorWindow:touchreleased(...) then
        return end
end

return scene