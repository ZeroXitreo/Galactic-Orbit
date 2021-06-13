local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Goto"
component.description = "Go to a player"
component.command = "goto"
component.tip = "[player]"
component.permission = component.title
component.category = "Teleportation"
component.guide = {}

function component:Execute(ply, args)

	local players = galactic.messages:GetPlayers(ply, args)

	if args[1] then
		if #players > 0 then
			table.RemoveByValue(players, ply)
			if #players > 0 then // There's still someone
				if #players == 1 then

					local message = {}
					table.insert(message, {"blue", ply:Nick()})
					table.insert(message, {"text", " went to "})
					table.insert(message, {"red", players[1]:Nick()})
					galactic.messages:Announce(unpack(message))
					
					galactic.bring:BringPlayers(players[1], {ply})

				else
					local message = {}
					table.insert(message, {"text", galactic.messages.question .. " "})
					table.insert(message, {"red", galactic.messages:PlayersToString(players, true)})
					table.insert(message, {"text", "?"})
					galactic.messages:Notify(ply, unpack(message))
				end
			else
				galactic.messages:Notify(ply, {"red", "You cannot go to yourself"})
			end
		else
			galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
		end
	else
		galactic.messages:Notify(ply, {"red", "Please provide who you wanna go to"})
	end

end

galactic:Register(component)
