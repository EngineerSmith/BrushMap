local list = {}
list.__index = list

list.new = function()
    return setmetatable({
        items = {},
        hash = {},
        size = 0
    }, list)
end

list.clear = function(self)
    self.items = {}
    self.hash = {}
    self.size = 0
    
    return self
end

list.add = function(self, item)
    local index = self.size + 1
    
    self.items[index] = item
    self.hash[item.id] = index
    self.size = index
    
    return self
end

list.remove = function(self, item, index)
    index = index or self.hash[item.id]
    local size = self.size
    
    if index == size then
        self.items[index] = nil
    else
        local last = self.items[size]
        self.items[index] = last
        self.hash[last.id] = index
        self.items[size] = nil
    end
    self.hash[item.id] = nil
    self.size = size - 1
end

list.get = function(self, itemId)
    if self.hash[itemId] ~= nil then
        return self.items[self.hash[itemId]]
    end
    return nil
end

list.has = function(self, item)
    return self.hash[item.id] ~= nil    
end

return list