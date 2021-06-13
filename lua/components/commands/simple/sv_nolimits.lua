local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "No Limits"
component.description = "Disable/Enable spawn limits for players"
component.command = "nolimits"
component.tip = "[players|1/0] [1/0]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {{"Enable", 1}, {"Disable", 0}}

function component:Execute(ply, args)
	local enabled = galactic.consoleManager:TryArgToNumber(args, #args, true)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			pl.hasNoLimits = enabled
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		if enabled then
			table.insert(announcement, {"text", " has disabled limits for "})
		else
			table.insert(announcement, {"text", " has enabled limits for "})
		end
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		galactic.messages:Announce(unpack(announcement))
	end
end

galactic:Register(component)
