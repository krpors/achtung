--[[
-- A menu class, for holding Buttons and the like.
--]]

Menu = {}
Menu.__index = Menu

function Menu.new()
	local self = setmetatable({}, Menu)

	self.buttons = {}
	self.width = 250
	self.pos = {
		x = (love.window.getWidth() / 2) - (self.width / 2),
		y = love.window.getHeight() / 2
	}

	return self
end

function Menu:addButton(button)
	local prevButton = self.buttons[#self.buttons]
	if prevButton == nil then
		button.selected = true
		button.pos.y = self.pos.y
	else
		button:align(prevButton)
	end
	table.insert(self.buttons, button)
end

--[[
-- Dumb circular list kind of implementation. If the last item is selected and
-- then the next one is selected, we rotate towards the beginning. Same thing
-- applies when we navigate before the first item.
--]]
function Menu:focus(diff)
	local first = self.buttons[1]
	local last = self.buttons[#self.buttons]

	for i = 1, #self.buttons do
		local btn = self.buttons[i]
		if btn.selected then
			btn.selected = false
			local nextbtn = self.buttons[i+diff]
			if nextbtn then
				nextbtn.selected = true
			else
				if diff <= -1 then last.selected = true end
				if diff >= 1 then first.selected = true end
			end
			return
		end
	end
end

function Menu:fireEvent()
	for k, v in ipairs(self.buttons) do
		if v.selected and v.action then
			v.action()
		end
	end
end

function Menu:update(dt)
	for k, v in ipairs(self.buttons) do
		v:update(dt)
	end
end

function Menu:draw()
	for k, v in ipairs(self.buttons) do
		v:draw()
	end
end

--[[=========================================================================]]--
--
Button = {}
Button.__index = Button

function Button.new(text)
	local self = setmetatable({}, Button)

	self.text = text
	self.selected = false
	self.pos = {
		x = 0,
		y = 0
	}

	self.width = 250
	self.height = 25
	self.action = nil

	return self
end


function Button:align(button)
	self.pos.y = button.pos.y + button.height + 10
end
function Button:update(dt)
end

function Button:draw()
	love.graphics.setFont(globals.gameFontLarge)
	if self.selected then
		love.graphics.setColor(255, 10, 100)
	else
		love.graphics.setColor(10, 255, 100)
	end

	local x = love.window.getWidth() / 2 - (self.width / 2)
	love.graphics.rectangle("line", x, self.pos.y, self.width, self.height)
	love.graphics.print(self.text, x + 5, self.pos.y + 3)
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
