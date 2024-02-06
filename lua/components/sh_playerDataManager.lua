local component = {}
component.dependencies = {"data", "messages"}
component.namespace = "pdManager"
component.title = "Player data manager"

component.playersInformation = {}
component.netRecieve = "pdManagerRecieve"
component.netPlayerFirstSpawn = "playerFirstSpawn"

if SERVER then
	component.timerName = "pdManagerSaveTimer"
	component.path = "players/"
	component.tableName = "playersInformation"
end

function component:Constructor()

	local PLAYER = FindMetaTable("Player")
	function PLAYER:Info()
		return galactic.pdManager.playersInformation[self:Identifier()] or {
			nick = self:Nick(),
			roles = {},
			lastJoin = os.time(),
			playTime = 0,
			steamID = self:SteamID()
		}
	end

	function PLAYER:Identifier()
		if self:IsBot() then
			return string.lower(self:Nick())
		elseif game.SinglePlayer() then
			return "singleplayer"
		elseif not self:AccountID() then
			return "playerNULL"
		else
			return "player" .. self:AccountID()
		end
	end

	if SERVER then
		gameevent.Listen("player_changename")
		util.AddNetworkString(self.netRecieve)
		util.AddNetworkString(self.netPlayerFirstSpawn)

		self:Load()

		timer.Create(component.timerName, 60, 0, function()
			self:Save()
		end)

		net.Receive(self.netPlayerFirstSpawn, function(len, ply) self:Save() end)

		self:Save()
	else
		net.Receive(self.netRecieve, function(len, ply) self:ReceivePlayerData(ply) end)
	end

end

if SERVER then

	function component:Save()
		for _, ply in ipairs(player.GetAll()) do
			self:SavePlayer(ply)
		end
	end

	function component:SavePlayer(ply)
		local identity = ply:Identifier()
		self:UpdatePlayerTime(identity)
		galactic.data:SetTable(self.path .. identity, self.playersInformation[identity])

		self:BroadcastPlayerInformation(identity)
	end

	function component:BroadcastPlayerInformation(identity)
		net.Start(self.netRecieve)
		net.WriteString(identity)
		net.WriteCompressedTable(self.playersInformation[identity])
		net.Broadcast()
	end

	function component:AddRoleToPlayer(ply, roleStr)
		local identity = ply:Identifier()
		local infoTable = ply:Info()
		if not table.HasValue(infoTable.roles, roleStr) then
			table.insert(infoTable.roles, roleStr)
			self:SavePlayer(ply)
		end
	end

	function component:RemoveRoleFromPlayer(ply, roleStr)
		local identity = ply:Identifier()
		local infoTable = ply:Info()
		table.RemoveByValue(infoTable.roles, roleStr)
		self:SavePlayer(ply)
	end

	function component:Load()
		self.playersInformation = galactic.data:FindTables(self.path)
	end

	function component:PlayerInitialSpawn(ply)
		local identity = ply:Identifier()
		local announcement = {{"blue", ply:Nick()}}
		if not self.playersInformation[identity] then
			self.playersInformation[identity] = {}

			self.playersInformation[identity].nick = ply:Nick()
			self.playersInformation[identity].roles = {}
			self.playersInformation[identity].lastJoin = os.time()
			self.playersInformation[identity].playTime = 0

			if ply:IsBot() then
				self.playersInformation[identity].steamID = ply:Nick()
			else
				self.playersInformation[identity].steamID = ply:SteamID()
			end

			table.insert(announcement, {"text", " joined for the first time"})
		else
			table.insert(announcement, {"text", " last joined "})
			table.insert(announcement, {"red", string.NiceTime(os.time() - self.playersInformation[identity].lastJoin)})
			table.insert(announcement, {"text", " ago"})
			if self.playersInformation[identity].nick != ply:Nick() then
				self.playersInformation[identity].nick = ply:Nick()
				table.insert(announcement, {"text", " as "})
				table.insert(announcement, {"yellow", self.playersInformation[identity].nick})
			end
			self.playersInformation[identity].lastJoin = os.time()
		end

		self:BroadcastPlayerInformation(identity)

		galactic.messages:Announce(unpack(announcement))
	end

	function component:UpdatePlayerTime(identity)
		self.playersInformation[identity].playTime = self.playersInformation[identity].playTime + os.time() - self.playersInformation[identity].lastJoin
		self.playersInformation[identity].lastJoin = os.time()
	end

	function component:GetInfoFromIdentity(identity)
		self:UpdatePlayerTime(identity)
		return self.playersInformation[identity]
	end

	function component:GetIdentityFromSteamID(needle)
		for identity, info in pairs(self.playersInformation) do
			if needle:lower() == info.steamID:lower() then
				return identity
			end
		end
	end

	function component:player_changename(tbl)
		ply = Player(tbl.userid)
		oldname = tbl.oldname
		newname = tbl.newname

		galactic.messages:Announce({"blue", oldname}, {"text", " changed name to "}, {"red", newname})

		self.playersInformation[ply:Identifier()].nick = newname
	end

	function component:PlayerDisconnected(ply)
		self:UpdatePlayerTime(ply:Identifier())
	end

	function component:ShutDown()
		print("Saving player data...")
		for _, ply in ipairs(player.GetAll()) do
			local identity = ply:Identifier()
			galactic.data:SetTable(self.path .. identity, self.playersInformation[identity])
		end
		print("Saved.")
	end
else

	function component:InitPostEntity()
		net.Start(self.netPlayerFirstSpawn)
		net.SendToServer()
	end

	function component:ReceivePlayerData(ply)
		local identity = net.ReadString()
		local content = net.ReadCompressedTable()
		self.playersInformation[identity] = content
	end

	function component:ReceivePlayersData(ply)
		local identity = net.ReadString()
		local content = net.ReadCompressedTable()
		self.playersInformation[identity] = content
	end

end

galactic:Register(component)
