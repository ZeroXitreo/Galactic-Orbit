local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Remove role"
component.command = "removerole"
component.tip = "<shorthand>"
component.permission = "Role management"

function component:Execute(ply, args)

	if not args[1] then
		local announcement = {}
		table.insert(announcement, {"red", "Please provide a role to remove"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	local role = self:GetRoleByShorthand(args[1])

	// No role found
	if not role then
		local announcement = {}
		table.insert(announcement, {"red", args[1] .. " wasn't found"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	galactic.roleManager:RemoveRole(role.shorthand)
	
end

function component:GetRoleByShorthand(shorthand)

	for i, v in ipairs(galactic.roleManager.roles) do
		if v.shorthand == shorthand then
			return v
		end
	end

end

galactic:Register(component)