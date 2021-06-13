local component = {}
component.dependencies = {"consoleManager", "messages"}
component.title = "Give weapon"
component.description = "Give a specific weapon to players"
component.command = "give"
component.tip = "<players|weapon> [weapon]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {{"Crowbar", "weapon_crowbar"}, {"Gravity gun", "weapon_physcannon"}, {"Physics gun", "weapon_physgun"}, {".357 Magnum", "weapon_357"}, {"SMG", "weapon_smg1"}, {"Pulse-rifle", "weapon_ar2"}, {"Shotgun", "weapon_shotgun"}, {"Crossbow", "weapon_crossbow"}, {"Grenade", "weapon_frag"}, {"RPG", "weapon_rpg"}}

function component:Execute(ply, args)
	local weapon = galactic.consoleManager:RequestData(ply, table.remove(args, #args), "weapon", "a")
	if weapon then
		weapon, _ = galactic.consoleManager:ListFind(ply, list.Get("Weapon"), function(k, v) return weapon == k end, weapon)
		if weapon then
			local players = galactic.consoleManager:GetLowerPlayers(ply, args)
			if players then

				for _, pl in ipairs(players) do
					pl:Give(weapon)
				end

				local announcement = {}
				table.insert(announcement, {"blue", ply:Nick()})
				table.insert(announcement, {"text", " has given "})
				table.insert(announcement, {"red", weapon})
				table.insert(announcement, {"text", " to "})
				galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
				galactic.messages:Announce(unpack(announcement))
			end
		end
	end
end

galactic:Register(component)
