local scene = {}
local lg, ls = love.graphics, love.system

local nfs = require("lib.nativefs")

local lily

local mountDrive = function(path, to)
    assert(nfs.mount(path, to), "Unable to mount drive, tell a programmer: "..path)
end

scene.load = function()
    if ls.getOS() == "Android" then
       mountDrive("/storage/emulated/0/Download", "externalAssets/Download")
    end
    
    lily = require("utilities.lilyLoader")
end

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