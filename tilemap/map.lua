local map = {}
map.__index = map

map.new = function()
    local self = setmetatable({
        layers = {}
    }, map)
    return self
end

map.draw = function()
    
end

return map