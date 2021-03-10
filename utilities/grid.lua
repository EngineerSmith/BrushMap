local grid = {}
grid.__index = grid

local lg = love.graphics
local min, max = math.min, math.max

local dashedLine = require("utilities.dashedLine")

local function inbetween(low, high, value)
    return min(high, max(low, value))
end

grid.new = function()
    local self = setmetatable({
        x,y = 4,4,
        color = {.8,.8,.8}
    }, grid)
    
    return self
end

grid.setTileSize = function(self, x, y)
    self.sizeX, self.sizeY = x, y
end

grid.setTileOffset = function(self, x, y)
    self.offsetX, self.offsetY = x, y
end

grid.setDimensions = function(self, width, height)
    self.width, self.height = width, height
end

grid.setColor = function(self, r,g,b)
    self.color[1], self.color[2], self.color[3] = r, g, b
end

grid.positionToTile = function(self, x, y)
    local tx = x / self.sizeX
    local ty = y / self.sizeY 
    return tx, ty
end

grid.draw = function(self, scale)
    local dash  = inbetween(2.1, 5, 5 / scale)
    local space = inbetween(2.1, 5, 5 / scale)
    
    local w, h = self.width, self.height
    local x, y = self.sizeX, self.sizeY
    local ofX, ofY = self.offsetX, self.offsetY
    
    lg.setLineWidth(min(scale, 0.2))
    lg.setColor(self.color)
    for i=0, (w - ofX) / x do
        dashedLine(i * x + ofX, ofY, i * x + ofX, h, dash, space)
    end
    for i=0, (h - ofY) / y do
        dashedLine(ofX, i * y + ofY, w, i * y + ofY, dash, space)
    end
    lg.setLineWidth(1)
end

return grid