require "player"
require "pgen"

local delta = 0
local player1
local player2

local pgen

function love.load()
	player1 = Player.new()
	player1.color = { r = 255, g = 0, b = 0}
	player2 = Player.new()
	player2.color = { r = 0, g = 255, b = 0}

	pgen = ParticleGenerator.new()
end

function love.update(dt)
	delta = delta + dt
	if delta >= 0.1 then
		delta = 0
	end

	player1:update(dt)
	player2:update(dt)

	if player1:collidesWith(player2) then
		player1:die()
	end
	if player2:collidesWith(player1) then
		player2:die()
	end

	pgen:update(dt)
end

function love.draw()
	player1:draw()
	player2:draw()

	pgen:draw()
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit()
	elseif key == 'left' then player1:left()
	elseif key == 'right' then player1:right()
	elseif key == "a" then player2:left()
	elseif key == "s" then player2:right()
	elseif key == " " then pgen:init()
	end
end

function love.keyreleased(key)
	if key == 'left' or key == 'right' then
		player1:stop()
	end
	if key == "a" or key == "s" then
		player2:stop()
	end
end

