require "player"

local delta = 0
local player1
local player2

function love.load()
	player1 = Player.new()
	player1.color = { r = 122, g = 222, b= 222 }
	player2 = Player.new()
end

function love.conf(t)
end

function love.update(dt)
	delta = delta + dt
	if delta >= 0.2 then
		delta = 0
	end
	player1:update(dt)
	player2:update(dt)

	if player1:collidesWith(player2) then
		player1:die()
	end
	if player2:collidesWith(player1) then
		player2:die()
	end
end

function love.draw()
	player1:draw()
	player2:draw()
end
function love.keypressed(key)
	if key == 'escape' then love.event.quit()
	elseif key == 'left' then player1:left()
	elseif key == 'right' then player1:right()
	elseif key == "a" then player2:left()
	elseif key == "s" then player2:right()
	end
end

function love.keyreleased(key)
	if key == 'left' or key == 'right' then
		player1:stop()
	end
	if key == "a" or key == "s" then
		player2:stop()
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


