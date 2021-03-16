local image = require("ui.image")
local imageAnimation = setmetatable({}, image)
imageAnimation.__index = imageAnimation

local lg = love.graphics
local insert, remove= table.insert, table.remove
local floor = math.floor

imageAnimation.new = function(anchor, picture, color)
    local self = setmetatable(image.new(anchor, picture, color), imageAnimation)
    self.quads = {}
    self.times = {}
    self.currentTime = 0
    self.id = -1
    return self
end

imageAnimation.addFrame = function(self, quad, time)
    insert(self.quads, quad)
    insert(self.times, time)
    self.id = 1
end

imageAnimation.removeFrame = function(self, position)
    remove(self.quads, position)
    remove(self.times, position)
    self.id = 1
end

imageAnimation.updateElement = function(self, dt)
    if self.id ~= -1 then
        self.currentTime = self.currentTime + dt
        while self.currentTime > self.times[self.id] do
            self.currentTime = self.currentTime - self.times[self.id]
            self.id = self.id + 1 
            if self.id > #self.times then
                self.id = 1
            end
        end
    end
end

imageAnimation.drawElement = function(self)
    local x, y, width, height = self.anchor:getRect()
    if self.backgroundColor then
        lg.setColor(self.backgroundColor)
        lg.rectangle("fill", x,y, width,height)
    end
    if self.id ~= -1 and self.image then
        local quad = self.quads[self.id]
        
        local _,_, w,h = quad:getViewport()
        self.imageLength = w > h and w or h
        
        local s = (width > height and width or height) / self.imageLength
        
        lg.setColor(self.color)
        local offsetX = floor(width/2) - floor((w*s)/2)
        local offsetY = floor(height/2) - floor((h*s)/2)
        lg.draw(self.image, quad, x + offsetX, y + offsetY, 0, s, s)
    end
end

return imageAnimation