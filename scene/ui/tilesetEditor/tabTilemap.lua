local tabWindow = require("ui.tabWindow")

local anchor = require("ui.base.anchor")
local button = require("ui.button")

return function(font, controller, window)
local tabTilemap = tabWindow.new("Tilemap", font, controller)

tabTilemap.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,40, 20,0)
    local tilemapReturn = button.new(anchor, nil, function()
        require("utilities.sceneManager").changeScene("scene.editor")
    end)
    tilemapReturn:setText("Return", nil, font)
    self:addChild(tilemapReturn)
end

return tabTilemap
end