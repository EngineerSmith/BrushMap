local grid = {}
grid.__index = grid

local lg = love.graphics

grid.new = function(tileW, tileH)
    return setmetatable({
        tileW = tileW, tileH = tileH
    }, grid)
end

grid.setTileSize = function(self, w, h)
    self.tileW, self.tileH = w, h
end

grid.draw = function(self, x, y, w, h, scale)
    str = ""
    lg.setLineWidth(2)
    -- X Line
    lg.setColor(0,1,0)
    lg.line(0, y, w, y)
    -- Y Line
    lg.setColor(1,0,0)
    lg.line(x, 0, x, h)
    -- Dashed Lines
    lg.setLineWidth(math.min(0.8 / (scale * 1.5)), 0.4)
    lg.setColor(.6,.6,.6)
    
    local scaledW = self.tileW * scale
    local scaledH = self.tileH * scale
    
    local offsetX = x % scaledW
    local offsetY = y % scaledH
    
    for i=-scaledW + offsetX, w, scaledW do
        lg.line(i, -y, i, h)
    end
    
    for i=-scaledH + offsetY, h, scaledH do
        lg.line(-x, i, w, i)
    end
    
    lg.setLineWidth(1)
end

return grid