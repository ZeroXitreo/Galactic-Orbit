local component = {}
component.dependencies = {"messages"}
component.title = "Extinguish"
component.description = "Extinguish everything"
component.command = "extinguish"
component.permission = component.title

function component:Execute(ply)
	for _, ent in ipairs(ents.GetAll()) do
		ent:Extinguish()
	end
	local announcement = {}
	table.insert(announcement, {"blue", ply:Nick()})
	table.insert(announcement, {"text", " has extinguished everything"})
	galactic.messages:Announce(unpack(announcement))
end

galactic:Register(component)