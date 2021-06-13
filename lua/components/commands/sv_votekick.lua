local component = {}
component.dependencies = {"messages", "messages", "orbitalVote", "orbitalKick"}
component.title = "Votekick"
component.description = "Kick a player by voting on it"
component.command = "votekick"
component.tip = "<player> [reason]"
component.permission = component.title
component.category = "Punishment"
component.guide = {{"No reason", ""}, "RDM", "Spamming", "Exploitation"}

function component:Execute(ply, args)

	local arg1 = table.remove(args, 1)
	local players = galactic.messages:GetPlayers(ply, arg1)
	players = ply:GetLower(players)

	argConcat =  table.concat(args, " ")

	if arg1 then
		if #players == 1 then
			local pl = players[1]

			print(pl:Nick())

			if argConcat and argConcat != "" then
				galactic.orbitalVote:CallVote(ply, {"Kick " .. pl:Nick() .. " with the reason: " .. argConcat .. "?", "Yes", "No"}, function(_, answers) self:Callback(answers, ply, pl) end)
			else
				galactic.orbitalVote:CallVote(ply, {"Kick " .. pl:Nick() .. "?", "Yes", "No"}, function(_, answers) self:Callback(answers, ply, pl) end)
			end

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
		galactic.messages:Notify(ply, {"red", "Please provide a player to votekick"})
	end

end

function component:Callback(answers, attacker, victim)
	local votedYes = answers[1]
	local votedNo = answers[2]
	local didNotVote = #player.GetHumans() - votedYes - votedNo

	if votedYes > votedNo then
		victim:Kick("You've been votekicked")
	end
end

galactic:Register(component)
