local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "God mode"
component.description = "Enable god mode for players"
component.command = "god"
component.tip = "[players|1/0] [1/0]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {{"Enable", 1}, {"Disable", 0}}

function component:Execute(ply, args)
	local enabled = galactic.consoleManager:TryArgToBool(args, #args, true)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			if enabled then
				pl:GodEnable()
			else
				pl:GodDisable()
			end
			pl.isInGodMode = enabled
		end

		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", string.format(" has %s god mode for ", enabled and "enabled" or "disabled")})
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		galactic.messages:Announce(unpack(announcement))
	end
end

function component:PlayerSpawn(ply)
	if ply.isInGodMode then
		ply:GodEnable()
	end
end

galactic:Register(component)
