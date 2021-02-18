local background = {}
background.__index = background

local lg = love.graphics

background.load = function() end

background.update = function(dt) end

background.draw = function() 
    lg.print("NO BACKGROUND SET.", lg.getWidth()/2, lg.getHeight()/2)
end

background.resize = function(width, height) end

return background