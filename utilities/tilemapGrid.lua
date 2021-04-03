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
    local dash = math.min(5, 5 / scale)
    local space = math.min(5 / scale)
    str = ""
    lg.setLineWidth(2)
    -- X Line
    lg.setColor(0,1,0)
    lg.line(0, y, w, y)
    -- Y Line
    lg.setColor(1,0,0)
    lg.line(x, 0, x, h)
    -- Dashed Lines
    lg.setLineWidth(0.8)
    lg.setColor(.6,.6,.6)
    
    local scaledW = self.tileW * scale
    local scaledH = self.tileH * scale
    
    local offsetX = x % scaledW
    local offsetY = y % scaledH
    
    for i=-scaledW + offsetX, w, scaledW do
        dashedLine(i, -y, i, h, dash, space)
    end
    
    for i=-scaledH + offsetY, h, scaledH do
        dashedLine(-x, i, w, i, dash, space)
    end
    
    lg.setLineWidth(1)
end

return grid