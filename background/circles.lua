local background = require("background.background")
local lg, lm = love.graphics, love.math
local insert = table.insert
local remove = table.remove

local maxSize = lg.getWidth() > lg.getHeight() and lg.getHeight()/2 or lg.getWidth()/2
local minSize = maxSize/4

local minTime, maxTime = 4, 7

local minColor, maxColor, colorDp = 10, 18, 2

local circles = {}

local createCircle = function(index)
    local circle = {
        color = lm.random(minColor, maxColor) / (10 ^ colorDp),
        alpha = 0, 
        alphaMaxTime = lm.random(minTime, maxTime),
        alphaTime = 0,
        size = lm.random(minSize, maxSize),
        x = lm.random(0-minSize/2, lg.getWidth()+minSize/2),
        y = lm.random(0-minSize/2, lg.getHeight()+minSize/2),
    }
    circles[index] = circle
end

local updateCircle = function(dt, circle, index)
    circle.alphaTime = circle.alphaTime + dt
    
    if circle.alphaTime >= circle.alphaMaxTime then
        createCircle(index)
    end
    
    circle.alpha = circle.alphaTime / circle.alphaMaxTime + 0.3
end

local drawCircle = function(circle)
    local c = circle.color
    lg.setColor(c, c ,c, circle.alpha)
    lg.circle("fill", circle.x, circle.y, circle.size)
end

background.load = function(numberOfCircles)
    numberOfCircles = numberOfCircles or 0
    for i=1, numberOfCircles do
        createCircle(i)
    end
end

background.update = function(dt)
    for i, circle in ipairs(circles) do
        updateCircle(dt, circle, i)
    end
end

lg.setBackgroundColor(0,0,0)
background.draw = function()
    for _, circle in ipairs(circles) do
        drawCircle(circle)
    end
end

return background