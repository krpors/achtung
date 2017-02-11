Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)

	self.history = {}

	self.counter = 0

	self.moveLeft = false
	self.moveRight = false

	self.size = 5
	self.rot = 0
	self.velocity = 128

	self.pos = {
		x = 600,
		y = 300
	}

	self.prevpos = {
		x = self.pos.x,
		y = self.pos.y
	}

	return self
end

-- Player is always moving.
function Player:update(dt)
	if self.dead then
		return
	end
	if self.moveLeft then
		self.rot = self.rot - (dt * 2.5)
	end
	if self.moveRight then
		self.rot = self.rot + (dt * 2.5)
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

	-- To prevent lots of inserts into the history table (e.g. the paths we have followed as
	-- a player), make sure some threshold is used. Once a player has moved this amount of pixels,
	-- whether that be in x or y direction, insert an entry in the history table.
	local threshold = self.size / 2
	if (math.abs(self.prevpos.x - self.pos.x) >= threshold) or (math.abs(self.prevpos.y - self.pos.y) >= threshold) then
		if self.counter < 80 then
			table.insert(self.history, { x = self.pos.x, y = self.pos.y})
		elseif self.counter > 90 then
			self.counter = 0
		end
		self.prevpos.x = self.pos.x
		self.prevpos.y = self.pos.y
		self.counter = self.counter + 1
	end

	-- check if we are colliding with ourselves. If so, we lost.
	for i = 1, #self.history - 10 do
		if isColliding(self.pos.x, self.pos.y, self.size, self.history[i].x, self.history[i].y, self.size) then
			self.dead = true
		end
	end
end

--[[
-- Funky collision function to check circle intersections, using Pythagoras'
-- theorem (a² + b² = c²).
--]]
function isColliding(x1, y1, r1, x2, y2, r2)
	-- first get the difference 
	local dx = x2 - x1
	local dy = y2 - y1
	local dist = math.sqrt(dx * dx + dy * dy)
	return dist < (r1 + r2)
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
	for i = 1, #self.history do
		love.graphics.circle("fill", self.history[i].x, self.history[i].y, self.size)
	end


	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.size)
	local lolx = math.cos(self.rot) * self.size;
	local loly = math.sin(self.rot) * self.size;
	local endx, endy = self.pos.x + lolx, self.pos.y + loly

	love.graphics.setColor(255, 255, 255)

	love.graphics.line(self.pos.x, self.pos.y, endx, endy)

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Table size: " .. #self.history, 10, 10)
	love.graphics.print("(x, y) = (" .. self.pos.x .. "," .. self.pos.y .. ")", 10, 25)
end
