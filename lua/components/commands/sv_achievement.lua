local component = {}
component.dependencies = {"messages", "consoleManager"}
component.title = "Achievement"
component.description = "Make someone think they earned an achievement"
component.command = "ach"
component.tip = "<players> <achievement>"
component.permission = component.title
component.category = "Manipulation"
component.guide = {"Secret Phrase", "Play Singleplayer", "Play Multiplayer", "Startup Millenium", "Map Loader", "Play Around", "War Zone", "Friendly", "Yes, I am the real garry!", "Marathon", "Half Marathon", "One Day", "One Week", "One Month", "Addict", "Innocent Bystander", "Ball Eater", "Creator", "Popper", "Destroyer", "Menu User", "Bad Coder", "Procreator", "Dollhouse", "Bad Friend", "10 Thumbs", "100 Thumbs", "1000 Thumbs", "Mega Upload"}

function component:Execute(ply, args)
	local players = galactic.consoleManager:GetPlayers(ply, table.remove(args, 1))
	if players then
		local message = galactic.consoleManager:RequestData(ply, table.concat(args, " "), "achievement", "an")
		if message then
			for _, pl in ipairs(players) do
				local announcement = {}
				table.insert(announcement, {team.GetColor(pl:Team()), pl:Nick()})
				table.insert(announcement, {Color(255, 255, 255), " earned the achievement "})
				table.insert(announcement, {Color(255, 201, 0), message})
				galactic.messages:Announce(unpack(announcement))
			end
		end
	end
end

galactic:Register(component)
