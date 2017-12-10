require "player"
require "menu"
require "pgen"
require "fx"

--[[
-- A table with some global variables defined which can be used throughout the
--  This table is not intended to keep state of the game, but rather some
-- globally reusable resources such as images, or fonts. This somewhat allows
-- us to put these things in their own 'namespace'.
--]]
globals = {
	debug            = true,
	gameFont         = nil,
	gameFontLarge    = nil,
	playableArea = {
		width = love.window.getWidth(),
		height = love.window.getHeight() - 50,
	},
}

menu = {
	currentMenu,
	main,
	options,
}

button = {
	play,
	options,
	quit,
	players,
	back,
}

-- Effects
local bgeffect = nil
local bob = nil

-- Others
local gameStarted = false

local delta = 0

local players = {}

local pgen = nil

local startCounter = 5
local startCounterSize = 50

local ticksSinceStart = 0

local shaker = nil

local scoreboard = nil

local gameState = nil

function initMenu()
	menu.main = Menu.new()
	menu.options = Menu.new()

	button.play = Button.new("Start :)")
	button.play.action = function() gameStarted = true end

	button.options = Button.new("Options")
	button.options.action = function()
		menu.currentMenu = menu.options
		menu.currentMenu:selectFirst()
	end

	button.quit = Button.new("Quit :(")
	button.quit.action = function() love.event.quit() end

	menu.main:addButton(button.play)
	menu.main:addButton(button.options)
	menu.main:addButton(button.quit)


	button.players = Button.new("Add player")
	button.back = Button.new("Back")

	button.back.action = function()
		menu.currentMenu = menu.main
		menu.currentMenu:selectFirst()
	end

	menu.options:addButton(button.players)
	menu.options:addButton(button.back)

	menu.currentMenu = menu.main
end

function initPlayers()
	local player = Player.new()
	player.color = { 255, 0, 0 }
	player.name = "Proxima"
	table.insert(players, player)
	player = Player.new()
	player.color = { 0, 0, 255 }
	player.name = "Centauri"
	table.insert(players, player)
	player = Player.new()
	player.color = { 0, 255, 255 }
	player.name = "Sirius"
	table.insert(players, player)
	player = Player.new()
	player.color = { 255, 0, 255 }
	player.name = "Alnitak"
	table.insert(players, player)
end

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	local glyphs = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-=_+|/\\:;'\"<>,.?"
	globals.gameFont      = love.graphics.newImageFont("font.png", glyphs)
	globals.gameFontLarge = love.graphics.newImageFont("font-large.png", glyphs)

	shaker = Shaker.new()
	bgeffect = BgEffect.new()
	bob = BobbingText.new("text")

	initMenu()
	initPlayers()

	scoreboard = Scoreboard.new()
	scoreboard.players = players

	gameState = currentMenu
end

function love.update(dt)
	ticksSinceStart = ticksSinceStart + dt

	shaker:update(dt)

	if not gameStarted then
		bgeffect:update(dt)
		bob:update(dt)
		menu.currentMenu:update(dt)
		return
	end

	delta = delta + dt
	if delta >= 1 then
		startCounter = startCounter - 1
		startCounterSize = 50
		delta = 0
	end

	for k, v in pairs(players) do
		v:update(dt)
	end

	-- Iterate through the players, and see if we collide with any other players... or ourselves!
	for k, p1 in pairs(players) do
		for k, p2 in pairs(players) do
			if p1:collidesWith(p2) then
				p1:die()
				shaker:reset()
				shaker.shaking = true
			end
		end
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

		for k, v in pairs(players) do
			v:draw()
		end

		-- TODO: draw death animation last, to make sure the animation is drawn on top
		-- of everything else.

		if pgen then
			pgen:draw()
		end

		scoreboard:draw()
	else
		bgeffect:draw()
		menu.currentMenu:draw()
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
	elseif key == 'left' then players[1]:left()
	elseif key == 'right' then players[1]:right()
	elseif key == 'up' then menu.currentMenu:focus(-1)
	elseif key == 'down' then menu.currentMenu:focus(1)
	elseif key == "return" then menu.currentMenu:fireEvent()
	elseif key == "a" then players[2]:left()
	elseif key == "s" then players[2]:right()
	elseif key == "f" then love.window.setFullscreen(true)
	elseif key == "p" then
		shaker:reset()
		shaker.shaking = true
	elseif key == " " then
		pgen = ParticleGenerator.new(300, 400)
		pgen.color = {120,200,255}
		pgen.continuous = true
		pgen:init()
	elseif key == "x" then players[1]:die()
	elseif key == "d" then globals.debug = not globals.debug
	elseif key == "r" then
		delta = 0
		startCounter = 5
		startCounterSize = 50
	end
end

function love.keyreleased(key)
	if key == 'left' or key == 'right' then
		players[1]:stop()
	end
	if key == "a" or key == "s" then
		players[2]:stop()
	end
end

