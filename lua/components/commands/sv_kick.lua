local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.namespace = "orbitalKick"
component.title = "Kick"
component.description = "Kick a player"
component.command = "kick"
component.tip = "<player> [reason]"
component.permission = component.title
component.category = "Punishment"
component.guide = {{"No reason", ""}, "RDM", "Spamming", "Exploitation"}

function component:Execute(ply, args)

	local arg1 = table.remove(args, 1)
	local players = galactic.messages:GetPlayers(ply, arg1)
	players = ply:GetLower(players)

	argConcat =  table.concat(args, " ")

	if arg1 then
		if #players == 1 then

			print(argConcat)
			if argConcat != "" then
				players[1]:Kick(argConcat)
			else
				players[1]:Kick("No reason specified")
			end

			local announcement = {}
			table.insert(announcement, {"blue", ply:Nick()})
			table.insert(announcement, {"text", " has kicked "})
			table.insert(announcement, {"red", players[1]:Nick()})
			if argConcat != "" then
				table.insert(announcement, {"text", " with the reason: "})
				table.insert(announcement, {"yellow", argConcat})
			end
			galactic.messages:Notify(ply, unpack(announcement))
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
		galactic.messages:Notify(ply, {"red", "Please provide a player to kick"})
	end

end

galactic:Register(component)
