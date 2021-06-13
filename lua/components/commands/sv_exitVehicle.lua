local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Exit vehicle"
component.description = "Force a player out of their vehicle"
component.command = "exit"
component.tip = "[player]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {}

function component:Execute(ply, args)
	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)
	local playersInVehicle = {}
	for _,pl in ipairs(players) do
		if pl:InVehicle() then
			table.insert(playersInVehicle, pl)
		end
	end

	if #playersInVehicle > 0 then
		for _,pl in ipairs(playersInVehicle) do
			pl:ExitVehicle()
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has forced "})
		table.insert(announcement, {"red", galactic.messages:PlayersToString(playersInVehicle)})
		table.insert(announcement, {"text", " out of their vehicle"})
		galactic.messages:Notify(ply, unpack(announcement))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end	
end

galactic:Register(component)
