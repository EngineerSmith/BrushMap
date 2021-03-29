local window = require("ui.base.window").new()

local global = require("global")

local anchor = require("ui.base.anchor")
local button = require("ui.button")

local anchor = anchor.new("Center", 0,0, 200,60)
local button = button.new(anchor, nil, global.assets["font.robotoReg18"])
button:setText("To Tileset Editor")
button:setCallbackPressed(function(self)
    require("utilities.sceneManager").changeScene("scene.tilesetEditor")
end)

window:addChild(button)

return window