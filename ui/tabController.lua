local ui = require("ui.base.ui")
local tabController = setmetatable({}, ui)
tabController.__index = tabController

local anchor = require("ui.base.anchor")

local tabTitleWidth = 40

tabController.new = function(windowWidth)
    local anchor = anchor.new("NorthEast", tabTitleWidth,0, 0,-1)
    local self = setmetatable(ui.new(anchor), tabController)
    
    self.windowWidth = windowWidth or 200
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
local maxHeight = 120

tabController.updateTabLocations = function(self)
    local x,y,w,h = self.anchor:getRect()
    
    local height = h / self.children.count
    if padding + height > maxHeight then
        height = maxHeight
    end
    
    y = y + padding
    for i, child in ipairs(self.children) do
        child:setTitleRect(x,y,tabTitleWidth,height)
        y = y + padding + height
    end
end

tabController.setActive = function(self, value, child)
    if value then
        for _, c in ipairs(self.children) do
            if c ~= child then 
                c.active = false
            end
        end
    end
    self.activeChild = child
    
    if self.active ~= value then
        self.active = value
        
        local dir = self.active and 1 or -1
        
        self.anchor.x = self.anchor.x + self.windowWidth * dir
        
        self:getAnchorUpdate()
    end
end

return tabController