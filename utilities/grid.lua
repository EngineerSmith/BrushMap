local grid = {}
grid.__index = grid

local lg = love.graphics
local min, max, mod, modf = math.min, math.max, math.mod, math.modf

local dashedLine = require("utilities.dashedLine")

local function inbetween(low, high, value)
    return min(high, max(low, value))
end

grid.new = function()
    local self = setmetatable({
        x,y = 4,4,
        color = {.8,.8,.8}
    }, grid)
    
    self.stencilFunc = function()
        lg.rectangle("fill", 0,0, self.width, self.height)
    end
    
    return self
end

grid.setTileSize = function(self, x, y)
    self.sizeX, self.sizeY = x, y
end

grid.setTileOffset = function(self, x, y)
    self.offsetX, self.offsetY = x, y
end

grid.setInnerOffset = function(self, x , y)
    self.innerX, self.innerY = x, y
end

grid.setDimensions = function(self, width, height)
    self.width, self.height = width, height
end

grid.setColor = function(self, r,g,b)
    self.color[1], self.color[2], self.color[3] = r, g, b
end

grid.positionToTile = function(self, x, y)
    local rX, rY
    local rW, rH = self.sizeX, self.sizeY
    
    local strideX = self.sizeX + self.innerX
    local strideY = self.sizeY + self.innerY
    
    local startX = mod(self.offsetX, strideX)
    local startY = mod(self.offsetY, strideY)
    
    if self.innerX == 0 then
        x = x - startX
        if x < 0 then
            x = x - strideX
        end
        local idX = modf(x / strideX)
        rX = idX * strideX + startX
        if rX < 0 then
            rW = strideX - startX
            rX = rX - rW + strideX
        end
    else
        --TODO
    end
    if self.innerY == 0 then
        y = y - startY
        if y < 0 then
            y = y - strideY
        end
        local idY = modf(y / strideY)
        rY = idY * strideY + startY
        if rY < 0 then
            rH = strideY - startY
            rY = rY - rH + strideY
        end
    else
        --TODO
    end
    
    return rX, rY, rW, rH
end

grid.draw = function(self, scale)
    local dash  = inbetween(2.1, 5, 5 / scale)
    local space = inbetween(2.1, 5, 5 / scale)
    
    local w, h = self.width, self.height
    
    local strideX = self.sizeX + self.innerX
    local strideY = self.sizeY + self.innerY
    
    local startX = mod(self.offsetX, strideX)
    local startY = mod(self.offsetY, strideY)
    
    lg.setLineWidth(min(scale, 0.2))
    lg.setColor(self.color)
    
    for x = startX, w, strideX do
        if x >= 0 then
            dashedLine(x, 0, x, h, dash, space)
        end
    end
    if self.innerX ~= 0 then
        for x = startX - self.innerX, w, strideX do
            if x >= 0 then
                dashedLine(x, 0, x, h, dash, space)
            end
        end
    end
    
    for y = startY, h, strideY do
        if y >= 0 then
            dashedLine(0, y, w, y, dash, space)
        end
    end
    if self.innerY ~= 0 then
        for y = startY - self.innerY, h, strideY do
            if y >= 0 then
                dashedLine(0, y, w, y, dash, space)
            end
        end
    end
    
    lg.setLineWidth(1)
end

return grid