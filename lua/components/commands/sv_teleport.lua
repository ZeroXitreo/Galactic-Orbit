local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Teleport"
component.description = "Teleport a player."
component.command = "tp"
component.tip = "[players]"
component.permission = component.title
component.category = "Teleportation"
component.guide = {}

function component:Execute(ply, args)

	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)



	if #players > 0 then

		local message = {}
		table.insert(message, {"blue", ply:Nick()})
		table.insert(message, {"text", " has teleported "})
		table.insert(message, {"red", galactic.messages:PlayersToString(players)})
		galactic.messages:Announce(unpack(message))

		// Move player
		local pl = players[1]

		if table.HasValue(players, ply) then
			pl = ply
		end

		local pos = self:GetSafeEyePosition(ply, players)
		pl:SetPos(pos)
		pl:SetLocalVelocity(Vector(0, 0, 0))
		table.RemoveByValue(players, pl)

		galactic.bring:BringPlayers(pl, players)

	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end

end

function component:GetSafeEyePosition(ply, extraFilter)

	local trace = ply:GetEyeTrace()
	local eyePos = ply:EyePos()
	local plyPos = ply:GetPos()
	local _, vec2 = ply:GetCollisionBounds()
	local tr = {}
	tr.filter = {}
	table.Merge(tr.filter, extraFilter)
	table.insert(tr.filter, ply)

	tr.start = trace.HitPos
	tr.endpos = trace.HitPos - Vector(0, 0, vec2.z)
	local trace = util.TraceLine(tr)

	local hitPosHeightAdjusted = trace.HitPos
	local eyePos = eyePos - Vector(0, 0, trace.Fraction * (eyePos.z - plyPos.z))


	// Box away from ground
	tr.start = trace.HitPos
	tr.endpos = eyePos
	local trace = util.TraceEntity(tr, ply)


	// Box towards player
	tr.start = trace.StartPos
	tr.endpos = eyePos
	local trace = util.TraceEntity(tr, ply)


	// Box towards endpoint
	tr.start = trace.HitPos
	tr.endpos = hitPosHeightAdjusted
	local trace = util.TraceEntity(tr, ply)

	return trace.HitPos

end

galactic:Register(component)