Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)

	self.moveLeft = false
	self.moveRight = false

	-- Has the player just started? In that case, give the player some time to
	-- move around and give him or her some room to re-pick the direction.
	self.timeCounter = 0
	self.starting = true

	-- Initialize random seed to place the player at a random position and
	-- a random direction.
	math.randomseed(os.time())

	-- Thie history table, contains coordinates of all the positions the player
	-- has visited. This table is used for drawing the path the player has gone
	-- through, as well as collision detection with ourselves and other players.
	self.history = {}

	-- Counter is used to draw a gap in the player's path.
	self.counter = 0


	-- Color of the player as a table with r, g, b properties.
	self.color = {
		r = 255,
		g = 0,
		b = 255
	}
	-- Size of the player (radius)
	self.size = 5
	-- Rotation (direction) the player starts at.
	self.rot = math.random() * 2 * math.pi
	-- Speed
	self.velocity = 120

	-- The player's current (initial) position.
	self.pos = {
		x = math.random() * love.window.getWidth(),
		y = math.random() * love.window.getHeight()
	}

	-- Our previous position, to calculate how many pixels we diverged, to know
	-- whether we should insert something in the history table.
	self.prevpos = {
		x = self.pos.x,
		y = self.pos.y
	}

	return self
end

-- Player is always moving, until death.
function Player:update(dt)
	if self.dead then
		return
	end

	if self.moveLeft then
		self.rot = self.rot - 0.04
	end
	if self.moveRight then
		self.rot = self.rot + 0.04
	end

	local newx = self.pos.x + math.cos(self.rot) * (self.velocity * dt)
	local newy = self.pos.y + math.sin(self.rot) * (self.velocity * dt)

	self.pos.x = newx
	self.pos.y = newy

-- handle bounds of the screen.
	if newx - self.size > love.window.getWidth() then
		self.pos.x = 0 - self.size
	elseif newx + self.size < 0 then
		self.pos.x = love.window.getWidth() + self.size
	elseif newy - self.size > love.window.getHeight() then
		self.pos.y = 0 - self.size;
	elseif newy + self.size < 0 then
		self.pos.y = love.window.getHeight() + self.size
	end

	-- So, if the player is starting the game, give the player some time to move before
	-- we actually start. No collision detection is done (we're returning prematurely).
	-- By default, just use 5 seconds, which is just arbitrarily chosen.
	if self.starting then
		if self.timeCounter > 5 then
			self.starting = false
		end
		self.timeCounter = self.timeCounter + dt
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

	-- check if we are colliding with ourselves. If so, we lost.
	for i = 1, #self.history - 10 do
		-- we subtract 2 from the self.size to lower the preciseness a bit of collision.
		if isColliding(self.pos, self.size, self.history[i], self.size - 2) then
			self.dead = true
		end
	end
end

--[[
-- Funky collision function to check circle intersections, using Pythagoras'
-- theorem (a² + b² = c²). The parameters coord1 and coord2 are expected to be
-- tables with an x and y property, e.g. coord1.x and coord1.y.
--]]
function isColliding(coord1, radius1, coord2, radius2)
	local dx = coord2.x - coord1.x
	local dy = coord2.y - coord1.y
	local dist = math.sqrt(dx * dx + dy * dy)
	return dist < (radius1 + radius2)
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

function Player:draw()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b)
	for i = 1, #self.history do
		love.graphics.circle("fill", self.history[i].x, self.history[i].y, self.size)
	end


	love.graphics.circle("fill", self.pos.x, self.pos.y, self.size)
	local lolx = math.cos(self.rot) * self.size;
	local loly = math.sin(self.rot) * self.size;
	local endx, endy = self.pos.x + lolx, self.pos.y + loly

	love.graphics.setColor(255, 255, 255)

	love.graphics.line(self.pos.x, self.pos.y, endx, endy)

	love.graphics.setColor(255, 0, 0)
	love.graphics.print("Table size: " .. #self.history, 10, 10)
	love.graphics.print("(x, y) = (" .. self.pos.x .. "," .. self.pos.y .. ")", 10, 25)
	love.graphics.print("rot = " .. self.rot, 10, 35)
end
