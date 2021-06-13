local component = {}
component.dependencies = {"messages", "roleManager"}
component.title = "Slay"
component.description = "Slay players"
component.command = "slay"
component.tip = "[players]"
component.permission = component.title
component.category = "Punishment"
component.guide = {}

function component:Execute(ply, args)
	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)

	if players[1] then
		for _, pl in ipairs(players) do
			pl:Kill()
			pl:AddFrags(1)
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has slayed "})
		table.insert(announcement, {"red", galactic.messages:PlayersToString(players)})
		galactic.messages:Announce(unpack(announcement))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end
end

galactic:Register(component)