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
	local ENTITY = FindMetaTable("Entity")
	function ENTITY:SetCleanupCreator(ply)
		self:SetNWString("GalacticCreator", ply:SteamID())
	end
	
	function ENTITY:GetCleanupCreator()
		return self:GetNWString("GalacticCreator")
	end
end

function component:OnGamemodeLoaded()
	local PLAYER = FindMetaTable("Player")
	if PLAYER.AddCount then
		galactic.PLAYERAddCountCleanup = galactic.PLAYERAddCountCleanup or PLAYER.AddCount
		function PLAYER:AddCount(Type, ent) -- self: Player
			ent:SetCleanupCreator(self)
			return galactic.PLAYERAddCountCleanup(self, Type, ent)
		end
	end
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
				if ent:GetCleanupCreator() == ply:SteamID() then
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
