local component = {}
component.dependencies = {"messages", "messages"}
component.title = "RCON"
component.description = "Run rcon on the server via chat"
component.command = "rcon"
component.tip = "<arguments>"
component.permission = component.title

function component:Execute(ply, args)
	if args[1] then
		RunConsoleCommand(unpack(args))
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.missingArguments})
	end
end

galactic:Register(component)
