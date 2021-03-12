local min, max = math.min, math.max

local inbetween = function(low, high, value)
    return min(high, max(low, value))
end

return inbetween