local window = require("ui.base.window").new()

local global = require("global")

local anchor = require("ui.base.anchor")

local shape = require("ui.shape")
local button = require("ui.button")
local scrollView = require("ui.scrollView")
local directoryItem = require("ui.directoryItem")

local anchor = anchor.new("Center", 0,0, -1,-1, 70,70)
local background = shape.new(anchor, "Rectangle", {0.4,0.4,0.4, 0.5}, "fill", 7)

window:addChild(background)

local iconSize = 30

local anchor = anchor.new("SouthWest", 10,10, -1,-1, 150, 80)
local fileScrollView = scrollView.new(anchor, 0, iconSize + 2)
window.scrollView = fileScrollView
background:addChild(fileScrollView)

local anchor = anchor.new("SouthEast", 10,10, 120,120)
local actionButton = button.new(anchor)

background:addChild(actionButton)

local fileItemCallback = function(self, selected)
    if selected and window.previousSelected then
        window.previousSelected:setSelected(false)
        window.previousSelected = self
    elseif selected then
        window.previousSelected = self
    else
        window.previousSelected = nil
    end
    return true
end

local fileItemfactory = function(fileName)
    fileName = fileName or error("File name required")
    local item = directoryItem.new(global.assets["icon.stack"], fileName, global.assets["font.kennyfuture12"], iconSize, fileItemCallback)
    window.scrollView:addChild(item)
end

local directoryItemFactory = function(directoryName)
    directoryName = directoryName or error("Directory name required")
    local item = directoryItem.new(global.assets["icon.folder.open"], directoryName, global.assets["font.kennyfuture12"], iconSize)
    window.scrollView:addChild(item)
end

fileItemfactory("Test1.png")
fileItemfactory("Test2.png")
fileItemfactory("Test3.png")
fileItemfactory("Test4.png")
fileItemfactory("Test5.png")
fileItemfactory("Test6.png")
fileItemfactory("Test7.png")
fileItemfactory("Test8.png")
fileItemfactory("Test9.png")
fileItemfactory("Test10.png")
fileItemfactory("Test11.png")
fileItemfactory("Test12.png")
fileItemfactory("Test13.png")
fileItemfactory("Test14.png")
fileItemfactory("Test15.png")
fileItemfactory("Test16.png")
--fileItemfactory("Test3.png")
--[[ 
CALLBACK EXAMPLE
    function callback(success, filePath) end
FILTER EXAMPLE
    {"png", "tga", "jpeg", "jpg"}
]]

window.modes = {
    ["save"] = "Save Here",
    ["load"] = "Load",
}

window.dialog = function(callback, mode, filter)
    window.callback = callback or error("Callback required when displaying file dialog")
    window.mode = window.modes[mode] and mode or error("Mode not supported in file dialog. "..tostring(mode))
    
    actionButton:setText(window.modes[mode])
    
end

return window