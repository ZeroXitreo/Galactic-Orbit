local component = {}
component.dependencies = {"messages"}
component.title = "Change gamemode"
component.description = "Change the gamemode"
component.command = "gamemode"
component.tip = "<gamemode>"
component.permission = component.title

function component:Execute(ply, args)

	argConcat =  table.concat(args, " ")

	if args[1] then
		if file.Exists("gamemodes/" .. argConcat, "GAME") then
			local announcement = {}
			table.insert(announcement, {"blue", ply:Nick()})
			table.insert(announcement, {"text", " has changed the gamemode to "})
			table.insert(announcement, {"red", argConcat})
			galactic.messages:Announce(unpack(announcement))
			
			RunConsoleCommand("gamemode", argConcat)
		else
			galactic.messages:Notify(ply, {"red", "Couldn't find " .. argConcat})
		end
	else
		galactic.messages:Notify(ply, {"red", "Please specify a gamemode"})
	end
	
end

galactic:Register(component)