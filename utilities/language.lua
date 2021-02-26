local language = {
    all = {},
    localeKey = nil,
    imported = 0
}

language.import = function(localeKey, locale)
    language.all[localeKey] = locale
    language.imported = language.imported + 1
end

language.setLocale = function(localeKey)
    language.isLocaleValid(localeKey)
    language.localeKey = localeKey
end

--Place given data into string E.g.
-- format("$1's Money $2", "Bob", 100) -> "Bob's Money 100" 
local format = function(str, ...)
    local n = select('#', ...)
    for i=1, n do
        str = str:gsub("$"..i, tostring(select(i, ...)))    
    end
    return str
end

language.getTextLocale = function(localeKey, stringKey, ...)
    language.isLocaleValid(localeKey)
    stringKey = stringKey or error("StringKey required")
    
    local str = language.all[localeKey][stringKey]
    if str == "nil" then
        error("Locale doesn't contain string: LocaleKey: "..LocaleKey.." StringKey: "..stringKey)
    end
    return format(str, ...)
end

language.getText = function(stringKey, ...)
    return language.getTextLocale(language.localeKey, stringKey, ...)
end

language.isLocaleValid = function(localeKey)
    localeKey = localeKey or error("localeKey required")
    if language.all[localeKey] == nil then
        error("LocaleKey not imported")
    end
end

local insert,sort = table.insert, table.sort

language.getLocales = function()
    local locales = {}
    for key, _ in pairs(language.all) do
       insert(locales, {key=key, name=language.all[key]["language"] or key}) 
    end
    local sortFunction = function(a, b) return a.name < b.name end
    sort(locales, sortFunction)
    return locales
end

return language