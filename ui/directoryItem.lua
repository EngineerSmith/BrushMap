local ui = require("ui.base.ui")
local directoryItem = setmetatable({}, ui)
directoryItem.__index = directoryItem

local anchor = require("ui.base.anchor")

local shape = require("ui.shape")

local lg = love.graphics
local floor = math.floor
local aabb = require("utilities.aabb")
local nilFunc = function() end

directoryItem.new = function(icon, text, font, iconSize, callback)
    local anchor = anchor.new("NorthWest", 0,0, -1, iconSize)
    local self = setmetatable(ui.new(anchor), directoryItem)
    
    self.selected = false
    
    self.iconSize = iconSize or error("IconSize required")
    self:setIcon(icon)
    self.text = text or error("Text required")
    self.font = font or lg.getFont()
    self.callbackReleased = callback or nilFunc
    
    local anchor = anchor.new("Center", 0,0, -1,-1)
    
    self.background = shape.new(anchor, "Rectangle", {0.8,0.8,0.8,1}, "fill")
    
    self.background.enabled = false
    self:addChild(self.background)
    
    
    return self
end

directoryItem.setIcon = function(self, icon)
    self.icon = icon or error("Icon required")
    
    local width, height = icon:getWidth(), icon:getHeight()
    self.iconLength = width > height and height or width
    
    self.iconScale = self.iconSize / self.iconLength
end

directoryItem.setSelected = function(self, value)
    self.selected = value or false
    self.background.enabled = value or false
end


directoryItem.touchreleasedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    if aabb(pressedX, pressedY, self.anchor:getRect()) then
        self:setSelected(not self.selected)
        local result = self:callbackReleased(self.selected)
        return result ~= nil and result or true
    end
    return false
end

directoryItem.draw = function(self)
    self:drawChildren()
    self:drawElement()
end

directoryItem.drawElement = function(self)
    local x,y, width,height = self.anchor:getRect()
    
    local s = self.iconScale
    
    lg.setColor(1,1,1,1)
    lg.draw(self.icon, x,y, 0, s,s)
    local textMid = floor(self.iconSize/2) - floor(self.font:getHeight()/2)
    lg.print(self.text, self.font, x + self.iconSize + 2,y + textMid)
end

return directoryItem