local grid = {}
grid.__index = grid

local lg = love.graphics

local dashedLine = require("utilities.dashedLine")

grid.new = function(tileW, tileH)
    return setmetatable({
        tileW = tileW, tileH = tileH
    }, grid)
end

grid.setTileSize = function(self, w, h)
    self.tileW, self.tileH = w, h
end

grid.draw = function(self, x, y, w, h, scale)
    local dash = 5
    local space = 5
    str = ""
    lg.setLineWidth(2)
    -- X Line
    lg.setColor(0,1,0)
    lg.line(0, y, w, y)
    -- Y Line
    lg.setColor(1,0,0)
    lg.line(x, 0, x, h)
    -- Dashed Lines
    lg.setLineWidth(1)
    
end

return grid