local checkbox = require("ui.checkbox")
local togglebox = setmetatable({}, checkbox)
togglebox.__index = togglebox

local lg = love.graphics

togglebox.new = function(anchor, selected)
    local self = setmetatable(checkbox.new(anchor, selected), togglebox)
    
    return self
end

togglebox.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    local r = h/2
    lg.setColor(.4,.4,.4)
    lg.circle("fill", x+r, y+r, r)
    lg.rectangle("fill", x+r,y,w-r*2,h)
    lg.circle("fill", x+w-r, y+r, r)
    lg.setColor(.3,.3,.3)
    lg.circle("fill", x+r, y+r, r-4)
    lg.rectangle("fill", x+r+2,y+4,w-(r)*2,h-8)
    lg.circle("fill", x+w-r, y+r, r-4)
    
    if self.active then
        lg.setColor(.6,.6,.6)
        if self.selected then
            lg.circle("fill", x+w-r-1, y+r, r-6)
        else    
            lg.circle("fill", x+1+r, y+r, r-6)
        end
    end
    
end

return togglebox