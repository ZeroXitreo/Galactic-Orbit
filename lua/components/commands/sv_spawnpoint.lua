local component = {}
component.dependencies = {"messages", "messages", "roleManager", "jail"}
component.title = "Spawnpoint"
component.description = "Set your own spawnpoint"
component.command = "sp"
component.tip = "[1/0]"
component.permission = component.title

function component:Execute(ply, args)

	local enabled = true
	if isnumber(tonumber(args[#args])) then
		enabled = tonumber(args[#args]) != 0
		table.remove(args, #args)
	end

	if enabled then
		ply.spawnPosition = ply:GetPos()
		ply.spawnEyeAngle = ply:EyeAngles()
	else
		ply.spawnPosition = nil
		ply.spawnEyeAngle = nil
	end
	local announcement = {}
	table.insert(announcement, {"blue", ply:Nick()})
	if enabled then
		table.insert(announcement, {"text", " has set"})
	else
		table.insert(announcement, {"text", " has reset"})
	end
	table.insert(announcement, {"text", " their spawnpoint"})
	galactic.messages:Announce(unpack(announcement))

end

function component:PlayerSpawn(ply)
	if not ply.isJailed && ply.spawnPosition && ply.spawnEyeAngle then
		ply:SetPos(ply.spawnPosition)
		ply:SetEyeAngles(ply.spawnEyeAngle)
	end
end

galactic:Register(component)