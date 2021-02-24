local floor = math.floor

local anchor = {
    points = {
        Center = 0,
        North = 1,
        NorthWest = 2,
        West = 3,
        SouthWest = 4,
        South = 5,
        SouthEast = 6,
        East = 7,
        NorthEast = 8
    }
}

anchor.__index = anchor

anchor.new = function(point, x, y, width, height, horizontal, vertical)
    local self = setmetatable({}, anchor)
    
    if point == "Centre" then -- I keep writing it the British way
        error("Did you mean Center not Centre?")
    end
    
    self.point = anchor.points[point] or error("Anchor requires point")
    self.x = x or error("Anchor requires position X")
    self.y = y or error("Anchor requires position Y")
    self.horizontal = horizontal or 0 -- Padding
    self.vertical = vertical or 0
    
    if type(width) == "number" then
       self.width = {min=width,max=width}
    else
        self.width = type(width) == "table" and width or {}
        self.width.min = self.width.min or 0
        self.width.max = self.width.max or 0
    end
    
    if type(height) == "number" then
       self.height = {min=height,max=height}
    else
        self.height = type(height) == "table" and height or {}
        self.height.min = self.height.min or 0
        self.height.max = self.height.max or 0
    end
    
    self.rect = {}
    self:calculate(0,0,-1,-1) -- Initlize rect with max values
    
    return self
end

anchor.length = function(side, padding, windowLength)
    if side.max == -1 then
       return windowLength - padding
    end
    
    if windowLength == -1 then 
        return side.max
    end
    
    if side.max + padding <= windowLength then
        return side.max
    elseif side.min + padding <= windowLength then
        return windowLength - padding
    else
        return side.min
    end
end

anchor.position = function(self, anchorWidth, anchorHeight, windowWidth, windowHeight)
    local centerX = floor(windowWidth / 2) - floor(anchorWidth / 2)
    local centerY = floor(windowHeight / 2) - floor(anchorHeight / 2)
    
    --TODO design better point to add safe position
    -- local safeX, safeY = love.window.getSafeArea()
    
    local x = self.x --+ self.horizontal
    local y = self.y --+ self.vertical
    
    if self.point == anchor.points.Center then
        return centerX + x, centerY + y
    elseif self.point == anchor.points.North then
        return centerX + x, y
    elseif self.point == anchor.points.NorthWest then
        return x, y
    elseif self.point == anchor.points.West then
        return x, centerY + y
    elseif self.point == anchor.points.SouthWest then
        return x, windowHeight - y - anchorHeight
    elseif self.point == anchor.points.South then
        return centerX + x, windowHeight - y - anchorHeight
    elseif self.point == anchor.points.SouthEast then
        return windowWidth - x - anchorWidth, windowHeight - y - anchorHeight
    elseif self.point == anchor.points.East then
        return windowWidth - x - anchorWidth, centerY + y
    elseif self.point == anchor.points.NorthEast then
        return windowWidth - x - anchorWidth, y
    end
    error("Unknown anchor point given")
end

anchor.calculate = function(self, offsetX, offsetY, windowWidth, windowHeight)
    
    local width = anchor.length(self.width, self.horizontal, windowWidth)
    local height = anchor.length(self.height, self.vertical, windowHeight)
    
    local x, y = self:position(width, height, windowWidth, windowHeight)
    
    self.rect[1], self.rect[2], self.rect[3], self.rect[4] = x + offsetX, y + offsetY, width, height
    
    return self.rect[1], self.rect[2], self.rect[3], self.rect[4]
end

anchor.getRect = function(self)
   return self.rect[1], self.rect[2], self.rect[3], self.rect[4]
end

return anchor