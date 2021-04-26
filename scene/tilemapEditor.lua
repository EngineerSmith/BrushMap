local scene = {}

local global = require("global")

local editorWindow = require("scene.ui.tilemapEditor")
local touchController = require("input.touch").new()
local grid = require("utilities.tilemapGrid").new(16, 16)

scene.load = function()
    local _,_, w,h = love.window.getSafeArea()
    touchController:setDimensions(w, h)
    touchController:setLimitScale(0.8, 2)
    
    editorWindow.controllerWest:setActive(false, "all")
end

scene.update = function(dt)
    global.editorSession:update(dt)
    
    editorWindow:update(dt)
    
    touchController:update()
end

scene.draw = function()
    local s = touchController.scale
    local x = touchController.x * s
    local y = touchController.y * s
    local w,h = love.graphics.getDimensions()
    
    global.editorSession.tilemap:draw(x, y)
    
    grid:draw(x, y, w, h, s)
    
    editorWindow:draw()
    
    local str = str or "" -- debug, global str
    love.graphics.print(str, 100,50)
end

scene.touchpressed = function(...)
    if editorWindow:touchpressed(...) then
        return end
    touchController:touchpressed(...)
end

scene.touchmoved = function(...)
    touchController:touchmoved(...)
    if editorWindow:touchmoved(...) then
        return end
end

scene.touchreleased = function(...)
    touchController:touchreleased(...)
    if editorWindow:touchreleased(...) then
        return end
end

return scene