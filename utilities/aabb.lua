local aabb = function(pointX, pointY, x,y,w,h)
    return pointX > x and pointX < x + w and
           pointY > y and pointY < y + h
end

return aabb