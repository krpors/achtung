require "util"

ParticleGenerator = {}
ParticleGenerator.__index = ParticleGenerator

function ParticleGenerator.new(origin_x, origin_y)
	local self = setmetatable({}, ParticleGenerator)

	-- Spawn point, or just the origin of the generator
	self.pos = {
		x = origin_x,
		y = origin_y
	}

	self.particles = {}
	self.particleCount = 40
	self.color = { 255, 0, 0, 255 }

	return self
end

--[[
-- Initializes the particle generator with all the parameters involved.
--]]
function ParticleGenerator:init()
	self.particles = {}

	for i = 1, self.particleCount do
		local maxlife = love.math.random() * 2
		local p = {
			x         = self.pos.x,
			y         = self.pos.y,
			color     = self.color,
			radius    = 10,
			maxradius = 10,
			dx        = love.math.random(-1000, 1000) / 1000,
			dy        = love.math.random(-1000, 1000) / 1000,
			life      = maxlife, -- life in seconds
			maxlife   = maxlife  -- life maximum
		}
		table.insert(self.particles, p)
	end
end

--[[
-- Resets a particle's parameters.
--]]
function ParticleGenerator:resetParticle(particle)
	local p = {
		x         = self.pos.x,
		y         = self.pos.y,
		color     = self.color,
		radius    = 10,
		maxradius = 10,
		dx        = love.math.random(-1000, 1000) / 1000,
		dy        = love.math.random(-1000, 1000) / 1000,
		life      = maxlife, -- life in seconds
		maxlife   = maxlife  -- life maximum
	}
end

-- ParticleGenerator is always moving, until death.
function ParticleGenerator:update(dt)
	for i = 1, #self.particles do
		local p = self.particles[i]
		if p and p.life >= 0 then
			p.x = p.x + p.dx * dt * 80
			p.y = p.y + p.dy * dt * 80
			p.life = p.life - dt
			-- Change the radius. The radius must decline to zero in proportion
			-- to the lifetime of the particle. Meaning, if the lifetime of the
			-- particle is 4.8 seconds, after 4.8 seconds we must have reached
			-- a radius of 0. We do that by just setting by calculating the
			-- percentage of the lifetime, multiplied by the original max radius.
			p.radius = p.maxradius * (p.life / p.maxlife)
		elseif p.life < 0 then
			p.life = p.maxlife
			p.x = self.pos.x
			p.y = self.pos.y
			p.radius = p.maxradius
		end
	end
end

function ParticleGenerator:draw()
	for i = 1, #self.particles do
		local p = self.particles[i]
		if p and p.life > 0 then
			love.graphics.setColor(p.color)
			love.graphics.circle("fill", p.x, p.y, p.radius)
		end
	end
end
