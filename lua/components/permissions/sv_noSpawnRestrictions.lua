local component = {}
component.dependencies = {"roleManager"}
component.title = "No spawn restrictions"
component.description = "Allows players with this permission to spawn as many entities as they want"
component.permission = component.title

function component:PlayerSpawnSENT(ply, class)
	if ply.HasPermission and ply:HasPermission(self.permission) or ply.hasNoLimits then
		if ply:HasEntityPermission(class) then
			return true
		end
	end
end

function component:PlayerSpawnEffect(ply)
	if ply.HasPermission and ply:HasPermission(self.permission) or ply.hasNoLimits then
		return true
	end
end

function component:PlayerSpawnNPC(ply)
	if ply.HasPermission and ply:HasPermission(self.permission) or ply.hasNoLimits then
		return true
	end
end

function component:PlayerSpawnProp(ply)
	if ply.HasPermission and ply:HasPermission(self.permission) or ply.hasNoLimits then
		return true
	end
end

function component:PlayerSpawnRagdoll(ply)
	if ply.HasPermission and ply:HasPermission(self.permission) or ply.hasNoLimits then
		return true
	end
end

function component:PlayerSpawnVehicle(ply)
	if ply.HasPermission and ply:HasPermission(self.permission) or ply.hasNoLimits then
		return true
	end
end

galactic:Register(component)
