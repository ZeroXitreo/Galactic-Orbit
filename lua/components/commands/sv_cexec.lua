local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Player command execute"
component.description = "Execute a client command on players"
component.command = "cexec"
component.tip = "<player> <cmd>"
component.permission = component.title

function component:Execute(ply, args)
	local players = galactic.messages:GetPlayers(ply, table.remove(args, 1))
	players = ply:GetLower(players)

	argConcat =  table.concat(args, " ")

	if #players == 1 then
		if argConcat != "" then
			players[1]:ConCommand(argConcat)
		else
			galactic.messages:Notify(ply, {"red", "No message specified"})
		end
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end
end

galactic:Register(component)
