local component = {}
component.dependencies = {"messages", "messages"}
component.title = "Private message"
component.description = "Send private message to someone"
component.command = "pm"
component.tip = "<player> <message>"
component.permission = component.title

function component:Execute(ply, args)

	local arg1 = table.remove(args, 1)
	local players = galactic.messages:GetPlayers(ply, arg1)

	argConcat =  table.concat(args, " ")

	if arg1 && #players == 1 then
		if argConcat and argConcat != "" then
			local announcement = {}
			table.insert(announcement, {"text", "To "})
			table.insert(announcement, {"yellow", players[1]:Nick()}) // team.GetColor( pl:Team() )
			table.insert(announcement, {"text", ": " .. argConcat})
			galactic.messages:Notify(ply, unpack(announcement))
			announcement = {}
			table.insert(announcement, {"text", "From "})
			table.insert(announcement, {"yellow", ply:Nick()}) // team.GetColor( pl:Team() )
			table.insert(announcement, {"text", ": " .. argConcat})
			galactic.messages:Notify(players[1], unpack(announcement))
		else
			galactic.messages:Notify(ply, {"red", "No message specified"})
		end
	elseif arg1 && #players > 0 then
		local announcement = {}
		table.insert(announcement, {"text", galactic.messages.question .. " "})
		table.insert(announcement, {"red", galactic.messages:PlayersToString(players, true)})
		table.insert(announcement, {"text", "?"})
		galactic.messages:Notify(ply, unpack(announcement))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end
	
end

galactic:Register(component)