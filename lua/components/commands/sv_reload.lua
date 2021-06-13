local component = {}
component.dependencies = {"messages"}
component.title = "Reload"
component.description = "Reload the map."
component.command = "reload"
component.permission = component.title

function component:Execute(ply)
	local announcement = {}
	table.insert(announcement, {"blue", ply:Nick()})
	table.insert(announcement, {"text", " has reloaded the map"})
	galactic.messages:Announce(unpack(announcement))
	RunConsoleCommand("changelevel", game.GetMap())
end

galactic:Register(component)