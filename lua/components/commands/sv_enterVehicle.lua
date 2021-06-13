local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Enter vehicle"
component.description = "Force a player into a vehicle"
component.command = "enter"
component.tip = "[player]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {}

function component:Execute(ply, args)
	
	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)

	local vehicle = ply:GetEyeTrace().Entity
	
	if vehicle:IsVehicle() then
		if #players == 1 then
			players[1]:EnterVehicle(vehicle)
			local announcement = {}
			table.insert(announcement, {"blue", ply:Nick()})
			table.insert(announcement, {"text", " has forced "})
			table.insert(announcement, {"red", players[1]:Nick()})
			table.insert(announcement, {"text", " into a vehicle"})
			galactic.messages:Notify(ply, unpack(announcement))
		elseif #players > 0 then
			local announcement = {}
			table.insert(announcement, {"text", galactic.messages.question .. " "})
			table.insert(announcement, {"red", galactic.messages:PlayersToString(players, true)})
			table.insert(announcement, {"text", "?"})
			galactic.messages:Notify(ply, unpack(announcement))
		else
			galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
		end
	else
		galactic.messages:Notify(ply, {"red", "Please look at a vehicle"})
	end

end

galactic:Register(component)