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
local tab3 = tabWindow.new("3")
local tab4 = tabWindow.new("4")
local tab5 = tabWindow.new("5")

controller:addChild(tab1)
controller:addChild(tab2)
controller:addChild(tab3)
controller:addChild(tab4)
controller:addChild(tab5)

return window