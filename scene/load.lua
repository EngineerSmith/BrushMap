local scene = {}

local lg = love.graphics

scene.draw = function()
    lg.setColor(0.4,0.8,0.6,1)
    lg.rectangle("fill", 60, 60, 200, 200)
end

return scene