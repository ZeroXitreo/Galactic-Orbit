local component = {}
component.dependencies = {"messages", "roleManager"}
component.title = "Cleanup"
component.description = "Clean-up players or the entire map"
component.command = "cleanup"
component.tip = "[player]"
component.permission = component.title
component.category = "Punishment"
component.guide = {}

function component:Constructor()

	timer.Simple(0, function()
		if not galactic.PlayerAddCleanup then
			galactic.PlayerAddCleanup = galactic.registry.Player.AddCleanup
		end

		function galactic.registry.Player:AddCleanup(typ, ent)
			ent:SetCreator(self)
			galactic:PlayerAddCleanup(self, typ, ent)
		end

		function galactic.registry.Entity:SetCreator(ply)
			self:SetNWString("GalacticCreator", ply:SteamID())
		end

		function galactic.registry.Entity:GetCreator()
			return self:GetNWString("GalacticCreator")
		end
	end)
end

function component:Execute(ply, args)

	local players = galactic.messages:GetPlayers(ply, args)
	if #args == 0 then
		players = player.GetAll()
	end
	players = ply:GetLower(players)

	if #players > 0 then
		local message = {}
		table.insert(message, {"blue", ply:Nick()})
		table.insert(message, {"text", " has cleaned up "})
		if #players == #player.GetAll() then
			table.insert(message, {"text", "the map"})
			game.CleanUpMap(false, {"env_fire", "entityflame", "_firesmoke"})
		else
			table.insert(message, {"text", "after "})
			table.insert(message, {"red", galactic.messages:PlayersToString(players)})
			local entities = ents.GetAll()
			for _, ent in ipairs(entities) do
				if ent:GetCreator() == ply:SteamID() then
					ent:Remove()
				end
			end
		end
		galactic.messages:Announce(unpack(message))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end

end

galactic:Register(component)
