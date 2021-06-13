local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Respawn"
component.description = "Respawn a player."
component.command = "spawn"
component.tip = "[players]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {}

function component:Execute(ply, args)
	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)

	if players[1] then
		for _, pl in ipairs(players) do
			pl:Spawn()
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has respawned "})
		table.insert(announcement, {"red", galactic.messages:PlayersToString(players)})
		galactic.messages:Announce(unpack(announcement))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end
end

galactic:Register(component)