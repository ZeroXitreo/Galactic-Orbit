local component = {}
component.namespace = "messages"
component.title = "Messages"
component.networkID = "messageInbound"

component.noPlayersFound = "No matching players was found"
component.question = "Did you mean"
component.missingArguments = "Missing arguments"

if CLIENT then
	component.dependencies = {"theme"}
else
	component.isSilent = false
end

function component:Constructor()
	if SERVER then
		util.AddNetworkString(self.networkID)
	else
		net.Receive(self.networkID, function(length)
			local argc = net.ReadUInt(8)
			local args = {}
			for i = 1, argc do
				if net.ReadBool() then
					table.insert(args, galactic.theme.colors[net.ReadString()])
				else
					table.insert(args, net.ReadColor())
				end
				table.insert(args, net.ReadString())
			end

			table.insert(args, galactic.theme.colors.text)
			
			chat.AddText(unpack(args))
		end)
	end
end

if SERVER then
	function component:BuildNetMessage(...)
		local args = {...}
		local collectedString = ""
		net.Start(self.networkID)
		net.WriteUInt(#args, 8)
		for _, v in ipairs(args) do
			local col = v[1]
			local str = v[2]
			if isstring(col) then
				net.WriteBool(true)
				net.WriteString(col)
			else
				net.WriteBool(false)
				net.WriteColor(col)
			end
			net.WriteString(str)
			collectedString = collectedString .. str
		end
		return collectedString
	end

	function component:Announce(...)
		if not self.isSilent then
			local collectedString = self:BuildNetMessage(...)
			print(collectedString)
			net.Broadcast()
		else
			local args = {...}
			local collectedString = ""
			for _, v in ipairs(args) do
				local str = v[2]
				collectedString = collectedString .. str
			end
			print("(Pruned) " .. collectedString)
		end
	end

	function component:Notify(ply, ...)
		local collectedString = self:BuildNetMessage(...)
		if not ply:IsValid() then
			print(collectedString)
		end
		net.Send(ply)
	end
end

function component:PlayersToString(plys, useOr)
	local lastConcatenate = (useOr and "or") or "and"
	
	if #plys == 1 then
		return plys[1]:Nick()
	end

	if #plys == #player.GetAll() then
		return "everyone"
	end

	local plyNicks = {}
	for i, ply in pairs(plys) do
		table.insert(plyNicks, ply:Nick())
	end
	return table.concat(plyNicks, ", ", 1, #plyNicks - 1) .. " " .. lastConcatenate .. " " .. plyNicks[#plyNicks]
end

function component:TableToString(tbl, useOr, toStringFunc)
	local lastConcatenate = (useOr and "or") or "and"

	if not toStringFunc then
		toStringFunc = function(item) return item end
	end
	
	if #tbl == 1 then
		return toStringFunc(tbl[1])
	end

	local tblToString = {}
	for i, item in pairs(tbl) do
		table.insert(tblToString, toStringFunc(item))
	end
	return table.concat(tblToString, ", ", 1, #tblToString - 1) .. " " .. lastConcatenate .. " " .. tblToString[#tblToString]
end

function component:GetPlayers(ply, args)

	if not args or istable(args) and table.IsEmpty(args) then
		if ply:IsValid() then
			return {ply}
		else
			return {}
		end
	end

	if isstring(args) then
		args = {args}
	end

	local plys = {}
	for _, arg in pairs(args) do
		if arg == "*" then
			return player.GetAll()
		end

		for _, pl in ipairs(player.GetAll()) do
			local found = (pl:Nick():lower():find(arg:lower(), nil, true) and true) or false
			if found or arg == pl:SteamID() then
				plys[pl] = true
			end
		end
	end

	local returnPlys = {}
	for pl, _ in pairs(plys) do
		table.insert(returnPlys, pl)
	end

	return returnPlys
end

function component:GetPlayerInformations(ply, args)

	if not args or istable(args) and table.IsEmpty(args) then
		if ply:IsValid() then
			return {ply:Info()}
		else
			return {}
		end
	end

	if isstring(args) then
		args = {args}
	end

	local plys = {}
	local allPlayerInformations = galactic.pdManager.playersInformation

	for _, arg in ipairs(args) do
		if arg == "*" then
			return allPlayerInformations
		end

		for id, pl in pairs(allPlayerInformations) do

			local found = (pl.steamID:lower():find(arg:lower(), nil, true) and true) or false

			if found or arg == pl.steamID then
				plys[id] = pl
			end
		end
	end

	return plys
end

function component:MessageList(announcement, tbl, total, namFunc, namCol, sepCol, lastSplit, seperator, all)
	if not tbl or table.IsEmpty(tbl) or not istable(announcement) then return end
	if not announcement or not istable(announcement) then return end
	if not namFunc then namFunc = function(name) return name end end
	if not namCol then namCol = "red" end
	if not sepCol then sepCol = "text" end

	if total and isnumber(total) and total == table.Count(tbl) then
		table.insert(announcement, {namCol, all or "everyone"})
		return
	end

	local lastValue = table.remove(tbl, table.Count(tbl))
	local secondLastValue = table.remove(tbl, table.Count(tbl))

	for k, v in pairs(tbl) do
		table.insert(announcement, {namCol, namFunc(tbl[k])})
		table.insert(announcement, {sepCol, seperator or ',' .. " "})
	end

	if secondLastValue then
		table.insert(announcement, {namCol, namFunc(secondLastValue)})
		table.insert(announcement, {sepCol, string.format(" %s ", lastSplit or "and")})
	end
	table.insert(announcement, {namCol, namFunc(lastValue)})
end

galactic:Register(component)