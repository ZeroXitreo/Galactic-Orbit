local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.namespace = "bring"
component.title = "Bring"
component.description = "Brings players to you"
component.command = "bring"
component.tip = "[players]"
component.permission = component.title
component.category = "Teleportation"
component.guide = {}

function component:Execute(ply, args)

	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)

	if #players > 0 then
		table.RemoveByValue(players, ply)
		if #players > 0 then

			local message = {}
			table.insert(message, {"blue", ply:Nick()})
			table.insert(message, {"text", " has brought "})
			table.insert(message, {"red", galactic.messages:PlayersToString(players)})
			table.insert(message, {"text", " to them"})
			galactic.messages:Announce(unpack(message))

			component:BringPlayers(ply, players)

		else
			galactic.messages:Notify(ply, {"red", "You cannot bring yourself"})
		end
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end

end

function component:BringPlayers(ply, plys)

	local nextAdjacentPlayers = {ply}

	while #plys > 0 and #nextAdjacentPlayers > 0 do
		nextAdjacentPlayers = self:GetAdjacentFromAdjacent(nextAdjacentPlayers, plys)
	end

	if #plys > 0 then // Didn't get to place all players

		// Pop a random player
		local pl = table.remove(plys, math.random(#plys))

		// Move player
		local vec, vec2 = ply:GetCollisionBounds()
		pl:SetPos(ply:GetPos() + Vector(0, 0, vec2.z + 1))
		pl:SetLocalVelocity(Vector(0, 0, 0))

		// Start over
		self:BringPlayers(pl, plys)

	end

end

function component:GetAdjacentFromAdjacent(adjPlys, plys)

	local nextAdjacentPlayers = {}

	for _, adjPly in ipairs(adjPlys) do
		// Place players and get adjacent
		table.Add(nextAdjacentPlayers, self:PlacePlayersAroundPlayerAndGetAdjacent(adjPly, plys))
	end

	return nextAdjacentPlayers

end

// Updates plys list, removes already placed players
function component:PlacePlayersAroundPlayerAndGetAdjacent(ply, plys)

	local adjPos = self:GetAdjacentPositions(ply, plys)
	local adjPlys = {}

	for i = #adjPos, 1, -1 do
		if #plys > 0 then

			// Pick a position and pop
			local pos = table.remove(adjPos, math.random(#adjPos))

			// Pick a player and pop
			local pl = table.remove(plys, math.random(#plys))

			// Move player
			pl:SetPos(pos)
			pl:SetLocalVelocity(Vector(0, 0, 0))

			// Insert player into adjacent players
			table.insert(adjPlys, pl)

		end
	end

	return adjPlys

end

function component:GetAdjacentPositions(ply, extraFilter)
	local vec, vec2 = ply:GetCollisionBounds()
	local eyePos = ply:EyePos()
	local plyPos = ply:GetPos()
	local resolution = 8
	local distance = 64
	local tr = {}
	tr.filter = {}
	table.Merge(tr.filter, extraFilter)
	table.insert(tr.filter, ply)
	local spawnTbl = {}

	for i = 1, resolution do

		local b = (vec2.x + vec2.y)
		local degrees = i / resolution * 360
		local alpha = degrees
		local switch = 22.5

		while alpha > 45 do
			alpha = alpha - 45
			switch = -switch
		end

		local c = b / math.cos(math.rad(alpha - 22.5 + switch))



		tr.start = plyPos + Angle(0, degrees, 0):Forward() * c
		tr.endpos = plyPos + Angle(0, degrees, 0):Forward() * distance

		local trace = util.TraceEntity(tr, ply)

		local col = Color(0, 255, 0)

		if trace.Hit then
			col = Color(255, 255, 0)
		end

		if not trace.StartSolid then
			table.insert(spawnTbl, trace.HitPos)
		end
	end

	return spawnTbl
end

galactic:Register(component)