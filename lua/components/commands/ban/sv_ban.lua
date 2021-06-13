local component = {}
component.dependencies = {"messages", "roleManager", "banManager"}
component.namespace = "ban"
component.title = "Ban"
component.description = "Ban a player"
component.command = "ban"
component.tip = "<name/steamid> [time=5] [reason]"
component.permission = component.title
component.category = "Punishment"
component.guide = {{"30 minutes", 30}, {"1 day", 1440}, {"1 week", 10080}, {"Permanently", 0}}

function component:Execute(ply, args)

	// Check for live players
	local players = galactic.messages:GetPlayers(ply, args[1])

	if #players == 0 then
		players = galactic.messages:GetPlayerInformations(ply, args[1])
	else
		local tempPlayers = {}

		for i, pl in ipairs(players) do
			tempPlayers[pl:Identifier()] = pl:Info()
		end

		players = tempPlayers
	end

	if args[1] then
		table.remove(args, 1)

		if ply:IsPlayer() then
			players = self:GetLower(ply:Info(), players)
		end

		local time = 5
		if #args >= 1 and isnumber(tonumber(args[1])) then
			time = tonumber(args[1])
			table.remove(args, 1)
		end

		if table.Count(players) == 1 then
			local playerId = table.GetKeys(players)[1]
			local playerInfo = players[playerId]

			local reason = "No reason specified"
			if table.concat(args, " ") != "" then
				reason = table.concat(args, " ")
			end

			galactic.banManager:Ban(playerId, playerInfo.nick, playerInfo.steamID, time * 60, reason, ply)

			for i,v in ipairs(player.GetAll()) do
				if v:Identifier() == playerId then
					v:Kick(reason)
				end
			end

			local message = {}
			table.insert(message, {"blue", ply:Nick()})
			table.insert(message, {"text", " has banned "})
			table.insert(message, {"red", playerInfo.nick})

			if time <= 0 then
				table.insert(message, {"yellow", " permanently"})
			else
				table.insert(message, {"text", " for "})
				table.insert(message, {"yellow", string.NiceTime(time * 60)})
			end
			if reason then
				table.insert(message, {"text", " with the reason: "})
				table.insert(message, {"yellow", reason})
			end
			galactic.messages:Notify(ply, unpack(message))
			
		elseif table.Count(players) > 0 then
			local message = {}
			table.insert(message, {"text", galactic.messages.question .. " "})
			table.insert(message, {"red", table.Count(players)})
			table.insert(message, {"text", "?"})
			galactic.messages:Notify(ply, unpack(message))
		else
			galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
		end
	else
		galactic.messages:Notify(ply, {"red", "Please provide a player to ban"})
	end

end

function component:GetLower(playerInfo, playersInfo)
	local playersInfoLower = {}
	for k, plInfo in pairs(playersInfo) do
		if playerInfo == plInfo then
			playersInfoLower[k] = plInfo
		elseif self:GreaterThan(playerInfo, plInfo) then
			playersInfoLower[k] = plInfo
		end
	end
	return playersInfoLower
end

function component:GreaterThan(attackerInfo, victimInfo)
	return self:Rank(attackerInfo) < self:Rank(victimInfo)
end

function component:Rank(playerInfo)
	local roles = self:Roles(playerInfo)
	for i, role in ipairs(galactic.roleManager.roles) do
		if table.HasValue(roles, role) then
			return i
		end
	end
end

function component:Roles(playerInfo)
	return galactic.roleManager:RolesByInfo(playerInfo)
end

galactic:Register(component)