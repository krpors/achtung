require "player"

local delta = 0
local player

function love.load()
	player = Player.new()
end

function love.conf(t)
end

function love.update(dt)
	delta = delta + dt
	if delta >= 1.0 then
		delta = 0
	end
	player:update(dt)

end

function love.draw()
	player:draw()
end
function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'left' then
		player:left()
	elseif key == 'right' then
		player:right()
	end
end

function love.keyreleased(key)
	if key == 'left' or key == 'right' then
		player:stop()
	end
end
