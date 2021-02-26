local scene = {}

local editorWindow = require("scene.ui.tilesetEditor")

scene.update = function(dt)
    editorWindow:update(dt)
end

scene.draw = function()
    editorWindow:draw()
end

scene.touchpressed = function(id, x, y, dx, dy, pressure)
    editorWindow:touchpressed(id, x, y, dx, dy, pressure)
end

scene.touchmoved = function(id, x, y, dx, dy, pressure)
    editorWindow:touchmoved(id, x, y, dx, dy, pressure)
end

scene.touchreleased = function(id, x, y, dx, dy, pressure)
    editorWindow:touchreleased(id, x, y, dx, dy, pressure)
end


return scene