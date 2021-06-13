local component = {}
component.dependencies = {"messages", "roleManager"}
component.title = "Role tool"
component.command = "roletool"
component.tip = "<shorthand> <tool> [1/0]"
component.permission = "Role management"

function component:Execute(ply, args)

	// Enabled
	local enabled = true
	if isnumber(tonumber(args[#args])) then
		enabled = tonumber(args[#args]) != 0
		table.remove(args, #args)
	end

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
	local tool = args[2]

	if not tool then
		local announcement = {}
		table.insert(announcement, {"red", "Please provide a tool"})
		galactic.messages:Notify(ply, unpack(announcement))
		return
	end

	// Success
	if enabled then
		galactic.roleManager:AddRoleTool(shorthand, tool)
	else
		galactic.roleManager:RemoveRoleTool(shorthand, tool)
	end
	
end

function component:GetRoleByShorthand(shorthand)

	for i, v in ipairs(galactic.roleManager.roles) do
		if v.shorthand == shorthand then
			return v
		end
	end

end

galactic:Register(component)