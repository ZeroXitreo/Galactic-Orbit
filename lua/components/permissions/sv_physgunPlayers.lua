local component = {}
component.dependencies = {"roleManager"}
component.title = "Physgun players"
component.description = "Gives you the ability to lift people with your physgun"
component.permission = component.title

function component:PhysgunPickup(ply, ent)
	if (ply:HasPermission(self.permission) and ent:IsPlayer() and ply:GreaterThan(ent)) then
		ent.isPickedUpByPhysgun = true
		ent:SetMoveType(MOVETYPE_NOCLIP)
		return true
	end
end

function component:PhysgunDrop(ply, ent)
	//print(ent:GetVelocity())
	if ent:IsPlayer() then
		ent.isPickedUpByPhysgun = false
		ent:SetMoveType(MOVETYPE_WALK)
		return true
	end
end

function component:PlayerNoclip(ply)
	if pl.isPickedUpByPhysgun then
		return false
	end
end

galactic:Register(component)