local component = {}
component.title = "Strip Weapons"
component.description = "Strip a player's weapons."
component.command = "strip"
component.tip = "[players]"
component.permission = component.title
component.category = "Punishment"
component.guide = {}

function component:Execute(ply, args)
	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)

	if players[1] then
		for _, pl in ipairs(players) do
			pl:StripWeapons()
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has stripped "})
		table.insert(announcement, {"red", galactic.messages:PlayersToString(players)})
		table.insert(announcement, {"text", " of weapons"})
		galactic.messages:Announce(unpack(announcement))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end
end

galactic:Register(component)