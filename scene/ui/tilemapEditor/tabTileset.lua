local tabWindow = require("ui.tabWindow")

local anchor = require("ui.base.anchor")
local button = require("ui.button")

return function(font, controller, window)
local tabTileset = tabWindow.new("Tileset", font, controllerWest)

tabTileset.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,40, 20,0)
    local tilesetReturn = button.new(anchor, nil, function()
        require("utilities.sceneManager").changeScene("scene.tilesetEditor")
    end)
    tilesetReturn:setText("Tileset Editor", nil, font)
    self:addChild(tilesetReturn)
end

return tabTileset
end