local component = {}
component.dependencies = {"data", "pdManager", "arc"}
component.namespace = "banManager"
component.title = "Ban manager"

component.bans = {}

if SERVER then
	component.fileName = "bans"
	component.timerPurgeTimer = component.namespace .. "PurgeTimer"
end

function component:Constructor()
	if SERVER then
		self:Load()
		self:Purge()

		timer.Create(component.timerPurgeTimer, 60, 0, function()
			self:Purge()
		end)
	end
	galactic.arc:Setup(self.namespace, self.bans)
end

if SERVER then
	function component:Load()
		if galactic.data:TableExists(self.fileName) then
			table.Empty(self.bans)
			table.Merge(self.bans, galactic.data:GetTable(self.fileName))
		end
	end

	function component:Save()
		galactic.data:SetTable(self.fileName, self.bans)
	end

	function component:Purge()
		for id, ban in pairs(self.bans) do
			if ban.duration and ban.time + ban.duration < os.time() then
				self:Unban(id)
			end
		end
	end

	function component:Ban(identity, nick, steamId, duration, reason, ply)
		self.bans[identity] = {}
		self.bans[identity].nick = nick
		self.bans[identity].steamId = steamId
		if duration > 0 then
			self.bans[identity].duration = duration
		end
		self.bans[identity].time = os.time()
		self.bans[identity].user = ply:Nick()
		self.bans[identity].reason = reason

		galactic.arc:Add(self.namespace, identity, self.bans[identity])
		self:Save()
	end

	function component:Unban(identity)
		self.bans[identity] = nil

		galactic.arc:Remove(self.namespace, identity)
		self:Save()
	end

	function component:PlayerAuthed(ply, steamid, uniqueid)
		local id = ply:Identifier()
		if self.bans[id] != nil then
			local ban = self.bans[id]
			if ban.duration and ban.time + ban.duration < os.time() then
				self:Unban(id)
			else
				ply:Kick(ban.reason)
			end
		end
	end
end

if CLIENT then
	function component:ArcOnLoad(tblContent)
		table.Empty(self.bans)
		table.Merge(self.bans, tblContent)
		hook.Run("OrbitBanPopulate")
	end

	function component:ArcOnRemove(id)
		self.bans[id] = nil
		hook.Run("OrbitBanDeleted", id)
	end

	function component:ArcOnAdd(id, tblContent)
		if self.bans[id] then
			table.Empty(self.bans[id])
			table.Merge(self.bans[id], tblContent)
			hook.Run("OrbitBanUpdated", id, tblContent)
		else
			self.bans[id] = tblContent
			hook.Run("OrbitBanCreated", id, tblContent)
		end
	end
end

galactic:Register(component)
