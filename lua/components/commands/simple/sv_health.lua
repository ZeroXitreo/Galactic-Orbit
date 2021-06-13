local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Health"
component.description = "Set the health of players"
component.command = "hp"
component.tip = "[players|health] [health]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {{"Fragile", 1}, {"Squishy", 50}, {"Normal", 100}, {"Tough", 200}, {"Sponge", 500}}

function component:Execute(ply, args)
	local health = galactic.consoleManager:TryArgToNumber(args, #args, 100)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			pl:SetHealth(health)
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has set the health of "})
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		table.insert(announcement, {"text", " to "})
		table.insert(announcement, {"yellow", health})
		galactic.messages:Announce(unpack(announcement))
	end
end

galactic:Register(component)
