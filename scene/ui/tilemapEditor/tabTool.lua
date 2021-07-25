local tabWindow = require("ui.tabWindow")

local global = require("global")

local anchor = require("ui.base.anchor")
local button = require("ui.button")
local shape = require("ui.shape")
local tilePreviewGrid = require("ui.tilePreviewGrid")

return function(font, controller, window)
local tabTool = tabWindow.new("Tools", font, controller)

tabTool.createUI = function(self)
    
    local c = {.9,.9,.9}
    
    local tools, moveButton = nil, nil -- init later
    
    local buttFnc = function(button)
        for _, tool in ipairs(tools) do
            if tool ~= button then
                tool:setOutline(false)
                tool.selected = false
            end
        end
        
        button.selected = not button.selected
        button:setOutline(button.selected, 2, 5, c)
        
        
        if button.selected == false then
            moveButton.selected = true
            moveButton:setOutline(true, 2, 5, c)
            window.selectedTool = moveButton.tool
        else
            window.selectedTool = button.tool
        end
    end
    
    local anchor = anchor.new("NorthWest", 10,30, 50,50)
    moveButton = button.new(anchor, nil, buttFnc)
    moveButton:setImage(global.assets["icon.move"])
    moveButton.tool = "move"
    self:addChild(moveButton)
    
    local anchor = anchor.new("NorthWest", 70,30, 50,50)
    local drawButton = button.new(anchor, nil, buttFnc)
    drawButton:setImage(global.assets["icon.brush"])
    drawButton.tool = "brush"
    self:addChild(drawButton)
    
    tools = {moveButton, drawButton}
    buttFnc(moveButton) -- Default moveButton selected
    
    
    local anchor = anchor.new("NorthWest", 10,90, -1,5, 20,0)
    self:addChild(shape.new(anchor, "Rectangle", {.4,.4,.4}, "fill"))
    
    local anchor = anchor.new("NorthWest", 5,100, -1,-1)
    local tilePreviewGrid = tilePreviewGrid.new(anchor, global.editorSession.tilesets, font)
    tilePreviewGrid.CBSelectTile = function(_, tile)
        window.selectedTile = tile
    end
    self:addChild(tilePreviewGrid)
end

return tabTool
end