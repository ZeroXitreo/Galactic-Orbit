local component = {}
component.namespace = "jail"
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Jail"
component.description = "Jail players"
component.command = "jail"
component.tip = "[players|1/0] [1/0]"
component.permission = component.title
component.category = "Punishment"
component.guide = {{"Enable", 1}, {"Disable", 0}}

function component:Execute(ply, args)
	local enabled = galactic.consoleManager:TryArgToBool(args, #args, true)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			pl.isJailed = enabled
			pl.jailLocation = pl:GetPos()
			if enabled then
				self:RemoveJailProps(pl)
				self:SpawnJailProps(pl)
				self:ExecuteJailing(pl)
			else
				self:RemoveJailProps(pl)
				hook.Run("PlayerLoadout", pl)
			end
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		if enabled then
			table.insert(announcement, {"text", " has jailed "})
		else
			table.insert(announcement, {"text", " has released "})
		end
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		galactic.messages:Announce(unpack(announcement))
	end
end

function component:ExecuteJailing(ply)
	ply:StripWeapons()
	ply:SetMoveType(MOVETYPE_WALK)
end

function component:RemoveJailProps(ply)
	ply.jailProps = ply.jailProps or {}
	for i, v in ipairs(ply.jailProps) do
		if IsValid(v) then
			v:Remove()
		end
	end
	ply.jailProps = {}
end

function component:SpawnJailProps(ply)
	local spacing = 30
	local propPosAng = {}
	table.insert(propPosAng, {Vector(-spacing, 0, 51), Angle(0, 0, 0)})
	table.insert(propPosAng, {Vector(spacing, 0, 51), Angle(0, 180, 0)})
	table.insert(propPosAng, {Vector(0, -spacing, 51), Angle(0, 90, 0)})
	table.insert(propPosAng, {Vector(0, spacing, 51), Angle(0, -90, 0)})
	table.insert(propPosAng, {Vector(0, 0, -2), Angle(-90, 0, 0)})
	table.insert(propPosAng, {Vector(0, 0, 104), Angle(90, 0, 0)})

	ply.jailProps = ply.jailProps or {}

	for i, v in ipairs(propPosAng) do
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_building_details/Storefront_Template001a_Bars.mdl")
		prop:SetPos(ply.jailLocation + v[1])
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetAngles(v[2])
		prop:Spawn()
		prop:GetPhysicsObject():EnableMotion(false)
		table.insert(ply.jailProps, prop)
	end
end

function component:PlayerSpawn(ply)
	if ply.isJailed then
		self:ExecuteJailing(ply)
	end
end

function component:PlayerLoadout(ply)
	if ply.isJailed then
		self:ExecuteJailing(ply)
		return true
	end
end

function component:PlayerDisconnected(ply)
	if ply.isJailed then self:RemoveJailProps(ply) end
end

function component:CanPlayerSuicide(ply)
	if ply.isJailed then return false end
end

function component:PlayerNoClip(ply)
	if ply.isJailed then return false end
end

function component:PlayerSpawnProp(ply)
	if ply.isJailed then return false end
end

function component:PlayerSpawnSENT(ply)
	if ply.isJailed then return false end
end

function component:PlayerSpawnSWEP(ply)
	if ply.isJailed then return false end
end

function component:PlayerSpawnNPC(ply)
	if ply.isJailed then return false end
end

function component:PlayerSpawnEffect(ply)
	if ply.isJailed then return false end
end

function component:PlayerSpawnRagdoll(ply)
	if ply.isJailed then return false end
end

function component:PlayerSpawnedVehicle(ply, veh)
	if ply.isJailed then veh:Remove() end
end

galactic:Register(component)
