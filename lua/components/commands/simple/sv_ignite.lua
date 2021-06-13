local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Ignite"
component.description = "Ignite players"
component.command = "ignite"
component.tip = "[players|1/0] [1/0]"
component.permission = component.title
component.category = "Punishment"
component.guide = {{"Enable", 1}, {"Disable", 0}}

function component:Execute(ply, args)
	local enabled = galactic.consoleManager:TryArgToBool(args, #args, true)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			if enabled then
				pl:Ignite(9999999)
			else
				pl:Extinguish()
			end
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		if enabled then
			table.insert(announcement, {"text", " has ignited "})
		else
			table.insert(announcement, {"text", " has extinguished "})
		end
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		galactic.messages:Announce(unpack(announcement))
	end
end

function component:PlayerDeath(ply)
	if ply:IsOnFire() then
		ply:Extinguish()
	end
end

function component:Move(ply)
	if ply:IsOnFire() and ply:WaterLevel() == 3 then
		ply:Extinguish()
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has extinguished themself in water"})
		galactic.messages:Announce(unpack(announcement))
	end
end

galactic:Register(component)
