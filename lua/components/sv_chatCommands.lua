local component = {}
component.namespace = "chatCommands"
component.title = "Chat commands"
component.description = "Provides port from the chat into the console commands"
component.chars = {"!", "/", "@"}
component.silentChars = {"@"}

function component:PlayerSay(ply, msg, isTeam)

	local char = string.Left(msg, 1)

	if table.HasValue(self.chars, char) then
		msg = string.sub(msg, 2) // Remove the front character
		command = string.Split(msg, " ")[1] // Get the command

		local foundCommand = false
		for _,v in ipairs(galactic.components) do
			if v.command == command:lower() and v.Execute then // Command found
				foundCommand = true
				if table.HasValue(component.silentChars, char) then
					ply:ConCommand("orbs " .. msg)
				else
					ply:ConCommand("orb " .. msg)
				end
			end
		end
		if foundCommand then
			return ""
		end

	end

end

galactic:Register(component)