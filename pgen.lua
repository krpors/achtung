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
		local maxlife = love.math.random() * 5
		local p = {
			x       = self.pos.x,
			y       = self.pos.y,
			color   = self.color,
			radius  = 20,
			dx      = love.math.random(-1000, 1000) / 1000,
			dy      = love.math.random(-1000, 1000) / 1000,
			maxlife = maxlife,
			life    = maxlife
		}
		table.insert(self.particles, p)
	end
end

-- ParticleGenerator is always moving, until death.
function ParticleGenerator:update(dt)
	for i = 1, #self.particles do
		local p = self.particles[i]
		if p and p.life >= 0 then
			p.x = p.x + p.dx * dt * 80
			p.y = p.y + p.dy * dt * 80
			p.life = p.life - dt
			p.radius = math.max(p.radius - (dt * p.maxlife * 40), 0)
			p.color[4] = math.max(p.color[4] - (dt * 10), 0)
		end
	end
end

function ParticleGenerator:draw()
	for i = 1, #self.particles do
		local p = self.particles[i]
		if p and p.life > 0 then
			--local col = p.life / p.maxlife * 255
			--love.graphics.setColor(255, col, 0)
			love.graphics.setColor(p.color)
			love.graphics.circle("fill", p.x, p.y, p.radius)
		end
	end
end
