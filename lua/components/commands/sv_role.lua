local component = {}
component.dependencies = {"messages", "roleManager", "pdManager"}
component.title = "Give roles"
component.description = "Add/Remove people to/from roles"
component.command = "role"
component.tip = "<player> [role] [1/0]"
component.permission = component.title

function component:Execute(ply, args)

	local enabled = true
	if isnumber(tonumber(args[#args])) then
		enabled = tonumber(args[#args]) != 0
		table.remove(args, #args)
	end

	local players = galactic.messages:GetPlayers(ply, args[1])

	if #players == 1 then
		if args[2] then
			players = ply:GetLower(players)
			if #players == 1 then
				local foundRole = nil
				local isRoleUnder = false
				for i, role in ipairs(galactic.roleManager.roles) do
					if role.shorthand == args[2] then
						foundRole = role
						local authority = ply:Rank()
						if i > authority then
							isRoleUnder = true
						end
					end
				end
				if foundRole then
					if isRoleUnder then
						if enabled then
							galactic.pdManager:AddRoleToPlayer(players[1], foundRole.shorthand)
							local announcement = {}
							table.insert(announcement, {"blue", ply:Nick()})
							table.insert(announcement, {"text", " added role "})
							table.insert(announcement, {"yellow", foundRole.title})
							table.insert(announcement, {"text", " to "})
							table.insert(announcement, {"red", players[1]:Nick()})
							galactic.messages:Announce(unpack(announcement))
						else
							galactic.pdManager:RemoveRoleFromPlayer(players[1], foundRole.shorthand)
							local announcement = {}
							table.insert(announcement, {"blue", ply:Nick()})
							table.insert(announcement, {"text", " removed role "})
							table.insert(announcement, {"red", foundRole.title})
							table.insert(announcement, {"text", " from "})
							table.insert(announcement, {"red", players[1]:Nick()})
							galactic.messages:Announce(unpack(announcement))
						end
					else
						galactic.messages:Notify(ply, {"red", "You are not allowed to add anyone into the " .. foundRole.title .. " role"})
					end
				else
					galactic.messages:Notify(ply, {"red", args[2] .. " was not found as a role"})
				end
			elseif #players > 1 then
				galactic.messages:Notify(ply, {"red", "You can't add multiple to a role at once"})
			else
				galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
			end
		else
			local announcement = {}
			table.insert(announcement, {"blue", players[1]:Nick()})
			table.insert(announcement, {"text", " is currently "})
			local roles = galactic.roleManager:RolesByInfo(players[1]:Info())
			local rolesStr = galactic.messages:TableToString(roles, false, function(info) return info.title end)
			table.insert(announcement, {"red", rolesStr})
			galactic.messages:Notify(ply, unpack(announcement))
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

end

galactic:Register(component)