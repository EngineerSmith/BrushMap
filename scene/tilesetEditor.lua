local scene = {}
local editorWindow = require("scene.ui.tilesetEditor")

local dashedLine = require("utilities.dashedLine")

scene.update = function(dt)
    editorWindow:update(dt)
end

scene.draw = function()
    if editorWindow.tileset then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(editorWindow.tileset)
    end
    
    local _,_, width, height = love.window.getSafeArea()
    
    if editorWindow.tileSizeX ~= 0 then
        local x = editorWindow.tilesizeX
        love.graphics.setColor(1,1,1,.6)
        for i=0, width / x do
            dashedLine(i*x,0, i*x,height, 3,2)
        end
    end
    
    if editorWindow.tileSizeY ~= 0 then
        local y = editorWindow.tilesizeY
        for i=0, height/y do
            love.graphics.setColor(1,1,1,.6)
            dashedLine(0,i*y, width,i*y, 3,2)
        end
    end
    love.graphics.setColor(1,1,1)
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