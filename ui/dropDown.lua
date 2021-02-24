local ui = require("ui.base.ui")
local dropDown = setmetatable({}, ui)
dropDown.__index = dropDown

local anchor = require("ui.base.anchor")

local shape = require("ui.shape")

local lg = love.graphics
local insert, floor = table.insert, math.floor
local aabb = require("utilities.aabb")

dropDown.new = function(anchor, options, font, hintText, option)
    local self = setmetatable(ui.new(anchor), dropDown)
    
    self.options = options or {}
    self.font = font or lg.getFont()
    self:setHintText(hintText)
    
    self.active = false
    self.selected = -1
    
    self.dropDownHeight = self.font:getHeight() + 5
    
    if option then
        local _ = self:setSelected(option) or error("Option not found")  
    end
    
    local anchor = anchor.new("NorthWest", 0,0, -1,-1)
    self.background = shape.new(anchor, "Rectangle", {0.3,0.3,0.3,1}, "fill")
    
    local anchor = anchor.new("NorthWest", 0,0, -1,-1)
    self.selectbackground = shape.new(anchor, "Rectangle", {0.35,0.35,0.35,1}, "fill")
    self.selectbackground.enabled = false
    
    self:addChild(self.selectbackground)
    self:addChild(self.background)
    
    self:updateBackgroundShape()
    return self
end

dropDown.updateBackgroundShape = function(self)
    local height = self.background.anchor.rect[4]
    local fontHeight = self.font:getHeight() + 5
    
    local t = self.selectbackground.anchor.height
    
    t.max = height + (fontHeight * #self.options)
    t.min = t.max
    self.selectbackground:getAnchorUpdate()
end

dropDown.addOption = function(self, option)
    insert(self.options, option)
    self:updateBackgroundShape()
end

dropDown.setHintText = function(self, hintText)
    self.options[-1] = hintText or ""
end

dropDown.setSelected = function(self, option)
    local index = -1
    for i, v in ipairs(self.options) do
        if v == option then 
            index = i 
            break
        end
    end
    if index == -1 then
        return false
    end
    
    self.selected = index
    return true
end

dropDown.touchpressedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    if aabb(pressedX, pressedY, self.anchor:getRect()) then
        self.active = true    
        self.selectbackground.enabled = true
        if self.touchpressedCallback then 
            self:touchpressedCallback()
        end
        return true
    end
end

dropDown.touchreleasedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    if self.active then
        local x,y,w,h = self.anchor:getRect()
        y = y + h
        self.selected = -1
        for i, option in ipairs(self.options) do
            if aabb(pressedX, pressedY, x,y+self.dropDownHeight*(i-1),w,self.dropDownHeight) then
                self.selected = i
                break
            end
        end
        
        self.active = false
        self.selectbackground.enabled = false
        if self.touchreleasedCallback then 
            self:touchreleasedCallback()
        end
        return true
    end
    return false
end

dropDown.draw = function(self)
    self:drawChildren()
    self:drawElement()
end

dropDown.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    lg.setColor(1,1,1,1)
    local height = floor(h / 2) - floor(self.font:getHeight() / 2)
    local str = self.options[self.selected]
    if self.active then
        str = self.options[-1]
    end
    lg.print(self.options[self.selected], self.font, x + 10, y + height)
    
    y = y + h
    height = self.dropDownHeight
    
    if self.active then
        for i=0, #self.options-1 do
            lg.print(self.options[i+1], self.font, (x + 10), y + height * i)
        end
    end
end

return dropDown