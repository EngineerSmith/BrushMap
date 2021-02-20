local scene = {}
local lg = love.graphics

local lily = require("utilities.lilyLoader")

scene.update = function()
    if lily:isComplete() then
        require("utilities.sceneManager").changeScene("scene.menu")
    end
end

local maxWidth, lineDistance = 100, 4

scene.draw = function() 
    local width = (lily:getLoadedCount() / lily:getCount()) * maxWidth
    lg.setColor(1,1,1)
    lg.rectangle("line", 50-lineDistance,50-lineDistance,maxWidth+(lineDistance*2),5+(lineDistance*2))
    lg.rectangle("fill", 50,50,width,5)
end

return scene