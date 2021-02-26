local scene = {}

local global = require("global")

local lg = love.graphics

scene.background = require("background.circles")

scene.menuWindow = require("scene.ui.menu") --[[require("scene.ui.fileDialog")
local callback = function(success, path)
    require("utilities.sceneManager").changeScene("scene.tilesetEditor")
end]]

scene.load = function()
    scene.background.load(7)
    --scene.menuWindow.dialog("load", callback)
end

scene.update = function(dt) 
    scene.background.update(dt)
    scene.menuWindow:update(dt)
end

scene.draw = function()
    scene.background.draw()
    lg.setColor(1,1,1,1)
    lg.print(global.info.name .. " " .. global.info.version, 5, 30)
    
    scene.menuWindow:draw()
end

scene.touchpressed = function(id, x, y, dx, dy, pressure)
    scene.menuWindow:touchpressed(id, x, y, dx, dy, pressure)
end

scene.touchmoved = function(id, x, y, dx, dy, pressure)
    scene.menuWindow:touchmoved(id, x, y, dx, dy, pressure)
end

scene.touchreleased = function(id, x, y, dx, dy, pressure)
    scene.menuWindow:touchreleased(id, x, y, dx, dy, pressure)
end

scene.resize = function(windowWidth, windowHeight)
    scene.background.resize(windowHeight, windowHeight)
    
    local _, _, width, height = love.window.getSafeArea()
    
    scene.menuWindow:updateAnchor(width, height)
end

return scene