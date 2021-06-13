local component = {}
component.dependencies = {"messages", "roleManager"}
component.title = "Role move up"
component.command = "rolemoveup"
component.tip = "<shorthand>"
component.permission = "Role management"

function component:Execute(ply, args, aaaa)

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

	// Success
	galactic.roleManager:MoveRoleUp(shorthand)
	
end

function component:GetRoleByShorthand(shorthand)

	for i, v in ipairs(galactic.roleManager.roles) do
		if v.shorthand == shorthand then
			return v
		end
	end

end

galactic:Register(component)
