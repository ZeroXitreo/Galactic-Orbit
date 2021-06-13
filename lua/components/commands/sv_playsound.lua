local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Play sound"
component.description = "Play a sound for everyone"
component.command = "play"
component.tip = "<path>"
component.permission = component.title

function component:Execute(ply, args)

	argConcat =  table.concat(args, " ")

	if file.Exists( "sound/" .. argConcat, "GAME") then
		galactic.messages:Announce({"blue", ply:Nick()}, {"text", " played the sound: "}, {"red", "sound/" .. argConcat})
		for _, pl in ipairs( player.GetAll() ) do
			pl:ConCommand( "play " .. argConcat )
		end
	else
		galactic.messages:Notify(ply, {"red", "No sound was found"})
	end
end

galactic:Register(component)