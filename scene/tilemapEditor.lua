local scene = {}

local editorWindow = require("scene.ui.tilemapEditor")
local touchController = require("input.touch").new()

scene.update = function(dt)
    editorWindow:update(dt)
end

scene.draw = function() 
    editorWindow:draw()
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