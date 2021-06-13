local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Noclip"
component.description = "Enable/Disable noclip for players"
component.command = "noclip"
component.tip = "[players|1/0] [1/0]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {{"Enable", 1}, {"Disable", 0}}

function component:Execute(ply, args)
	local enabled = galactic.consoleManager:TryArgToBool(args, #args, true)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			if enabled then
				pl:SetMoveType(MOVETYPE_NOCLIP)
			else
				pl:SetMoveType(MOVETYPE_WALK)
			end
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		if enabled then
			table.insert(announcement, {"text", " has noclipped "})
		else
			table.insert(announcement, {"text", " has clipped "})
		end
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		galactic.messages:Announce(unpack(announcement))
	end
end

function component:PlayerNoClip(ply, wantsToNoClip)
	if ply:HasPermission(self.permission) or not wantsToNoClip then
		return true
	end
end

galactic:Register(component)