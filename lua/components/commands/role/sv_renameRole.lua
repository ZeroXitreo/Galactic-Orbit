local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Rename role"
component.command = "renamerole"
component.tip = "<shorthand> <title>"
component.permission = "Role management"

function component:Execute(ply, args)
	local shorthand = galactic.consoleManager:RequestData(ply, table.remove(args, 1), "shorthand", "a")
	if shorthand then
		local _, role = galactic.consoleManager:ListFind(ply, galactic.roleManager.roles, function(k, v) return string.lower(v.shorthand) == string.lower(shorthand) end, shorthand)
		if role then
			local title = galactic.consoleManager:RequestData(ply, table.remove(args, 1), "title", "a")
			if title then
				if galactic.consoleManager:NotOnList(ply, galactic.roleManager.roles, function(k, v) return string.lower(v.title) == string.lower(title) and v != role end, title) then
					galactic.roleManager:RenameRole(shorthand, title)
				end
			end
		end
	end
end

galactic:Register(component)
