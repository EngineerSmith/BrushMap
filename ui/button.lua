local button = {}
button.__index = button

local lg = love.graphics
local floor = math.floor
local nilFunc = function() end

--TODO STATES?

button.new = function(anchor, color, callback)
    local self = setmetatable({}, button)
    
    self.anchor = anchor
    self.color = color or {0.4,0.4,0.4}
    self.callback = callback or nilFunc
    self.rectCorner = 0
    
    return self
end

button.addText = function(self, text, color, font)
   --TODO come back to Text
   self.text = text
   self.textColor = color or {1,1,1}
   self.font = font
end

button.addImage = function(self, image, color)
    self.image = image
    self.imageColor = color or {1,1,1}
end

button.setOutline = function(self, enabled, distance, lineSize)
    self.lineEnabled = enabled or false
    self.lineDistance = distance or 2
    self.lineSize = lineSize or 1 --TODO add lineSize
end

button.setRoundCorner = function(self, round)
   self.rectCorner = round or 0 
end

button.pressed = function(self, pressedX, pressedY)
    local x, y, w, h = self.anchor:rect()
    if pressedX > x and pressedX < x + w and
       pressedY > y and pressedY < y + h then
        self.callback()
        return true
    end
    return false
end
    
button.draw = function(self)
    local x, y, width, height = self.anchor:getRect()
    
    lg.setColor(self.color)
    
    if self.lineEnabled then
        local line = self.lineDistance
        lg.setLineWidth(self.lineSize)
        lg.rectangle("line", x-line, y-line, width+line*2, height+line*2, self.rectCorner)
        lg.setLineWidth(1)
    end
    
    lg.rectangle("fill", x, y, width, height, self.rectCorner)
    
    if self.text then
        lg.setColor(self.textColor)
        lg.print(self.text, x, y) --TODO text allignment
    end
    
    if self.image then
        lg.setColor(self.imageColor)
        x, y = x + floor(self.image.getWidth()/2), y + floor(self.image.getWidth()/2)
        lg.draw(self.image, x, y)
    end
    
    lg.setColor(1,1,1)
end

return button