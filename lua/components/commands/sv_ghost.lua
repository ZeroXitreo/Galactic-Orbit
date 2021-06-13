local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Ghost"
component.description = "Ghost players"
component.command = "ghost"
component.tip = "[players|1/0] [1/0]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {{"Enable", 1}, {"Disable", 0}}

function component:Execute(ply, args)

	local enabled = true
	if isnumber(tonumber(args[#args])) then
		enabled = tonumber(args[#args]) != 0
		table.remove(args, #args)
	end

	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)

	if players[1] then
		for _, pl in ipairs(players) do
			if enabled then
				pl:SetRenderMode(RENDERMODE_NONE)
				pl:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			else
				pl:SetRenderMode(RENDERMODE_NORMAL)
				pl:SetCollisionGroup(COLLISION_GROUP_PLAYER)
			end
			pl.isGhosted = enabled
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		if enabled then
			table.insert(announcement, {"text", " has ghosted "})
		else
			table.insert(announcement, {"text", " has unghosted "})
		end
		table.insert(announcement, {"red", galactic.messages:PlayersToString(players)})
		galactic.messages:Announce(unpack(announcement))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end

end

function component:PlayerSpawn(ply)
	if ply.isGhosted then
		ply:SetRenderMode(RENDERMODE_NONE)
		ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
end

galactic:Register(component)
