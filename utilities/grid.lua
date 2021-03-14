local grid = {}
grid.__index = grid

local lg = love.graphics
local min, mod, modf = math.min, math.mod, math.modf

local inbetween = require("utilities.inbetween")
local dashedLine = require("utilities.dashedLine")

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

grid.setPadding = function(self, x , y)
    self.paddingX, self.paddingY = x, y
end

grid.setDimensions = function(self, width, height)
    self.width, self.height = width, height
end

grid.setColor = function(self, r,g,b)
    self.color[1], self.color[2], self.color[3] = r, g, b
end

local getTitlePosition = function(pos, length, start, stride, fullLength)
    pos = pos - start
    if pos < 0 then
        pos = pos - stride
    end
    local int = modf(pos / stride)
    pos = int * stride + start
    if pos < 0 then
        length = start
        pos = pos + stride - start
    elseif pos + length > fullLength then
        length = stride - start
    end
    return pos, length
end

grid.positionToTile = function(self, x, y)
    local rX, rY = -1, -1
    local rW, rH = self.sizeX, self.sizeY
    
    local strideX = self.sizeX + self.paddingX
    local strideY = self.sizeY + self.paddingY
    
    local startX = mod(self.offsetX, strideX)
    local startY = mod(self.offsetY, strideY)
    
    if self.paddingX == 0 then
        rX, rW = getTitlePosition(x, rW, startX, strideX, self.width)
    else
        local rX1, rW1 = getTitlePosition(x, rW, startX, strideX, self.width)
        if x > rX1 and x < rX1 + self.sizeX then
            rX = rX1
            if rX == 0 then
                rW = rW1 - self.paddingY
            elseif rX + rW > self.width then
                rW = self.width - rX
            end
        else
            return -1, -1, rW, rH
        end
    end
    if self.paddingY == 0 then
        rY, rH = getTitlePosition(y, rH, startY, strideY, self.height)
    else
        local rY1, rH1 = getTitlePosition(y, rH, startY, strideY, self.height)
        if y > rY1 and y < rY1 + self.sizeY then
            rY = rY1
            if rY == 0 then
                rH = rH1 - self.paddingY
            elseif rY + rH > self.height then
                rH = self.height - rY
            end
        end
    end
    
    return rX, rY, rW, rH
end

grid.draw = function(self, scale)
    local dash  = inbetween(2.1, 5, 5 / scale)
    local space = inbetween(2.1, 5, 5 / scale)
    
    local w, h = self.width, self.height
    
    local strideX = self.sizeX + self.paddingX
    local strideY = self.sizeY + self.paddingY
    
    local startX = mod(self.offsetX, strideX)
    local startY = mod(self.offsetY, strideY)
    
    lg.setLineWidth(min(scale, 0.2))
    lg.setColor(self.color)
    
    for x = startX, w, strideX do
        if x >= 0 then
            dashedLine(x, 0, x, h, dash, space)
        end
    end
    if self.paddingX ~= 0 then
        for x = startX - self.paddingX, w, strideX do
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
    if self.paddingY ~= 0 then
        for y = startY - self.paddingY, h, strideY do
            if y >= 0 then
                dashedLine(0, y, w, y, dash, space)
            end
        end
    end
    
    lg.setLineWidth(1)
end

return grid