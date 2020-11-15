function love.conf(t)
    t.window.title = "cellular automaton"
    t.window.width = 1600
    t.window.height = 1200

    t.modules.audio = false
    t.modules.graphics = true           -- Enable the graphics module (boolean)
    t.modules.image = false
    t.modules.joystick = false
    --t.modules.mouse = false
    t.modules.physics = false
    --t.window.resizable = true
    t.modules.sound = false
    t.modules.thread = true             -- Enable the thread module (boolean)
    t.modules.touch = false              -- Enable the touch module (boolean)
    t.modules.video = false              -- Enable the video module (boolean)
end
