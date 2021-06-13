local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Ragdoll"
component.description = "Ragdoll players"
component.command = "ragdoll"
component.tip = "[players] [1/0]"
component.permission = component.title
component.category = "Punishment"
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
				if ( !pl.isRagdolled and pl:Alive() ) then
					pl:StripWeapons()
					
					local doll = ents.Create("prop_ragdoll")
					doll:SetModel(pl:GetModel())
					doll:SetPos(pl:GetPos())
					doll:SetAngles(pl:GetAngles())
					doll:Spawn()
					doll:Activate()
					
					pl.ragdollEntity = doll
					pl:Spectate(OBS_MODE_CHASE)
					pl:SpectateEntity(pl.ragdollEntity)
					pl:SetParent(pl.ragdollEntity)
					
					pl.isRagdolled = true
				end
			elseif pl.isRagdolled then
				pl:UnSpectate()
				pl:SetNoTarget(false)
				pl:SetParent()
				pl.isRagdolled = false
				if pl.ragdollEntity:IsValid() then
					pl.ragdollEntity:Remove()
				end
				//GAMEMODE:PlayerLoadout(pl)
				pl:Spawn()
			end

		end

		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		if enabled then
			table.insert(announcement, {"text", " has ragdolled "})
		else
			table.insert(announcement, {"text", " has animated "})
		end
		table.insert(announcement, {"red", galactic.messages:PlayersToString(players)})
		galactic.messages:Announce(unpack(announcement))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end
	
end

function component:CanPlayerSuicide(ply)
	if ply.isRagdolled then
		return false
	end
end

function component:PlayerDisconnect(ply)
	if ply.ragdollEntity and ply.ragdollEntity:IsValid() then
		ply.ragdollEntity:Remove()
	end
end

function component:PlayerDeath(ply)
	ply:SetNoTarget(false)
	ply:SetParent()
	ply.isRagdolled = false
end

function component:PlayerSpawn(ply)
	if not ply.isRagdolled and ply.ragdollEntity and ply.ragdollEntity:IsValid() then
		ply.ragdollEntity:Remove()
		ply.ragdollEntity = nil
	end
end

galactic:Register(component)