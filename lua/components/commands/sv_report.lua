local component = {}
component.dependencies = {"messages", "messages", "data", "log"}
component.title = "Report"
component.description = "Report someone to the admins"
component.command = "report"
component.tip = "<player> <reason>"
component.permission = component.title

function component:Execute(ply, args)

	local arg1 = table.remove(args, 1)
	local players = galactic.messages:GetPlayers(ply, arg1)

	argConcat =  table.concat(args, " ")
	
	if arg1 and #players == 1 then
		if args[2] then
			str = string.format("[%s] %s reported %s with the reason: %s", os.date("%T"), galactic.log:PlayerLogStr(ply), galactic.log:PlayerLogStr(players[1]), argConcat)

			galactic.data:AppendText("reports", str .. "\n" )

			local announcement = {}
			table.insert(announcement, {"text", "You have reported "})
			table.insert(announcement, {"blue", players[1]:Nick()})
			table.insert(announcement, {"text", " with the following reason: "})
			table.insert(announcement, {"red", argConcat})
			galactic.messages:Notify(ply, unpack(announcement))
		else
			galactic.messages:Notify(ply, {"red", "No report specified"})
		end
	elseif arg1 and #players > 0 then
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
