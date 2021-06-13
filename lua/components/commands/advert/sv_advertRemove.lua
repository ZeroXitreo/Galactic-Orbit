local component = {}
component.dependencies = {"consoleManager", "messages", "advertManager"}
component.title = "Remove advert"
component.command = "advertremove"
component.tip = "<id>"
component.permission = "Advert management"

function component:Execute(ply, args)
	local id = galactic.consoleManager:RequestData(ply, table.remove(args, 1), "id", "an")
	if id then
		galactic.advertManager:Remove(id)
	end
end

galactic:Register(component)
