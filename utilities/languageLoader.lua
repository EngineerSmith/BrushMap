local lang = require("utilities.language")
local lfs = love.filesystem

local directory = "assets/locales/"

return function()
    local items = lfs.getDirectoryItems(directory)
    for _, item in ipairs(items) do
        local key = item:match("(.+)%..+$")
        local locale = require(directory..key)
        lang.import(key, locale)
    end
end