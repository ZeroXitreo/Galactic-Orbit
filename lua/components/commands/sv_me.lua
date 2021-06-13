local component = {}
component.dependencies = {"messages"}
component.title = "Me"
component.description = "Represent an action in your own name"
component.command = "me"
component.tip = "<action>"
component.permission = component.title

function component:Execute(ply, args)
	if not table.IsEmpty(args) then
		galactic.messages:Announce({"blue", ply:Nick()}, {"text", " " .. table.concat(args, " ")})
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.missingArguments})
	end
end

galactic:Register(component)
