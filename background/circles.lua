local background = require("background.background")
local lg, lm = love.graphics, love.math
local insert = table.insert
local remove = table.remove

local maxSize = lg.getWidth() > lg.getHeight() and lg.getHeight()/2 or lg.getWidth()/2
local minSize = maxSize/4

local minTime, maxTime = 4, 7

local colors = {
    3,
    {0.07, 0.07, 0.07},
    {0.08, 0.08, 0.08},
    {0.10, 0.10, 0.10},
}

local circles = {}

local createCircle = function(index)
    local circle = {
        color = colors[lm.random(2,colors[1])],
        alpha = 1, 
        alphaMaxTime = lm.random(minTime, maxTime),
        alphaTime = 0,
        size = lm.random(minSize, maxSize),
        x = lm.random(0-minSize, lg.getWidth()+minSize),
        y = lm.random(0-minSize, lg.getHeight()+minSize),
    }
    circles[index] = circle
end

local updateCircle = function(dt, circle, index)
    circle.alphaTime = circle.alphaTime + dt
    
    if circle.alphaTime >= circle.alphaMaxTime then
        createCircle(index)
    end
    
    circle.alpha = circle.alphaTime / circle.alphaMaxTime
end

local drawCircle = function(circle)
    lg.setColor(circle.color, circle.alpha)
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