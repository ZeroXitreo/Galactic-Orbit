local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Spectate"
component.description = "Spectate a player"
component.command = "spec"
component.tip = "<player>"
component.permission = component.title

function component:Execute(ply, args)

	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)
	
	if #args > 0 then
		if #players > 0 then
			if #players == 1 then
				if players[1] != ply then
					ply.isSpectating = true
					
					ply:Spectate(OBS_MODE_CHASE)
					ply:SpectateEntity(players[1])
					//ply:SetMoveType(MOVETYPE_OBSERVER)
					
					ply:StripWeapons()
				else
					galactic.messages:Notify(ply, {"red", "You cannot spectate yourself"})
				end
			else
				local message = {}
				table.insert(message, {"text", galactic.messages.question .. " "})
				table.insert(message, {"red", galactic.messages:PlayersToString(players, true)})
				table.insert(message, {"text", "?"})
				galactic.messages:Notify(ply, unpack(message))
			end
		else
			galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
		end
	elseif ply.isSpectating then
		ply.isSpectating = false

		ply:Spectate(OBS_MODE_NONE)
		ply:UnSpectate()
		//ply:SetMoveType(MOVETYPE_WALK)
		ply:SetLocalVelocity(Vector(0, 0, 0))
		
		hook.Run("PlayerLoadout", ply)
	end
end

galactic:Register(component)