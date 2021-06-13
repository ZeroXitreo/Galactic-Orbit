local component = {}
component.dependencies = {"messages", "pdManager", "messages"}
component.title = "Playtime"
component.description = "Display the lost playtime of a player"
component.command = "playtime"
component.tip = "[player]"
component.permission = component.title
component.guide = {}

function component:Execute(ply, args)
	local players = galactic.messages:GetPlayers(ply, args)

	if #players > 0 then
		if #players == 1 then
			for _, pl in ipairs(players) do
				local identity = pl:Identifier()
				self:DisplayPlaytime(ply, identity)
			end
		else
			local announcement = {}
			table.insert(announcement, {"text", galactic.messages.question .. " "})
			table.insert(announcement, {"red", galactic.messages:PlayersToString(players, true)})
			table.insert(announcement, {"text", "?"})
			galactic.messages:Notify(ply, unpack(announcement))
		end
	else
		local identity = galactic.pdManager:GetIdentityFromSteamID(args[1])
		if identity then
			self:DisplayPlaytime(ply, identity)
		else
			galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
		end
	end
end

function component:DisplayPlaytime(ply, identity)
	local announcement = {}
	table.insert(announcement, {"blue", galactic.pdManager:GetInfoFromIdentity(identity).nick})
	table.insert(announcement, {"text", " has lost "})
	table.insert(announcement, {"red", string.NiceTime(galactic.pdManager:GetInfoFromIdentity(identity).playTime)})
	table.insert(announcement, {"text", " on this server"})
	galactic.messages:Notify(ply, unpack(announcement))
end

galactic:Register(component)
