local component = {}
component.dependencies = {"ban", "banManager"}
component.title = "Unban"
component.description = "Unban a player."
component.command = "unban"
component.tip = "<steamid>"
component.permission = component.title

function component:Execute(ply, args)

	local players = galactic.messages:GetPlayerInformations(ply, args[1])

	if ply:IsPlayer() then
		players = galactic.ban:GetLower(ply:Info(), players)
	end

	if args[1] then
		if table.Count(players) == 1 then
			local playerId = table.GetKeys(players)[1]
			local playerInfo = players[playerId]

			galactic.banManager:Unban(playerId)

			local message = {}
			table.insert(message, {"blue", ply:Nick()})
			table.insert(message, {"text", " has unbanned "})
			table.insert(message, {"red", playerInfo.nick})
			galactic.messages:Notify(ply, unpack(message))
			
		elseif #players > 0 then
			local message = {}
			table.insert(message, {"text", galactic.messages.question .. " "})
			table.insert(message, {"red", galactic.messages:PlayersToString(players, true)})
			table.insert(message, {"text", "?"})
			galactic.messages:Notify(ply, unpack(message))
		else
			galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
		end
	else
		galactic.messages:Notify(ply, {"red", "Please provide a player to unban"})
	end

end

galactic:Register(component)