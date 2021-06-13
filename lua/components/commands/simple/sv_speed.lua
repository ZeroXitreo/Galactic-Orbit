local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Speed"
component.description = "Set the speed of players"
component.command = "speed"
component.tip = "[players|speed] [speed]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {1, 100, 250, 500, 1000}

function component:Execute(ply, args)
	local speed = galactic.consoleManager:TryArgToNumber(args, #args, 250)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			GAMEMODE:SetPlayerSpeed(pl, speed, speed * 2)
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has set the speed of "})
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		table.insert(announcement, {"text", " to "})
		table.insert(announcement, {"yellow", speed})
		galactic.messages:Announce(unpack(announcement))
	end
end

galactic:Register(component)
