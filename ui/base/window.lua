local ui = require("ui.base.ui")
local window = setmetatable({}, {__index=ui})
window.__index = window

local anchor = require("ui.base.anchor")

window.new = function()
    local anchor = anchor.new("NorthWest", 0, 0,-1,-1)
    local self = setmetatable(ui.new(anchor), window)
    return self
end

return window