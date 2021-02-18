local button = {}
button.__index = button

local lg = love.graphics
local nilFunc = function() end

--TODO STATES?

button.new = function(anchor, callback)
    local self = setmetatable({}, button)
    
    self.anchor = anchor
    self.callback = callback or nilFunc
    
    return self
end

button.addText = function(self, text, font)
   --TODO add font
   self.text = text
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
    lg.setColor(1,0,0) --TODO draw options
    lg.rectangle("fill", self.anchor:getRect())
    lg.setColor(1,1,1)
    local x, y = self.anchor:getRect()
    lg.print(self.text, x, y) --TODO better text allignment
end

return button