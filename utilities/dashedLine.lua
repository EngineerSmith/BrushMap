local lg = love.graphics
local atan2, sqrt = math.atan2, math.sqrt

local dashedLine = function(p1x, p1y, p2x, p2y, dash, gap)
    local dx, dy = p2x - p1x, p2y - p1y
    local angle = atan2(dy, dx)
    local stride = dash + gap
    local length = sqrt(dx*dx+dy*dy)
    local count = (length - dash) / stride
    
    lg.push()
    lg.translate(p1x,p1y)
    lg.rotate(angle)
    for i=0, count do
        local j = i * stride
        lg.line(j, 0, j + dash, 0)
    end
    local j = count * stride
    lg.line(j,0, j + dash,0)
    lg.pop()
end

return dashedLine