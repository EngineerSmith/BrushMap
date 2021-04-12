local ui = require("ui.base.ui")
local tabController = setmetatable({}, ui)
tabController.__index = tabController

local anchor = require("ui.base.anchor")

local tabTitleWidth = 40

tabController.new = function(side, windowWidth)
    local anch
    if side == "West" then
        anch = anchor.new("NorthWest", 0,0, 0,-1)
    elseif side == "East" then
        anch = anchor.new("NorthEast", tabTitleWidth,0, 0,-1)
    else
        error("Unaccepted side for tabController: "..tostring(side))
    end
    local self = setmetatable(ui.new(anch), tabController)
    
    self.side = side
    self.windowWidth = windowWidth or 240
    self.active = false
    self.lock = false
    
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

tabController.getTabWindowAnchor = function(self)
    local width = self.windowWidth
    return anchor.new(self.anchor.pointStr, -width,0, width,-1)
end

tabController.setActive = function(self, value, child)
    if self.lock then
        return false
    end
    if value then
        for _, c in ipairs(self.children) do
            if c ~= child then
                c.active = false
            end
        end
        self.activeChild = child
    end
    
    if self.active ~= value then
        self.active = value
        
        local dir = self.active and 1 or -1
        if self.side == "West" then
            self.anchor.x = self.anchor.x + self.windowWidth * dir
        elseif self.side == "East" then
            self.anchor.x = self.anchor.x + (self.windowWidth - tabTitleWidth) * dir
        end
        
        self:getAnchorUpdate()
    end
    if not value and self.activeChild then
        self.activeChild.active = false
        self.activeChild = nil
        return false
    end
    return true
end

tabController.setLock = function(self, bool)
    self.lock = bool
end

return tabController