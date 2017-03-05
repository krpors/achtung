require "util"
require "pgen"

Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)

	self.soundDeath = love.audio.newSource("boom.wav", "static")
	self.soundDeath:setPitch(math.random() + 0.5)

	self.moveLeft = false
	self.moveRight = false

	self.dead = false

	-- Has the player just started? In that case, give the player some time to
	-- move around and give him or her some room to re-pick the direction.
	self.startupCounter = 5 -- seconds

	-- Initialize random seed to place the player at a random position and
	-- a random direction.

	-- Thie history table, contains coordinates of all the positions the player
	-- has visited. This table is used for drawing the path the player has gone
	-- through, as well as collision detection with ourselves and other players.
	self.history = {}

	-- Counter is used to draw a gap in the player's path.
	self.counter = 0

	-- Color of the player as a table with r, g, b properties.
	self.color = {
		255,
		0,
		255
	}

	self.name = "Player"

	-- Size of the player (radius)
	self.size = 5
	-- Rotation (direction) the player starts at.
	self.rot = love.math.random() * 2 * math.pi
	-- Speed
	self.velocity = 120

	-- The player's current (initial) position.
	self.pos = {
		x = love.math.random() * love.window.getWidth(),
		y = love.math.random() * love.window.getHeight()
	}

	-- Our previous position, to calculate how many pixels we diverged, to know
	-- whether we should insert something in the history table.
	self.prevpos = {
		x = self.pos.x,
		y = self.pos.y
	}

	self.deathParticles = nil

	return self
end

-- Player is always moving, until death.
function Player:update(dt)
	if self.dead then
		self.deathParticles:update(dt)
		return
	end

	if self.moveLeft then
		self.rot = self.rot - 2 * dt
	end
	if self.moveRight then
		self.rot = self.rot + 2 * dt
	end

	local newx = self.pos.x + math.cos(self.rot) * (self.velocity * dt)
	local newy = self.pos.y + math.sin(self.rot) * (self.velocity * dt)

	self.pos.x = newx
	self.pos.y = newy

	-- handle bounds of the screen.
	if newx - self.size > globals.playableArea.width then
		self.pos.x = 0 - self.size
	elseif newx + self.size < 0 then
		self.pos.x = globals.playableArea.width + self.size
	elseif newy - self.size >= globals.playableArea.height then
		self.pos.y = 0 - self.size;
	elseif newy + self.size <= 0 then
		self.pos.y = globals.playableArea.height - self.size
	end

	-- So, if the player is starting the game, give the player some time to move before
	-- we actually start. No collision detection is done (we're returning prematurely).
	-- By default, just use 5 seconds, which is just arbitrarily chosen.
	if self.startupCounter >= 0 then
		self.startupCounter = self.startupCounter - dt
		-- No further processing necessary, we're just starting. Return from the
		-- function, don't do any path memorizing or collision detection.
		return
	end

	-- To prevent lots of inserts into the history table (e.g. the paths we have followed as
	-- a player), make sure some threshold is used. Once a player has moved this amount of pixels,
	-- whether that be in x or y direction, insert an entry in the history table.
	local threshold = self.size / 2
	if (math.abs(self.prevpos.x - self.pos.x) >= threshold) or (math.abs(self.prevpos.y - self.pos.y) >= threshold) then
		if self.counter < 80 then
			table.insert(self.history, { x = self.pos.x, y = self.pos.y})
		elseif self.counter > 85 then
			self.counter = 0
		end
		self.prevpos.x = self.pos.x
		self.prevpos.y = self.pos.y
		self.counter = self.counter + 1
	end
end

function Player:stop()
end

-- Moves the player left. Actually just rotates the orientation.
function Player:left()
	self.moveLeft = true
end

function Player:right()
	self.moveRight = true
end

function Player:stop()
	self.moveLeft = false
	self.moveRight = false
end

function Player:die()
	-- Don't die twice ;) I.e. return prematurely.
	if self.dead then
		return
	end

	-- TODO here
	self.soundDeath:play()

	self.dead = true
	self.deathParticles = ParticleGenerator.new(self.pos.x, self.pos.y)
	self.deathParticles.color = self.color
	self.deathParticles:init()
end

--[[
-- Checks if the current position of the player collides with the path of
-- the given otherPlayer by checking the otherPlayer's history table.
--]]
function Player:collidesWith(otherPlayer)
	-- only check if we are not dead yet.
	if self.dead then
		return
	end

	-- check if we are colliding with ourselves. If so, we lost. We subtract 10 from the
	-- history iteration, or else we'll be colliding with ourselves right away.
	if otherPlayer == self then
		for i = 1, #self.history - 10 do
			if util:isColliding(self.pos, self.size, self.history[i], self.size / 1.1) then
				return true
			end
		end
		return false
	end

	for i = 1, #otherPlayer.history do
		otherPos = {
			x = otherPlayer.history[i].x,
			y = otherPlayer.history[i].y
		}
		if util:isColliding(self.pos, self.size, otherPos, otherPlayer.size / 1.1) then
			return true
		end
	end
	return false
end

function Player:draw()
	love.graphics.setColor(self.color)
	for i = 1, #self.history do
		love.graphics.circle("fill", self.history[i].x, self.history[i].y, self.size)
	end


	love.graphics.circle("fill", self.pos.x, self.pos.y, self.size)
	local lolx = math.cos(self.rot) * self.size;
	local loly = math.sin(self.rot) * self.size;
	local endx, endy = self.pos.x + lolx, self.pos.y + loly

	love.graphics.setColor(255, 255, 255)

	--love.graphics.line(self.pos.x, self.pos.y, endx, endy)

	if self.dead then
		self.deathParticles:draw()
	end

	if globals.debug then
		love.graphics.setFont(globals.gameFont)
		love.graphics.setColor(255,255,255)
		local str = ""
		if self.dead then
			str = str .. "Kaputt!\n"
		end
		str = str ..
			self.name .. " (" .. math.floor(self.pos.x) .. ", " .. math.floor(self.pos.y) .. ")\n" ..
			"Trail size: " .. #self.history .. "\n" ..
			"Moving left: " .. tostring(self.moveLeft) .. "\n" ..
			"Moving right: " .. tostring(self.moveRight) .. "\n"

		love.graphics.printf(str, self.pos.x, self.pos.y, 150, "left")
	end
end

function Player:__tostring()
	return string.format("Player '%s'", self.name)
end
