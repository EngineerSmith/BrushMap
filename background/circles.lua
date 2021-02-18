local background = setmetatable({}, require("background.background"))

local lg, lm = love.graphics, love.math
local insert, remove = table.insert, table.remove

local _, _, width, height = love.window.getSafeArea()

local maxSize = width > height and height / 2 or width / 2
local minSize = maxSize / 4

local minTime, maxTime, timeDp = 40, 70, 1

local minColor, maxColor, colorDp = 15, 23, 2

local circles = {}

local createCircle = function()
    local circle = {
        color = lm.random(minColor, maxColor) / (10 ^ colorDp),
        alpha = 0, 
        alphaMaxTime = lm.random(minTime, maxTime) / (10 ^ timeDp),
        alphaTime = 0,
        size = lm.random(minSize, maxSize),
        x = lm.random(0 - minSize / 4, width + minSize / 2),
        y = lm.random(0 - minSize / 4, height + minSize / 2),
    }
    insert(circles, circle)
end

local updateCircle = function(dt, circle, index)
    circle.alphaTime = circle.alphaTime + dt
    
    if circle.alphaTime >= circle.alphaMaxTime then
        remove(circles, index)
        createCircle()
    end
    
    circle.alpha = circle.alphaTime / circle.alphaMaxTime + 0.3
end

local drawCircle = function(circle)
    local c = circle.color * (1-circle.alpha)
    lg.setColor(c, c ,c, 1)
    lg.circle("fill", circle.x, circle.y, circle.size)
end

background.load = function(numberOfCircles)
    numberOfCircles = numberOfCircles or 0
    for _ = 1, numberOfCircles do
        createCircle()
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

background.resize = function(windowWidth, windowHeight)
    _, _, width, height = love.window.getSafeArea()
    maxSize = width > height and height / 2 or width / 2
    minSize = maxSize / 4
end

return background