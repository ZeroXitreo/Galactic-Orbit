local component = {}
component.dependencies = {"log", "permissionRestrictions"}
component.title = "Log triggers"
component.description = "Add a bunch of log triggers"
	
function component:SendLogEvent(ply, text)
	galactic.log:Log(galactic.log:PlayerLogStr(ply) .. " " .. text)	
end

function component:PlayerSpawnedEffect(ply, model, ent)
	component:SendLogEvent(ply, "spawned an effect with model: " .. model)
end

function component:PlayerSpawnedNPC(ply, ent)
	component:SendLogEvent(ply, "spawned an NPC with class: " .. ent:GetClass())
end

function component:PlayerSpawnedProp(ply, model, ent)
	component:SendLogEvent(ply, "spawned a prop with model: " .. model)
end

function component:PlayerSpawnedRagdoll(ply, model, ent)
	component:SendLogEvent(ply, "spawned a ragdoll with model: " .. model)
end

function component:PlayerSpawnedSENT(ply, ent)
	component:SendLogEvent(ply, "spawned a SENT with class: " .. ent:GetClass())
end

function component:PlayerSpawnedSWEP(ply, ent)
	component:SendLogEvent(ply, "spawned a SWEP with class: " .. ent:GetClass())
end

function component:PlayerSpawnedVehicle(ply, ent)
	component:SendLogEvent(ply, "spawned a vehicle with model: " .. ent:GetModel())
end

function component:CanTool(ply, tr, tool)
	component:SendLogEvent(ply, "used " .. tool .. " on: " .. tr.Entity:GetModel())
end

function component:PlayerInitialSpawn(ply)
	component:SendLogEvent(ply, "connected to the server.")
	galactic.log:Log( galactic.log:PlayerLogStr(ply) .. " spawned for the first time this session.")
end

function component:PlayerConnect(name, address)
	galactic.log:Log(name .. " connected to the server.")
end

function component:PlayerDisconnected(ply)
	component:SendLogEvent(ply, "dropped from the server.")
	galactic.log:Log(galactic.log:PlayerLogStr(ply) .. " disconnected from the server.")
end

function component:InitPostEntity()
	galactic.log:Log("== Started in map '" .. game.GetMap() .. "' and gamemode '" .. GAMEMODE.Name .. "' ==")
end

function component:PlayerSay(ply, txt)
	galactic.log:Log(galactic.log:PlayerLogStr( ply ) .. ": " ..  txt)
end

function component:PlayerDeath(ply, inf, killer)
	if (ply != killer) then
		galactic.log:Log( galactic.log:PlayerLogStr(ply) .. " was killed by " .. galactic.log:PlayerLogStr(killer) .. ".")
	end
end

galactic:Register(component)