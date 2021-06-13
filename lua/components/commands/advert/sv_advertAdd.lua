local component = {}
component.dependencies = {"consoleManager", "messages", "advertManager"}
component.title = "Add advert"
component.command = "advertadd"
component.tip = "<id> <delay> <<color> <content> <color> <content> ...>"
component.permission = "Advert management"

function component:Execute(ply, args)
	local id = galactic.consoleManager:RequestData(ply, table.remove(args, 1), "id", "an")
	if id then
		local delay = galactic.consoleManager:RequestNumber(ply, table.remove(args, 1), "delay", "a", 1)
		if delay then
			galactic.advertManager:Add(id, delay, args)
		end
	end
end

galactic:Register(component)
