local component = {}
component.dependency = {"network", "theme", "roleManager", "messages", "permissionManager"}
component.namespace = "consoleManager"
component.title = "Console command manager"
component.short = "orb"
component.shortSilent = "orbs"

component.networkStringRequest = "GalacticOrbitalConsoleCommands"

function component:Constructor()

	if SERVER then
		util.AddNetworkString(self.networkStringRequest)
		net.Receive(self.networkStringRequest, function(len, ply)
			local cmd = net.ReadString()
			local argStr = net.ReadString()
			self:Callback(ply, cmd, argStr)
		end)
	end
	concommand.Add(self.short, function(ply, cmd, args, argStr) self:Callback(ply, cmd, argStr) end, function(cmd, args) return self:AutoComplete(cmd, args) end)
	concommand.Add(self.shortSilent, function(ply, cmd, args, argStr) self:Callback(ply, cmd, argStr) end, function(cmd, args) return self:AutoComplete(cmd, args) end)
end

function component:Callback(ply, cmd, argStr)

	argStr = argStr:TrimRight()

	if SERVER then
		local refinedArgs = {}
		local inQuote = false
		local escape = '\\'
		local quote = '"'
		local space = ' '
		local previousEscape = false
		for i = 1, #argStr do
			if i == 1 then
				table.insert(refinedArgs, "")
			end

			local char = argStr[i]

			if not previousEscape then
				if char == escape then
					previousEscape = true
				elseif char == quote then
					inQuote = not inQuote

					if inQuote and i != 1 and #refinedArgs[#refinedArgs] != 0 then
						table.insert(refinedArgs, "")
					elseif not inQuote and i != #argStr then
						table.insert(refinedArgs, "")
					end
				elseif char == space and not inQuote then
					if #refinedArgs[#refinedArgs] != 0 then
						table.insert(refinedArgs, "")
					end
				else
					refinedArgs[#refinedArgs] = refinedArgs[#refinedArgs] .. char
				end
			else
				previousEscape = false
				refinedArgs[#refinedArgs] = refinedArgs[#refinedArgs] .. char
			end
		end
		
		local args = refinedArgs

		local foundCommand = false
		if #args > 0 then
			for _, comp in ipairs(galactic.components) do
				if comp.command == args[1]:lower() and comp.Execute then // Command found
					foundCommand = true
					if ply:HasPermission(comp.permission) then

						galactic.messages.isSilent = cmd == self.shortSilent
						comp:Execute(ply, {unpack(args, 2)})
						galactic.messages.isSilent = false
					else
						galactic.messages:Notify(ply, {"red", "You do not have permission to do that"})
					end
				end
			end
			if not foundCommand then
				galactic.messages:Notify(ply, {"red", "Unknown command: " .. args[1]})
			end
		else
			galactic.messages:Notify(ply, {"red", "No command specified"})
		end
	else
		net.Start(self.networkStringRequest)
		net.WriteString(cmd)
		net.WriteString(argStr)
		net.SendToServer()
	end
end

function component:AutoComplete(cmd, args)
	args = args.Trim(args)
	args = string.Explode("%s+", args, true)

	local tbl = {}

	for _, v in pairs(galactic.permissionManager.permissions) do
		if v.commands then
			for command, _ in pairs(v.commands) do
				if command and (SERVER or LocalPlayer():HasPermission(v.permission)) then
					if args[1] then
						if string.StartWith(command, args[1]:lower()) and not args[2] then
							table.insert(tbl, cmd .. " " .. command .. " ")
						end
					else
						table.insert(tbl, cmd .. " " .. command)
					end
				end
			end
		end
	end

	return tbl
end

if SERVER then
	function component:RequestData(ply, data, context, grammar)
		if not data or data == "" then
			galactic.messages:Notify(ply, {"red", string.format("Please provide %s %s", grammar, context)})
			return
		end
		return data
	end

	function component:RequestNumber(ply, data, context, grammar, min, max)
		local data = self:RequestData(ply, data, context, grammar)
		if data then
			data = tonumber(data)
			if !isnumber(data) then
				local announcement = {}
				table.insert(announcement, {"red", string.format("The %s must be a number", context)})
				galactic.messages:Notify(ply, unpack(announcement))
				return
			end
			if min and data < min then
				local announcement = {}
				table.insert(announcement, {"red", string.format("The %s must be %s or above", context, min)})
				galactic.messages:Notify(ply, unpack(announcement))
				return
			end
			if max and data < min then
				local announcement = {}
				table.insert(announcement, {"red", string.format("The %s must be %s or below", context, min)})
				galactic.messages:Notify(ply, unpack(announcement))
				return
			end
			return data
		end
	end

	function component:ListFind(ply, tbl, condition, term)
		for k, v in pairs(tbl) do
			if condition(k, v) then
				return k, v
			end
		end
		local announcement = {}
		table.insert(announcement, {"red", string.format("Couldn't find %s", term)})
		galactic.messages:Notify(ply, unpack(announcement))
	end

	function component:NotOnList(ply, tbl, condition, term)
		for k, v in pairs(tbl) do
			if condition(k, v) then
				local announcement = {}
				table.insert(announcement, {"red", string.format("%s already exists", term)})
				galactic.messages:Notify(ply, unpack(announcement))
				return
			end
		end
		return true
	end

	function component:TryArgNumberToBool(args, pos, default)
		default = default or true
		if isnumber(tonumber(args[pos])) then
			default = tobool(table.remove(args, pos))
		end
		return default
	end

	function component:FirstNumberArg(args)
		if isnumber(tonumber(args[1])) then
			local val = table.remove(args, 1)
			return tonumber(val)
		end
	end

	function component:TryArgToBool(args, pos, default)
		return tobool(self:TryArgToNumber(args, pos, default))
	end

	function component:TryArgToNumber(args, pos, default)
		if isnumber(tonumber(args[pos])) then
			default = tonumber(table.remove(args, pos))
		end
		return default
	end

	function component:GetPlayers(ply, args)
		local players = galactic.messages:GetPlayers(ply, args)

		if table.IsEmpty(players) then
			local announcement = {}
			table.insert(announcement, {"red", galactic.messages.noPlayersFound})
			galactic.messages:Notify(ply, unpack(announcement))
			return
		end

		return players
	end

	function component:GetLowerPlayers(ply, args)
		local players = galactic.messages:GetPlayers(ply, args)
		players = ply:GetLower(players)

		if table.IsEmpty(players) then
			local announcement = {}
			table.insert(announcement, {"red", galactic.messages.noPlayersFound})
			galactic.messages:Notify(ply, unpack(announcement))
			return
		end

		return players
	end
end

galactic:Register(component)
