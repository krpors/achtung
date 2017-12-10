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
		self.y = math.sin(100 * self.delta - self.delta) / self.delta
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
	self.radius = 0
	self:init()
	return self
end

function BgEffect:init()
	self.circlecount = 50
	self.circles = {}

	for i = 1, self.circlecount do
		local c = {}
		self:resetCircle(c)
		table.insert(self.circles, c)
	end
end

function BgEffect:resetCircle(c)
	c.radius = 1
	c.life = love.math.random() * 40
	c.x = love.math.random() * love.window.getWidth()
	c.y = love.math.random() * love.window.getWidth()
	c.color = {
		love.math.random() * 255,
		love.math.random() * 255,
		love.math.random() * 255
	}
end

function BgEffect:update(dt)
	for i, c in ipairs(self.circles) do
		c.radius = c.radius + 1 * dt * love.math.random() * 18
		c.x = c.x + love.math.random(-1, 1)
		c.y = c.y + love.math.random(-1, 1)
		if c.radius > c.life then
			self:resetCircle(c)
		end
	end
end

function BgEffect:draw()
	for i, c in ipairs(self.circles) do
		love.graphics.setColor(c.color)
		love.graphics.circle("fill", c.x, c.y, c.radius)
	end
end

--[[=========================================================================]]--

--[[
-- BobbingText is just a simple text, bobbing up and down (i.e. scaling). I stole
-- the idea from Minecraft tbh. I found it fun to implement it so here it goes.
--]]
BobbingText = {}
BobbingText.__index = BobbingText

function BobbingText.new()
	local self = setmetatable({}, BobbingText)

	self.counter = 0
	self.scaling = 1
	self.color = 0

	self.texts = {
		"The newt bites you. You die...",
		"Uaaaaarrrrrrrghhh!!!!",
		"/r/love2d",
		"Hi thar ^_^",
		"Segmentation fault",
		"Core dumped.",
		"You've got mail. Check your inbox!",
		"Blue screen of death imminent... Or Linux?",
		"Grab them by the pony.",
		"e = 2.7182818284590452353602874...",
		"This game is bugfree!",
		"Use the source, Luke.",
		"i = 0x5f3759df - (i >> 1); // what the f?",
		"We have broken SHA-1 in practice.",
		"When in doubt, print it out!",
		"Bogosort is the best sort!",
		"Fatal Error: NO_ERROR",
		"It's true! It's fantastic. It's great!",
		"Random number selected: 42",
		"Tabs for indentation, spaces for alignment!",
		"Kernel panic!",
		"Click here to download more RAM!",
		"tan(x) = sin(x)/cos(x)",
		"I have a theoretical degree in physics.",
		"Save net neutrality!",
		"Squad CoverUp - Writing Tomorrow's Legacy!",
		"Justice is right, justice is wrong, justice is done!",
		"Scrum is overrated."
	}

	math.randomseed(os.time())
	self:reset()

	return self
end

function BobbingText:reset()
	self.text = self.texts[math.random(#self.texts)]
end

function BobbingText:update(dt)
	self.counter = self.counter + dt
	self.scaling = math.abs(0.5 * math.sin(4 * self.counter)) + 2
	self.color = math.abs(255 * math.sin(0.2 * self.counter))
end

function BobbingText:draw()
	love.graphics.setColor(50, 20, self.color)
	love.graphics.rotate(-0.2)
	love.graphics.rectangle("fill", -100, 350, love.window.getWidth() + 300, 70)

	love.graphics.rotate(0.2)
	love.graphics.setFont(globals.gameFont)
	love.graphics.setColor(225, 225, self.color)
	love.graphics.printf(self.text, 400, 300, 300, "center", -0.2, self.scaling, self.scaling, 300 / 2)
end

