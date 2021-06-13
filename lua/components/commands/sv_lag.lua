local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Lag"
component.description = "Freezes all props"
component.command = "lag"
component.permission = component.title

function component:Execute(ply)
	local entities = ents.FindByClass("prop_physics")
	for _, entity in pairs(entities) do
		if entity:IsValid() then
			local phys = entity:GetPhysicsObject()
			phys:EnableMotion(false)
		end
	end
	local announcement = {}
	table.insert(announcement, {"blue", ply:Nick()})
	table.insert(announcement, {"text", " has frozen all props"})
	galactic.messages:Notify(ply, unpack(announcement))
end

galactic:Register(component)