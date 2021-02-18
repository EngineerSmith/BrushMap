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
    
    self.point = anchor.points[point] or error("Anchor requires point")
    self.x = x or error("Anchor requires position X")
    self.y = y or error("Anchor requires position Y")
    self.horizontal = horizontal or 0 
    self.vertical = vertical or 0
    
    if type(width) == "number" then
       self.width = {min=width,max=width}
    else then
        self.width = type(width) == "table" and width or {}
        self.width.min = self.width.min or 0
        self.width.max = self.width.max or 0
    end
    
    if type(height) == "number" then
       self.height = {min=height,max=height}
    else then
        self.height = type(height) == "table" and height or {}
        self.height.min = self.height.min or 0
        self.height.max = self.height.max or 0
    end
    
    return self
end

anchor.length = function(side, padding, windowLength)
    if side.max + padding <= windowLength then
        return side.max
    elseif side.min + padding <= windowLength then
        return windowLength - padding
    else
        return side.min
    end
end

anchor.position = function(anchor, anchorWidth, anchorHeight, windowWidth, windowHeight)
    local centerX = floor(windowWidth / 2) - floor(anchorWidth / 2)
    local centreY = floor(windowHeight / 2) - floor(anchorHeight / 2)
    
    local x = anchor.x + anchor.horizontal
    local y = anchor.y + anchor.vertical
    
    if anchor.point == anchor.point.Center then
        return centerX + x, centerY + y
    elseif anchor.point == anchor.point.North then
        return centerX + x, y
    elseif anchor.point == anchor.point.NorthWest then
        return x, y
    elseif anchor.point == anchor.point.West then
        return x, centerY + y
    elseif anchor.point == anchor.point.SouthWest then
        return x, windowHeight - y
    elseif anchor.point == anchor.point.South then
        return centerX + x, windowHeight - y
    elseif anchor.point == anchor.point.SouthEast then
        return windowWidth - x, windowHeight - y
    elseif anchor.point == anchor.point.East then
        return windowWidth - x, centerY + y
    elseif anchor.point == anchor.point.NorthEast then
        return windowWidth - x, y
    end
    error("Unknown anchor point given")
end

anchor:rect = function(windowWidth, windowHeight)
   local width = anchor.length(self.width, self.horizontal, windowWidth)
   local height = anchor.length(self.height, self.vertical, windowHeight)
   
   local x, y = anchor.position(self, width, height, windowWidth, windowHeight)
   
   return x, y, width, height 
end

return anchor