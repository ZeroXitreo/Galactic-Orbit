local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Frags"
component.description = "Set the frags of players"
component.command = "frags"
component.tip = "[players|frags] [frags]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {}

function component:Execute(ply, args)
	local frags = galactic.consoleManager:TryArgToNumber(args, #args, 0)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			pl:SetFrags(frags)
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " has set the frags of "})
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		table.insert(announcement, {"text", " to "})
		table.insert(announcement, {"yellow", frags})
		galactic.messages:Announce(unpack(announcement))
	end
end

galactic:Register(component)
