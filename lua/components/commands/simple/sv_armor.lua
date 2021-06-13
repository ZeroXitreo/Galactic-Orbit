local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Armor"
component.description = "Set the armor of players"
component.command = "armor"
component.tip = "[players|armor] [armor]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {{"Fragile", 1}, {"Squishy", 50}, {"Normal", 100}, {"Tough", 200}, {"Sponge", 500}}

function component:Execute(ply, args)
	local armor = galactic.consoleManager:TryArgToNumber(args, #args, 100)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			pl:SetArmor(armor)
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has set the armor of "})
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		table.insert(announcement, {"text", " to "})
		table.insert(announcement, {"yellow", armor})
		galactic.messages:Announce(unpack(announcement))
	end
end

galactic:Register(component)
