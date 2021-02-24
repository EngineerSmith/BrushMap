local ui = require("ui.base.ui")
local scrollView = setmetatable({}, ui)
scrollView.__index = scrollView

local shape = require("ui.shape")

local lg = love.graphics
local insert = table.insert

scrollView.new = function(anchor, widthDistance, heightDistance, maskFunction)
    local self = setmetatable(ui.new(anchor), scrollView)
    
    self.background = shape.new(anchor, "Rectangle", {0.4,0.4,0.4, 0.4}, "fill")
    self.widthDistance = widthDistance or 0
    self.heightDistance = heightDistance or 10
    
    self.maskFunction = maskFunction or function()
        local x,y, width,height = self.anchor:getRect()
        lg.rectangle("fill", x,y, width,height)
    end
    
    self.offsetX, self.offsetY = 0,0
    
    return self
end

scrollView.addChild = function(self, child)
    if child.parent then 
        error("Child already a has parent") 
    end
    
    insert(self.children, child)
    self.children.count = self.children.count + 1
    child.parent = self
    
    local num = self.children.count - 1
    
    child.anchor.x = num * self.widthDistance
    child.anchor.y = num * self.heightDistance
    
    self:getAnchorUpdate()
end

scrollView.empty = function(self)
    local removedChildren = self.children
    self.children = {count=0}
    return removedChildren
end

scrollView.draw = function(self)
    self.background:drawElement()
    
    lg.setColor(1,1,1)
    
    lg.stencil(self.maskFunction, "replace", "1")
    lg.setStencilTest("greater", 0)
    
    lg.push()
    --lg.translate(self.offsetX, self.offsetY)
    
    self:drawChildren()
    
    lg.pop()
    
    lg.setStencilTest()
end

return scrollView