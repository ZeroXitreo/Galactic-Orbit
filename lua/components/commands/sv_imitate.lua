local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Imitate"
component.description = "Imitate a player"
component.command = "im"
component.tip = "<player> <message>"
component.permission = component.title

function component:Execute(ply, args)

	local playerArg = table.remove(args, 1)
	local players = galactic.messages:GetPlayers(ply, playerArg)
	players = ply:GetLower(players)

	argConcat =  table.concat(args, " ")

	if playerArg and playerArg != "" then
		if #players == 1 then
			local player = players[1]
			local announcement = {}
			table.insert(announcement, {player:Color(), player:Nick()})
			table.insert(announcement, {"text", ": " .. argConcat})
			galactic.messages:Announce(unpack(announcement))
		elseif #players > 0 then
			local announcement = {}
			table.insert(announcement, {"text", galactic.messages.question .. " "})
			table.insert(announcement, {"red", galactic.messages:PlayersToString(players, true)})
			table.insert(announcement, {"text", "?"})
			galactic.messages:Notify(ply, unpack(announcement))
		else
			galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
		end
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end

end

galactic:Register(component)