local component = {}
component.dependencies = {"consoleManager", "messages", "advertManager"}
component.title = "Change advert id"
component.command = "advertid"
component.tip = "<id> <new id>"
component.permission = "Advert management"

function component:Execute(ply, args)
	local id = galactic.consoleManager:RequestData(ply, table.remove(args, 1), "id", "an")
	if id then
		local newId = galactic.consoleManager:RequestData(ply, table.remove(args, 1), "new id", "a")
		if newId then
			galactic.advertManager:SetId(id, newId)
		end
	end
end

galactic:Register(component)
