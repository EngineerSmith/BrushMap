local scene = {}

local global = require("global")

local lg = love.graphics

scene.background = require("background.circles")

scene.uiwindow = require("scene.ui.menu")

scene.load = function()
    scene.background.load(7)
end

scene.update = function(dt) 
    scene.background.update(dt)
    scene.uiwindow:update(dt)
end

scene.draw = function()
    scene.background.draw()
    lg.setColor(1,1,1,1)
    lg.print(global.info.name .. " " .. global.info.version, 5, 30)
    
    scene.uiwindow:draw()
end

scene.touchpressed = function(id, x, y, dx, dy, pressure)
    scene.uiwindow:touchpressed(id, x, y, dx, dy, pressure)
end

scene.touchreleased = function(id, x, y, dx, dy, pressure)
    scene .uiwindow:touchreleased(id, x, y, dx, dy, pressure)
end

scene.resize = function(windowWidth, windowHeight)
    scene.background.resize(windowHeight, windowHeight)
    
    local _, _, width, height = love.window.getSafeArea()
    
    scene.uiwindow:updateAnchor(width, height)
end

return scene