local scene = {}
local lg = love.graphics

scene.background = require("background.circles")

scene.load = function()
    scene.background.load(7)
end

scene.update = function(dt) 
    scene.background.update(dt)
end

scene.draw = function()
    scene.background.draw()
    lg.setColor(1,1,1,1)
    lg.print("BrushMap 0.1", 5, 30)
end

return scene