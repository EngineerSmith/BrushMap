local window = require("ui.base.window").new()

--local anchor = require("ui.base.anchor")

local colorPicker = require("ui.colorPicker")

local picker = colorPicker.new()

window:addChild(picker)

return window