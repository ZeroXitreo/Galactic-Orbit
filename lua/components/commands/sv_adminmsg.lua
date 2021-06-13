local component = {}
component.dependencies = {"messages"}
component.title = "Public admin message"
component.description = "Display an anonymous admin notice"
component.command = "pa"
component.tip = "<message>"
component.permission = component.title

function component:Execute(ply, args)
	if args[1] then
		galactic.messages:Announce({"red", "(ADMIN)"}, {"text", ": " .. table.concat(args, " ")})
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.missingArguments})
	end
end

galactic:Register( component )