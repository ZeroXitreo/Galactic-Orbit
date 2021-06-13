local component = {}
component.dependencies = {"messages", "roleManager"}
component.title = "Set role icon"
component.command = "setroleicon"
component.tip = "<title> <icon>"
component.permission = "Role management"

function component:Execute(ply, args)

	// Shorthand
	local title = args[1]

	if not title then
		local announcement = {}
		table.insert(announcement, {"red", "Please provide a title"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	if not self:GetRoleByShorthand(title) then
		local announcement = {}
		table.insert(announcement, {"red", title .. " wasn't found"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// Title
	local icon = args[2]

	if not icon then
		local announcement = {}
		table.insert(announcement, {"red", "Please provide an icon"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// Success
	galactic.roleManager:SetRoleIcon(title, icon)
	
end

function component:GetRoleByShorthand(title)

	for i, v in ipairs(galactic.roleManager.roles) do
		if v.title == title then
			return v
		end
	end

end

galactic:Register(component)