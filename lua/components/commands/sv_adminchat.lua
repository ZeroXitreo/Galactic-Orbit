local component = {}
component.dependencies = {"messages", "roleManager"}
component.title = "Admin chat"
component.description = "Send and view admin messages"
component.command = "a"
component.tip = "<message>"
component.permission = component.title

function component:Execute(ply, args)
	if args[1] then
		local admins = {}
		for _, pl in ipairs(player.GetAll()) do
			if pl:HasPermission(self.permission) then
				table.insert(admins, pl)
			end
		end
		local announcement = {}
		local teamColAsTable = GAMEMODE:GetTeamColor(ply)
		local teamCol = Color(teamColAsTable.r, teamColAsTable.g, teamColAsTable.b)
		table.insert(announcement, {"text", "Admin "})
		table.insert(announcement, {teamCol, ply:Nick()})
		table.insert(announcement, {"text", ": " .. table.concat(args, " ")})
		galactic.messages:Notify(admins, unpack(announcement))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.missingArguments})
	end
end

galactic:Register(component)
