local scene = {}

local anchor = require("ui.base.anchor")
local button = require("ui.button")

local anchor = anchor.new("Center", 0,0, 200,60)
scene.button = button.new(anchor)
scene.button:setText("To Tileset Editor")
scene.button:setCallbackPressed(function(self)
    require("utilities.sceneManager").changeScene("scene.tilesetEditor")
end)

scene.update = function(dt) scene.button:update(dt) end
scene.draw = function() scene.button:draw() end
scene.touchpressed = function(...) scene.button:touchpressed(...) end

return scene