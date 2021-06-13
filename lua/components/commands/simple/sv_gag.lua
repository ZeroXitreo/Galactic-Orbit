local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Gag"
component.description = "Gag players"
component.command = "gag"
component.tip = "[players|1/0] [1/0]"
component.permission = component.title
component.category = "Punishment"
component.guide = {{"Enable", 1}, {"Disable", 0}}

function component:Execute(ply, args)
	local enabled = galactic.consoleManager:TryArgToBool(args, #args, true)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			pl.isGagged = enabled
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		if enabled then
			table.insert(announcement, {"text", " has gagged "})
		else
			table.insert(announcement, {"text", " has ungagged "})
		end
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		galactic.messages:Announce(unpack(announcement))
	end
end

function component:PlayerSay(ply, msg)
	if ply.isGagged then
		return ""
	end
end

galactic:Register(component)
