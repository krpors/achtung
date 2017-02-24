require "player"
require "menu"
require "pgen"
require "fx"

--[[
-- A table with some global variables defined which can be used throughout the
-- game. This table is not intended to keep state of the game, but rather some
-- globally reusable resources such as images, or fonts. This somewhat allows
-- us to put these things in their own 'namespace'.
--]]
globals = {
	debug         = true,
	gameFont      = nil,
	gameFontLarge = nil,
}


local gameMenu = nil
local bgeffect = nil
local bob = nil
local btnPlay = nil
local btnOptions = nil
local btnQuit = nil

local gameStarted = false

local delta = 0
local player1
local player2

local pgen = nil

local startCounter = 5
local startCounterSize = 50

local ticksSinceStart = 0

local shaker = nil

function love.load()
	local glyphs = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-=_+|/\\:;'\"<>,.?"
	globals.gameFont      = love.graphics.newImageFont("font.png", glyphs)
	globals.gameFontLarge = love.graphics.newImageFont("font-large.png", glyphs)

	shaker = Shaker.new()

	gameMenu = Menu.new()
	bgeffect = BgEffect.new()

	bob = BobbingText.new("text")

	btnPlay = Button.new("Play!!1one")
	btnPlay.action = function() gameStarted = true end
	btnOptions = Button.new("Roflcoptions")
	btnOptions.action = function() print("No action for options yet") end
	btnQuit = Button.new("Quit :(")
	btnQuit.action = function() love.event.quit() end

	gameMenu:addButton(btnPlay)
	gameMenu:addButton(btnOptions)
	gameMenu:addButton(btnQuit)

	player1 = Player.new()
	player1.color = { r = 255, g = 0, b = 0}
	player2 = Player.new()
	player2.color = { r = 0, g = 255, b = 0}
end

function love.update(dt)
	ticksSinceStart = ticksSinceStart + dt

	shaker:update(dt)

	if not gameStarted then
		bgeffect:update(dt)
		bob:update(dt)
		return
	end

	delta = delta + dt
	if delta >= 1 then
		startCounter = startCounter - 1
		startCounterSize = 50
		delta = 0
	end

	player1:update(dt)
	player2:update(dt)

	if player1:collidesWith(player2) and not player1.dead then
		print("Player 1 died")
		player1:die()
		shaker:reset()
		shaker.shaking = true
	end
	if player2:collidesWith(player1) and not player2.dead then
		print("Player 2 died")
		player2:die()
		shaker:reset()
		shaker.shaking = true
	end

	if pgen then
		pgen:update(dt)
	end


	startCounterSize = math.max(startCounterSize - (dt * 50), 0)
end


function love.draw()
	shaker:draw()

	if gameStarted then
		if startCounter > 0 then
			love.graphics.setFont(globals.gameFontLarge)
			love.graphics.setColor(255, 255, 255)
			love.graphics.printf(startCounter, love.window.getWidth() / 2, love.window.getHeight() / 2, 20, "center", 0, startCounterSize, startCounterSize, 20/2, 20/2)
		end


		player1:draw()
		player2:draw()

		-- TODO: draw death animation last, to make sure the animation is drawn on top
		-- of everything else.

		if pgen then
			pgen:draw()
		end
	else
		bgeffect:draw()
		gameMenu:draw()
		bob:draw()
	end


	if globals.debug then
		love.graphics.setFont(globals.gameFont)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print("Ticks since start: " .. ticksSinceStart .. " seconds", 0, 0)
	end

end

function love.keypressed(key)
	if key == 'escape' then
		gameStarted = false
		bob:reset()
	elseif key == 'left' then player1:left()
	elseif key == 'right' then player1:right()
	elseif key == 'up' then gameMenu:focus(-1)
	elseif key == 'down' then gameMenu:focus(1)
	elseif key == "return" then gameMenu:fireEvent()
	elseif key == "a" then player2:left()
	elseif key == "s" then player2:right()
	elseif key == "p" then
		shaker:reset()
		shaker.shaking = true
	elseif key == " " then
		pgen = ParticleGenerator.new(300, 400)
		pgen.color = {120,200,255}
		pgen.continuous = true
		pgen:init()
	elseif key == "x" then player1:die()
	elseif key == "d" then globals.debug = not globals.debug
	elseif key == "r" then
		delta = 0
		startCounter = 5
		startCounterSize = 50
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

