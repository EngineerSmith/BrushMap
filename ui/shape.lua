local ui = require("ui.base.ui")
local shape = setmetatable({}, ui)
shape.__index = shape

local lg = love.graphics

shape.types = {
    ["Rectangle"] = 1,
    ["Circle"] = 1,
    ["Eclipse"] = 1,
}

shape.drawModes = {
    ["fill"] = 1,
    ["line"] = 1,
}

shape.new = function(anchor, shapeType, color, drawMode, ...)
    local self = setmetatable(ui.new(anchor), shape)
    self.type = shape.types[shapeType] and shapeType or error("Shape must be a supported type. "..tostring(shapeType))
    self.color = color or {1,1,1}
    self.mode = shape.drawModes[drawMode] and drawMode or error("Drawmode must be a supported type. "..tostring(drawMode)) 
    
    local shapeData = {...}
    
    if self.type == "Rectangle" then
        self.rx = shapeData[1]
        self.ry = shapeData[2]
        self.segments = shapeData[3]
    elseif self.type == "Circle" or self.type == "Eclipse" then
        self.segments = shapeData[1]
    end
    
    self.stencilFunc = function()
        local x, y, width, height = self.anchor:getRect()
        if self.type == "Rectangle" then
            if self.lineEnabled then
                local line = self.lineDistance
                lg.setLineWidth(self.lineSize+.1)
                lg.rectangle("line", x-line, y-line, width+line*2, height+line*2, self.rx, self.ry, self.segments)
                lg.setLineWidth(1)
            end
            lg.rectangle(self.mode, x, y, width, height, self.rx, self.ry, self.segments)
        elseif self.type == "Circle" or self.type == "Eclipse" then
            if self.lineEnabled then
                local line = self.lineDistance
                lg.setLineWidth(self.lineSize+.1)
                lg.eclipse("line", x-line, y-line, width+line*2, height+line*2, self.segments)
                lg.setLineWidth(1)
            end
            lg.eclipse(self.mode, x, y, width, height, self.segments)
        end
    end
    
    self.stencil = false
    
    return self
end

shape.setOutline = function(self, enabled, distance, lineSize, color)
    self.lineEnabled = enabled or false
    self.lineDistance = distance or 2
    self.lineSize = lineSize or 1
    self.lineColor = color or self.color
end

shape.setRoundCorner = function(self, rx, ry)
   self.rx = rx or 0 
   self.ry = ry or nil
end

shape.setSegments = function(self, segments)
    self.segments = segments
end

shape.setColor = function(self, r, g, b, a)
    self.color[1] = r or self.color[1]
    self.color[2] = g or self.color[2]
    self.color[3] = b or self.color[3]
    self.color[4] = a or self.color[4]
end

shape.enableStencil = function(bool)
    shape.stencil = bool
end

shape.draw = function(self)
    if self.enabled then
        self:drawElement()
        if self.stencil then
            lg.stencil(self.stencilFunc, ",replace", "1")
            lg.setStencilTest("greater", "0")
        end
        self:drawChildren()
        if self.stencil then
            lg.setStencilTest()
        end
    end
end

shape.drawElement = function(self)
    local x, y, width, height = self.anchor:getRect()
    
    if self.type == "Rectangle" then
        if self.lineEnabled then
            local line = self.lineDistance
            lg.setLineWidth(self.lineSize)
            lg.setColor(self.lineColor)
            lg.rectangle("line", x-line, y-line, width+line*2, height+line*2, self.rx, self.ry, self.segments)
            lg.setLineWidth(1)
        end
        
        lg.setColor(self.color)
        lg.rectangle(self.mode, x, y, width, height, self.rx, self.ry, self.segments)
    elseif self.type == "Circle" or self.type == "Eclipse" then
        if self.lineEnabled then
            local line = self.lineDistance
            lg.setLineWidth(self.lineSize)
            lg.setColor(self.lineColor)
            lg.eclipse("line", x-line, y-line, width+line*2, height+line*2, self.segments)
            lg.setLineWidth(1)
        end
        
        lg.setColor(self.color)
        lg.eclipse(self.mode, x, y, width, height, self.segments)
    end
end

return shape