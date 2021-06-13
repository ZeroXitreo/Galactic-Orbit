local component = {}
component.dependencies = {"messages", "roleManager"}
component.title = "New role"
component.command = "newrole"
component.tip = "<shorthand> <title> [inherit from]"
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

	if self:GetRoleByShorthand(shorthand) then
		local announcement = {}
		table.insert(announcement, {"red", shorthand .. " is already a shorthand for another role"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// Title
	local title = args[2]

	if not title then
		local announcement = {}
		table.insert(announcement, {"red", "Please provide a title"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// inheritFrom with authority control
	local inheritFrom = args[3]
	if inheritFrom then
		for i, role in ipairs(galactic.roleManager.roles) do
			if role.shorthand == inheritFrom then
				local authority = ply:Rank()
				if i <= authority then
					local announcement = {}
					table.insert(announcement, {"red", "The role you're trying to inherit from is beyond your authority"})
					galactic.messages:Notify(ply, unpack(announcement))
					return
				end
			end
		end
	end

	// Success
	galactic.roleManager:AddRole(shorthand, title, inheritFrom)
	
end

function component:GetRoleByShorthand(shorthand)

	for i, v in ipairs(galactic.roleManager.roles) do
		if v.shorthand == shorthand then
			return v
		end
	end

end

galactic:Register(component)