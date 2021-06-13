local component = {}
component.namespace = "permissionRestrictions"
component.dependencies = {"messages", "roleManager"}
component.title = "Permission restrictions"

function component:PlayerSpawnSWEP(ply, class, tbl)
	if GAMEMODE.IsSandboxDerived and not ply:HasWeaponPermission(class) then
		local announcement = {}
		table.insert(announcement, {"red", "You are not allowed to spawn this weapon"})
		galactic.messages:Notify(ply, unpack(announcement))
		return false
	end
end
function component:PlayerGiveSWEP(ply, class, tbl)
	if self:PlayerSpawnSWEP(ply, class, tbl) == false then
		return false
	end
end

function component:PlayerSpawnSENT(ply, class)
	if GAMEMODE.IsSandboxDerived and not ply:HasEntityPermission(class) then
		local announcement = {}
		table.insert(announcement, {"red", "You are not allowed to spawn this entity"})
		galactic.messages:Notify(ply, unpack(announcement))
		return false
	end
end

function component:CanTool(ply, tr, class)
	if GAMEMODE.IsSandboxDerived and not ply:HasToolPermission(class) then
		local announcement = {}
		table.insert(announcement, {"red", "You are not allowed to use this tool"})
		galactic.messages:Notify(ply, unpack(announcement))
		return false
	end
end

galactic:Register(component)