local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Arm"
component.description = "Arm players with the default loadout"
component.command = "arm"
component.tip = "[players]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {}

function component:Execute(ply, args)
	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)
	
	if #players > 0 then
		for _, pl in ipairs(players) do
			GAMEMODE:PlayerLoadout(pl)
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has armed "})
		table.insert(announcement, {"red", galactic.messages:PlayersToString(players)})
		galactic.messages:Announce(unpack(announcement))


	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end
end

galactic:Register(component)