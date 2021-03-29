local scene = {}

local editorWindow = require("scene.ui.tilemapEditor")
local touchController = require("input.touch").new()
local grid = require("utilities.tilemapGrid").new(16, 16)

scene.update = function(dt)
    editorWindow:update(dt)
end

scene.update = function(dt)
    editorWindow:update(dt)
    
    touchController:update()
end

scene.draw = function() 
    local w,h = love.graphics.getDimensions()
    grid:draw(touchController.x, touchController.y, w, h, 1)
    
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