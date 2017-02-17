require "player"
require "pgen"

local delta = 0
local player1
local player2

local pgen = nil

local startCounter = 5
local startCounterSize = 50

local ticksSinceStart = 0

function love.load()
	player1 = Player.new()
	player1.color = { r = 255, g = 0, b = 0}
	player2 = Player.new()
	player2.color = { r = 0, g = 255, b = 0}
end

function love.update(dt)
	ticksSinceStart = ticksSinceStart + dt
	delta = delta + dt
	if delta >= 1 then
		startCounter = startCounter - 1
		startCounterSize = 50
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

	if pgen then
		pgen:update(dt)
	end

	startCounterSize = math.max(startCounterSize - (dt * 50), 0)
end

function love.draw()
	if startCounter > 0 then
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(startCounter, love.window.getWidth() / 2, love.window.getHeight() / 2, 0, startCounterSize, startCounterSize)
	end

	player1:draw()
	player2:draw()

	-- TODO: draw death animation last, to make sure the animation is drawn on top
	-- of everything else.

	if pgen then
		pgen:draw()
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.print(ticksSinceStart, 0, 0)
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit()
	elseif key == 'left' then player1:left()
	elseif key == 'right' then player1:right()
	elseif key == "a" then player2:left()
	elseif key == "s" then player2:right()
	elseif key == " " then
		pgen = ParticleGenerator.new(300, 400)
		pgen:init()
	elseif key == "d" then player1:die()
	elseif key == "r" then
		delta = 0
		startCounter = 5
		player1 = Player.new()
		player1.color = { r = 255, g = 0, b = 0}
		player2 = Player.new()
		player2.color = { r = 0, g = 0, b = 255}
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

