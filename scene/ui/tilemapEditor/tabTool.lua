local tabWindow = require("ui.tabWindow")

local global = require("global")

local anchor = require("ui.base.anchor")
local button = require("ui.button")
local shape = require("ui.shape")
local tilePreviewGrid = require("ui.tilePreviewGrid")

return function(font, controller, window)
local tabTool = tabWindow.new("Tools", font, controller)

tabTool.createUI = function(self)
    
    local anchor = anchor.new("NorthWest", 10,30, 50,50)
    local c = {.9,.9,.9}
    local drawButton = button.new(anchor, nil, function(self)
        self.selected = not self.selected
        self:setOutline(self.selected, 2, 5, c)
    end)
    drawButton:setImage(global.assets["icon.brush"])
    self:addChild(drawButton)
    
    local anchor = anchor.new("NorthWest", 10,90, -1,5, 20,0)
    self:addChild(shape.new(anchor, "Rectangle", {.4,.4,.4}, "fill"))
    
    local anchor = anchor.new("NorthWest", 10,100, -1,-1,20,0)
    local tilePreviewGrid = tilePreviewGrid.new(anchor, global.editorSession.tilesets, font)
    self:addChild(tilePreviewGrid)
end

return tabTool
end