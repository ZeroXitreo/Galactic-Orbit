local component = {}
component.dependencies = {"roleManager"}
component.title = "See event Log"
component.description = "Adds a message to applicable players' console about events such as prop spawning."
component.permission = component.title
	
function component:OnLogging(str)
	for _, ply in pairs(player.GetAll()) do
		if ply:HasPermission(self.permission) and not ply:IsListenServerHost() then
			ply:PrintMessage(HUD_PRINTCONSOLE, str)
		end
	end
end

galactic:Register(component)
