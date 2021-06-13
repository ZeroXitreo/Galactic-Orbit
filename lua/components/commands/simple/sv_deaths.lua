local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Deaths"
component.description = "Set the deaths of players"
component.command = "deaths"
component.tip = "[players|deaths] [deaths]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {}

function component:Execute(ply, args)
	local deaths = galactic.consoleManager:TryArgToNumber(args, #args, 0)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			pl:SetDeaths(deaths)
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has set the deaths of "})
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		table.insert(announcement, {"text", " to "})
		table.insert(announcement, {"yellow", deaths})
		galactic.messages:Announce(unpack(announcement))
	end
end

galactic:Register(component)
