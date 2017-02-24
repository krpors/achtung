--[[
-- Visual effects helpers and such.
--]]

Shaker = {}
Shaker.__index = Shaker

function Shaker.new()
	local self = setmetatable({}, Shaker)

	self.shaking = false
	self.delta = 0
	self.y = 0

	return self
end

function Shaker:reset()
	print("Rsetting")
	self.shaking = false
	self.delta = 0
	self.y = 0
end

function Shaker:update(dt)
	if self.shaking then
		self.delta = self.delta + dt
		self.y = math.sin(109 * self.delta - self.delta) / self.delta
		if self.delta >= 2 then
			self:reset()
		end
	end
end

function Shaker:draw()
	if self.shaking then
		love.graphics.translate(self.y, -self.y)
	end
end

--[[
-- Background menu color cruft.
--]]
BgEffect = {}
BgEffect.__index = BgEffect

function BgEffect.new()
	local self = setmetatable({}, BgEffect)
	self.rotation = 0
	self.radius = 1024
	return self
end

function BgEffect:update(dt)
	-- Update the rotation of the arc. This is used so the arc is rotated very slightly
	-- each frame, to get a 'nice' visual effect (which is an opinion of course, but due
	-- to lack of other ideas,,,)
	self.rotation = self.rotation + dt / 30
end

function BgEffect:draw()
	-- We are drawing arcs here. We want 16 segments, so we define the step counter.
	-- We need to iterate through a whole circumference (2 * pi), and we're stepping
	-- twice the stepcount so we can create a 'gap' between each segment.
	--
	-- The first arc will be drawn in one color, and the 'gaps' are filled with arcs
	-- of a different color.
	local step = math.pi / 16
	for i = 0, 2*math.pi, step*2 do
		local r1 = i
		local r2 = i + step
		-- Draw the yellow arcs
		love.graphics.setColor(255, 255, 0, 20)
		love.graphics.arc("fill", 200, 200, self.radius, r1 + self.rotation, r2 + self.rotation, 20)
		-- Draw the red arcs
		love.graphics.setColor(255, 0, 0, 20)
		love.graphics.arc("fill", 200, 200, self.radius, r1 + self.rotation + step, r2 + self.rotation + step, 20)
	end

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 200, love.window.getWidth(), 400)
end
