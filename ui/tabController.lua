local ui = require("ui.base.ui")
local tabController = setmetatable({}, ui)
tabController.__index = tabController

local anchor = require("ui.base.anchor")

tabController.new = function(windowWidth)
    local anchor = anchor.new("NorthEast", 30,0, 0,-1)
    local self = setmetatable(ui.new(anchor), tabController)
    
    self.windowWidth = windowWidth or 100
    self.active = false
    
    return self
end

tabController.getAnchorUpdate = function(self)
    if self.parent then
        self.parent:getAnchorUpdate()
    else
        local _,_, width, height = love.window.getSafeArea()
        self:updateAnchor(width, height)
    end
    self:updateTabLocations()
end

local padding = 10
local maxHeight = 150

tabController.updateTabLocations = function(self)
    local x,y,w,h = self.anchor:getRect()
    
    local height = h / self.children.count
    if height + (padding * self.children.count) > maxHeight then
        height = maxHeight
    end
    
    y = y + padding
    for i, child in ipairs(self.children) do
        child:setTitleRect(x,y,30,height)
        y = y + padding + height
    end
end

tabController.setActive = function(self, value, child)
    if value then
        if self.activeChild ~= child then
            for _, c in ipairs(self.children) do
                if c ~= child then c.active = false end
            end
            self.activeChild = child
        end
    end
    
    if self.active ~= value then
        self.active = value
        
        local dir = self.active and 1 or -1
        
        self.anchor.x = self.anchor.x + self.windowWidth * dir
        
        self:getAnchorUpdate()
    end
end

return tabController