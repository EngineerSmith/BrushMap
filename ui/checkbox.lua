local ui = require("ui.base.ui")
local checkbox = setmetatable({}, ui)
checkbox.__index = checkbox

local lg = love.graphics

local aabb = require("utilities.aabb")

checkbox.new = function(anchor, selected)
    local self = setmetatable(ui.new(anchor), checkbox)
    self.selected = selected or false
    self.active = true
    self.owned = {}
    self.owner = nil
    return self
end

checkbox.setValueChangedCallback = function(self, callback)
    self.valueChangedCallback = callback
    if self.valueChangedCallback then
        self:valueChangedCallback(self.selected)
    end
end

checkbox.addOwnership = function(self, box)
    for _, own in ipairs(self.owned) do
        if own == box then
            return
        end
    end
    table.insert(self.owned, box)
    box.owner = self
end

checkbox.childChanged = function(self, child)
    self.selected = not child.selected
    for _, own in ipairs(self.owned) do
        if own ~= child then
            own.selected = not child.selected
        end
    end
end

checkbox.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    lg.setColor(.4,.4,.4)
    lg.rectangle("fill", x,y,w,h)
    lg.setColor(.3,.3,.3)
    lg.rectangle("fill",x+3,y+3,w-6,h-6)
    if self.selected then
        if self.active then
            lg.setColor(.6,.6,.6)
        else
            lg.setColor(.5,.5,.5)
        end
        lg.rectangle("fill", x+6,y+6,w-12,h-12)
    end
end

checkbox.touchpressedElement = function(self, id, x,y)
    if self.active and aabb(x,y, self.anchor:getRect()) then
        if self.owner then
            if not self.selected then
                self.selected = true
                self.owner:childChanged(self)
            end
        elseif #self.owned > 0 then
            if not self.selected then
                self.selected = true
                for _, own in ipairs(self.owned) do
                    own.selected = false
                end
            end
        else
            self.selected = not self.selected
        end
        if self.valueChangedCallback then
            self:valueChangedCallback(self.selected)
        end
        return true
    end
end

return checkbox