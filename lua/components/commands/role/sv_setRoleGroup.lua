local component = {}
component.dependencies = {"messages", "roleManager"}
component.title = "Set role group"
component.command = "setrolegroup"
component.tip = "<shorthand> <guest/admin/superadmin>"
component.permission = "Role management"

function component:Execute(ply, args)

	// Shorthand
	local shorthand = args[1]

	if not shorthand then
		local announcement = {}
		table.insert(announcement, {"red", "Please provide a shorthand"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	if not self:GetRoleByShorthand(shorthand) then
		local announcement = {}
		table.insert(announcement, {"red", shorthand .. " wasn't found"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// Title
	local userGroup = args[2]

	if not userGroup then
		local announcement = {}
		table.insert(announcement, {"red", "Please provide a user group"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	if not table.HasValue(galactic.roleManager.userGroups, userGroup) then
		local announcement = {}
		table.insert(announcement, {"red", userGroup .. " user group doesn't exist"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// Success
	galactic.roleManager:SetRoleUserGroup(shorthand, userGroup)
	
end

function component:GetRoleByShorthand(shorthand)

	for i, v in ipairs(galactic.roleManager.roles) do
		if v.shorthand == shorthand then
			return v
		end
	end

end

galactic:Register(component)