local scene = {}

scene.update = function()
    require("utilities.sceneManager").changeScene("scene.menu")
end

return scene