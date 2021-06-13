local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Color role"
component.command = "colorrole"
component.tip = "<title> <0-255> <0-255> <0-255>"
component.permission = "Role management"

function component:Execute(ply, args)

	local role = self:GetRoleByTitle(args[1])

	// No role found
	if not role then
		local announcement = {}
		table.insert(announcement, {"red", args[1] .. " wasn't found"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// Red not a number
	local r = tonumber(args[2])
	if not isnumber(r) then
		local announcement = {}
		table.insert(announcement, {"red", args[2] .. " isn't a number between 0-255"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// Green not a number
	local g = tonumber(args[3])
	if not isnumber(g) then
		local announcement = {}
		table.insert(announcement, {"red", args[3] .. " isn't a number between 0-255"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// Green not a number
	local b = tonumber(args[4])
	if not isnumber(b) then
		local announcement = {}
		table.insert(announcement, {"red", args[4] .. " isn't a number between 0-255"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	galactic.roleManager:SetColorRole(role.title, Color(r, g, b))

	galactic.roleManager:Save()
	
end

function component:GetRoleByTitle(title)

	for i, v in ipairs(galactic.roleManager.roles) do
		if v.title == title then
			return v
		end
	end

end

galactic:Register(component)