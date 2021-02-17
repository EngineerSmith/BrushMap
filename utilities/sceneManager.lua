
local sceneManager = {
    currentScene = nil,
    nilFunc = function() end,
    sceneHandlers = {
        -- GAME LOOP
        "load",
        "unload",
        "update",
        "draw",
        -- WINDOW 
        "focus",
        "resize",
        "visable",
        "displayrotated",
        "filedropped",
        "directorydropped",
        -- MOBILE INPUT
        "touchpressed",
        "touchmoved",
        "touchreleased",
        -- MOUSE INPUT
        "mousepressed",
        "mousemoved",
        "mousereleased",
        "mousefocus",
        "wheelmoved",
        -- KEY INPUT
        "keypressed",
        "keyreleased",
        "textinput",
        "textedited",
        -- JOYSTICK/GAMEPAD INPUT
        "joystickhat",
        "joystickaxis",
        "joystickpressed",
        "joystickreleased",
        "joystickadded",
        "joystickremoved",
        "gamepadpressed",
        "gamepadreleased",
        "gamepadaxis",
        -- ERROR
        "threaderror",
        "lowmemory"
    }
}

sceneManager.changeScene = function(scene, ...)
    scene = require(scene) --TODO Add load fail catch 
    
    for _, v in ipairs(sceneManager.sceneHandlers) do
        love[v] = scene[v] or sceneManager.nilFunc
    end
    
    if sceneManager.currentScene then
        love.unload()
    end
    
    sceneManager.currentScene = scene
    love.load(...)
end

return sceneManager
