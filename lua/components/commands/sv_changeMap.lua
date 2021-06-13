local component = {}
component.dependencies = {"messages"}
component.title = "Change map"
component.description = "Change the map"
component.command = "map"
component.tip = "<map>"
component.permission = component.title

function component:Execute(ply, args)

	argConcat =  table.concat(args, " ")

	if args[1] then
		if file.Exists("maps/" .. argConcat .. ".bsp", "GAME") then
			local announcement = {}
			table.insert(announcement, {"blue", ply:Nick()})
			table.insert(announcement, {"text", " has changed the map to "})
			table.insert(announcement, {"red", argConcat})
			galactic.messages:Announce(unpack(announcement))
			
			RunConsoleCommand("changelevel", argConcat)
		else
			galactic.messages:Notify(ply, {"red", "Couldn't find " .. argConcat})
		end
	else
		galactic.messages:Notify(ply, {"red", "Please specify a map"})
	end
	
end

galactic:Register(component)