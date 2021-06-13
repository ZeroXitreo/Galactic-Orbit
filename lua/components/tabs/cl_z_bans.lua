local component = {}
component.dependencies = {"menu", "pdManager", "banManager"}
component.title = "Bans"

component.description = "Manage bans"
component.icon = "exclamation"
component.width = 256 * 2.5
component.permission = component.title .. " tab"

function component:InitializeTab(parent)
	self.container = parent:Add("DPanel")
	self.container:Dock(FILL)

	self.container.bannedList = self.container:Add("DListView")
	self.container.bannedList:SetMultiSelect(false)
	self.container.bannedList:Dock(FILL)
	self.container.bannedList:AddColumn("Nickname")
	self.container.bannedList:AddColumn("SteamID")
	self.container.bannedList:AddColumn("Time")
	self.container.bannedList:AddColumn("Reason")
	self.container.bannedList:AddColumn("Banned by")
	self.container.bannedList.OnRowRightClick = function(this, lineId, line)
		local menu = DermaMenu()
		menu:AddOption("Copy SteamID", function() SetClipboardText(line:GetValue(2)) end)
		menu:AddOption("Edit time", function()
			local _, line = this:GetSelectedLine()
			if line then
				local ban = galactic.banManager.bans[line.id]
				if ban then
					galactic.io:String("Edit time on " .. ban.nick, "What should the new ban time be?", function(result)
						local ban = galactic.banManager.bans[line.id]
						if ban then
							LocalPlayer():ConCommand(string.format("orb ban %q %q %q", ban.steamId, result, ban.reason))
						end
					end)
				end
			end
		end)
		menu:AddOption("Edit reason", function()
			local _, line = this:GetSelectedLine()
			if line then
				local ban = galactic.banManager.bans[line.id]
				if ban then
					galactic.io:String("Edit reason for " .. ban.nick .. "'s ban", "", function(result)
						local ban = galactic.banManager.bans[line.id]
						if ban then
							LocalPlayer():ConCommand(string.format("orb ban %q %q %q", ban.steamId, ban.duration and (ban.duration + ban.time - os.time()) / 60, result))
						end
					end)
				end
			end
		end)
		menu:AddOption("Unban", function()
			local _, line = this:GetSelectedLine()
			if line then
				local ban = galactic.banManager.bans[line.id]
				if ban then
					galactic.io:Boolean("Unban " .. ban.nick, "Are you sure you want to unban " .. ban.nick .. "?", function(result)
						local ban = galactic.banManager.bans[line.id]
						if ban then
							LocalPlayer():ConCommand(string.format("orb unban %q", ban.steamId))
						end
					end)
				end
			end
		end)
		menu:Open()
	end

	self:OrbitBanPopulate()
end

function component:OrbitBanPopulate()
	self.container.bannedList:Clear()
	for id, ban in pairs(galactic.banManager.bans) do
		self:OrbitBanCreated(id, ban)
	end
end

function component:OrbitBanCreated(id, ban)
	local line = self.container.bannedList:AddLine(ban.nick, ban.steamId, ban.duration and string.NiceTime(ban.duration) or "Permanently", ban.reason, ban.user)
	line.id = id
end

function component:OrbitBanUpdated(id, ban)
	for _, line in pairs(self.container.bannedList:GetLines()) do
		if line.id == id then
			line:SetColumnText(1, ban.nick)
			line:SetColumnText(2, ban.steamId)
			line:SetColumnText(3, string.NiceTime(ban.duration))
			line:SetColumnText(4, ban.reason)
			line:SetColumnText(5, ban.user)
		end
	end
end

function component:OrbitBanDeleted(id)
	for i, line in pairs(self.container.bannedList:GetLines()) do
		if line.id == id then
			self.container.bannedList:RemoveLine(i)
		end
	end
end

galactic:Register(component)
