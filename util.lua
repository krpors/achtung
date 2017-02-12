util = {}

--[[
-- Funky collision function to check circle intersections, using Pythagoras'
-- theorem (a² + b² = c²). The parameters coord1 and coord2 are expected to be
-- tables with an x and y property, e.g. coord1.x and coord1.y.
--]]
function util:isColliding(coord1, radius1, coord2, radius2)
	local dx = coord2.x - coord1.x
	local dy = coord2.y - coord1.y
	local dist = math.sqrt(dx * dx + dy * dy)
	return dist < (radius1 + radius2)
end


