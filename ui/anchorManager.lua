local anchorManager = {}
anchorManager.__index = anchorManager

local insert, remove = table.insert, table.remove

anchorManager.new = function()
    local self = setmetatable({}, anchorManager)
    self.anchors = {}
    self.size = 0
    return self
end

anchorManager.add = function(self, anchor, windowWidth, windowHeight)
    
    if anchor.index then
       error("Can't add anchor that is managed by another anchorManager") 
    end
    
    insert(self.anchors, anchor)
    self.size = self.size + 1
    anchor:resize(windowWidth, windowHeight)
    anchor.index = self.size -- index
    return self.size
end

anchorManager.remove = function(self, anchor)
    self.anchors[anchor.index] = nil
    anchor.index = nil
end

anchorManager.resize = function(self, windowWidth, windowHeight)
    for _, anchor in ipairs(self.anchors) do
        if anchor then 
            anchor:resize(windowWidth, windowHeight)
        end
    end
end

return anchorManager