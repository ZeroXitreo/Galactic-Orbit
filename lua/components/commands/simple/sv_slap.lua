local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Slap"
component.description = "Slap players"
component.command = "slap"
component.tip = "[players|damage] [damage]"
component.permission = component.title
component.category = "Punishment"
component.guide = {{"Free of charge", 0}, 1, 10, 25, 50, 100}

function component:Execute(ply, args)
	local damage = galactic.consoleManager:TryArgToNumber(args, #args, 10)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			pl:SetHealth(pl:Health() - damage)
			pl:ViewPunch(Angle(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(-10, 10)))
			if pl:Health() <= 0 then
				pl:Kill()
			end
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has set the frags of "})
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		table.insert(announcement, {"text", " with "})
		table.insert(announcement, {"yellow", damage})
		table.insert(announcement, {"text", " damage"})
		galactic.messages:Announce(unpack(announcement))
	end
end

galactic:Register(component)
