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
	self.rotation = self.rotation + dt / 20
end

function BgEffect:draw()
	-- We are drawing arcs here. We want 16 segments, so we define the step counter.
	-- We need to iterate through a whole circumference (2 * pi), and we're stepping
	-- twice the stepcount so we can create a 'gap' between each segment.
	--
	-- The first arc will be drawn in one color, and the 'gaps' are filled with arcs
	-- of a different color.
	local step = math.pi / 16

	local cx = love.window.getWidth() / 2
	local cy = love.window.getHeight() / 2

	for i = 0, 2*math.pi, step*2 do
		local r1 = i
		local r2 = i + step
		-- Draw the yellow arcs
		love.graphics.setColor(255, 255, 255, 90)
		love.graphics.arc("fill", cx, cy, self.radius, r1 + self.rotation, r2 + self.rotation, 20)
		-- Draw the red arcs
		love.graphics.setColor(255, 0, 0, 90)
		love.graphics.arc("fill", cx+5, cy+5, self.radius, r1 + self.rotation + step, r2 + self.rotation + step, 20)
	end

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 200, love.window.getWidth(), 400)
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
		"\".....\"\n - Gordon Freeman",
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
	love.graphics.setFont(globals.gameFont)
	love.graphics.setColor(225, 225, self.color)
	love.graphics.printf(self.text, 400, 300, 300, "center", -0.2, self.scaling, self.scaling, 300 / 2)
end

