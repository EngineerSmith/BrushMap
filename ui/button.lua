local ui = require("ui.base.ui")
local button = setmetatable({}, {__index=ui})
button.__index = button

local anchor = require("ui.base.anchor")
local imageUi = require("ui.image")
local textUi = require("ui.text")

local lg = love.graphics
local floor = math.floor
local nilFunc = function() end

button.new = function(anchor, color, callback)
    local self = setmetatable(ui.new(anchor), button)
    
    self.color = color or {0.4,0.4,0.4}
    self.callback = callback or nilFunc
    self.rectCorner = 0
    
    return self
end

button.addText = function(self, text, color, font)
    if not self.text then
        local anchor = anchor.new("East", 0, 0, -1, -1)
        self.text = textUi.new(anchor, text, font, color)
        self:addChild(self.text)
    else
        self.text:updateText(text, font, color)
    end
end

button.addImage = function(self, image, color)
    if not self.image then
        local anchor = anchor.new("West", 0, 0, -1, -1)
        self.image = imageUi.new(anchor, image, color)
        self:addChild(self.image)
    else
        self.image:setImage(image, color)
    end
end

button.setOutline = function(self, enabled, distance, lineSize)
    self.lineEnabled = enabled or false
    self.lineDistance = distance or 2
    self.lineSize = lineSize or 1 --TODO add lineSize
end

button.setRoundCorner = function(self, round)
   self.rectCorner = round or 0 
end

button.touchpressedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    local x, y, w, h = self.anchor:getRect()
    if pressedX > x and pressedX < x + w and
       pressedY > y and pressedY < y + h then
        self.callback()
        return true
    end
    return false
end

button.drawElement = function(self)
    local x, y, width, height = self.anchor:getRect()
    
    lg.setColor(self.color)
    
    if self.lineEnabled then
        local line = self.lineDistance
        lg.setLineWidth(self.lineSize)
        lg.rectangle("line", x-line, y-line, width+line*2, height+line*2, self.rectCorner)
        lg.setLineWidth(1)
    end
    
    lg.rectangle("fill", x, y, width, height,self.rectCorner)
    
    lg.setColor(1,1,1)
end

return button