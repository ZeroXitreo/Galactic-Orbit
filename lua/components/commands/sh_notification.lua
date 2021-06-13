local component = {}
component.title = "Notice"
component.description = "Put a notification up"
component.command = "notice"
component.tip = "<time = 10|message> [message]"
component.networkStringNotify = "GalacticOrbitNotify"
component.permission = component.title

if SERVER then
	component.dependencies = {"consoleManager"}

	function component:Execute(ply, args)
		local time = galactic.consoleManager:FirstNumberArg(args) or 10
		time = galactic.consoleManager:RequestNumber(ply, time, "timer", "a", 1)
		if time then
			local content = galactic.consoleManager:RequestData(ply, table.concat(args, " "), "message", "a")
			if content then
				net.Start(self.networkStringNotify)
				net.WriteString(content)
				net.WriteUInt(time, 8)
				net.Broadcast()
			end
		end
	end
end

function component:Constructor()
	if SERVER then
		util.AddNetworkString(self.networkStringNotify)
	else
		net.Receive(self.networkStringNotify, function(length)
			notification.AddLegacy(net.ReadString(), NOTIFY_GENERIC, net.ReadUInt(8))
			surface.PlaySound("ambient/water/drip" .. math.random( 1, 4 ) .. ".wav")
		end)
	end
end

galactic:Register(component)
