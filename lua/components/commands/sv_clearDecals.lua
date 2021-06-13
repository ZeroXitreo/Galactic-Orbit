local component = {}
component.dependencies = {"messages"}
component.title = "Clear decals"
component.description = "Clear decals from the map"
component.command = "decals"
component.permission = component.title

if SERVER then
	function component:Execute(ply)
		for _, pl in ipairs(player.GetAll()) do
			pl:ConCommand("r_cleardecals")
			pl:ConCommand("r_cleardecals")
		end

		galactic.messages:Announce({"blue", ply:Nick()}, {"text", " has cleaned up the decals"})
	end
end

galactic:Register(component)