function love.conf(t)
	t.version = "0.9.1"
	t.modules.joystick = false
	t.modules.physics = false
	t.modules.mouse = false

	t.window.width = 1024
	t.window.height = 768
	t.window.title = "Achtung! Dat curve!"
	t.window.fsaa = 0
end
