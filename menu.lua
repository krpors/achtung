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

function Menu:selectFirst()
	for k, v in ipairs(self.buttons) do
		v.selected = false
	end

	self.buttons[1].selected = true
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
	self.pos = {
		x = (love.window.getWidth() / 2) - (self.width / 2),
		y = love.window.getHeight() / 2
	}

	for k, v in ipairs(self.buttons) do
		v:update(dt)
	end
end

function Menu:draw()
	-- draw background under buttons
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle("fill", self.pos.x - 30, 0, self.width + 60, love.window.getHeight())

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
	local x = love.window.getWidth() / 2 - (self.width / 2)

	love.graphics.setFont(globals.gameFontLarge)

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", x, self.pos.y, self.width, self.height)

	if self.selected then
		love.graphics.setColor(255, 0, 0)
	else
		love.graphics.setColor(255, 255, 255)
	end

	love.graphics.rectangle("line", x, self.pos.y, self.width, self.height)
	love.graphics.print(self.text, x + 5, self.pos.y + 3)
end

--[[=========================================================================]]--

Scoreboard = {}
Scoreboard.__index = Scoreboard

function Scoreboard.new()
	local self = setmetatable({}, Scoreboard)

	self.height = 100
	self.players = nil

	return self
end

function Scoreboard:draw()
	local w = globals.playableArea.width
	local h = globals.playableArea.height

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, h, w, h)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(0, h, love.window.getWidth(), h)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(0, h+3, love.window.getWidth(), h+3)

	love.graphics.setFont(globals.gameFontLarge)

	-- For each player, draw the score.
	for k, v in ipairs(self.players) do
		local posx = w / 4 * (k - 1)
		local w2 = w / 4

		local color = { v.color[1] / 4, v.color[2] / 4, v.color[3] / 4 }
		love.graphics.setColor(color)
		love.graphics.rectangle("fill", posx, h, w2, h)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(v.name .. ": " .. v.score, posx + 10 + 1, h+16 + 1)
		love.graphics.setColor(v.color)
		love.graphics.print(v.name .. ": " .. v.score, posx + 10, h+16)

		if v.dead then
		end
	end
end

function Scoreboard:update(dt)

end
