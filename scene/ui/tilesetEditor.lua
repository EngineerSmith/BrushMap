local window = require("ui.base.window").new()

--local anchor = require("ui.base.anchor")

local tabController = require("ui.tabController")
local tabWindow = require("ui.tabWindow")
local colorPicker = require("ui.colorPicker")

--local picker = colorPicker.new()
--window:addChild(picker)

local controller = tabController.new()
window:addChild(controller)

local tab1 = tabWindow.new("1")
local tab2 = tabWindow.new("2")

controller:addChild(tab1)
controller:addChild(tab2)

return window