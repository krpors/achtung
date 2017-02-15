require "util"

ParticleGenerator = {}
ParticleGenerator.__index = ParticleGenerator

function ParticleGenerator.new()
	local self = setmetatable({}, ParticleGenerator)

	-- Spawn point, or just the origin of the generator
	self.pos = {
		x = 200,
		y = 200
	}

	self.particles = {}
	self.particleCount = 20

	return self
end

function ParticleGenerator:init()
	self.particleCount = 20
	self.particles = {}

	for i = 1, self.particleCount do
		local maxlife = love.math.random() * 2
		local p = {
			x       = self.pos.x,
			y       = self.pos.y,
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
			if p.life <= 0 then
				print("particle " .. i .. " died")
				self.particleCount = self.particleCount - 1
			end
		end
	end
end

function ParticleGenerator:draw()
	for i = 1, #self.particles do
		local p = self.particles[i]
		if p and p.life > 0 then
			local col = p.life / p.maxlife * 255
			love.graphics.setColor(255, col, 0)
			love.graphics.circle("fill", p.x, p.y, 2)
		end
	end
end
