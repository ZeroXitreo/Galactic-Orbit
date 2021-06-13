local component = {}
component.dependencies = {"menu", "permissionManager", "io"}
component.title = "Players"

component.description = "Manage players"
component.icon = "user"

function component:InitializeTab(parent)
	self.width = 406
	self.categoryPanels = {}
	self.players = parent:Add("GalacticItemListView")
	self.players:Dock(LEFT)
	self.players:SetWidth(200)
	self.players:DockMargin(0, 0, 6, 0)
	self.players.OnRowSelected = function(this, index, line)
		self:SelectionChanged()
	end
	self.players.OnRowRightClick = function(this, lineId, line)
		local menu = DermaMenu()
		menu:AddOption("Copy SteamID", function() SetClipboardText(self:GetPlayerUniqueId(line.player)) end)
		menu:Open()
	end

	self.categories = parent:Add("DCategoryList")
	self.categories:SetWidth(200)
	self.categories:Dock(LEFT)

	self.content = parent:Add("GalacticItemListView")
	self.content:DockMargin(6, 0, 0, 0)
	self.content:Dock(FILL)
	self.content.OnRowSelected = function(this, index, line)
		this:ClearSelection()
		LocalPlayer():ConCommand(string.format("orb %q %q %q", line.command, self:GetPlayerUniqueId(self:GetSelected()), line.value))
	end

	self:PopulatePlayers()

	self:PermissionManagerUpdated()
end

function component:PermissionManagerUpdated()
	self.categories:Clear()

	for permission, permissionTbl in pairs(galactic.permissionManager.permissions) do
		if permissionTbl.commands then
			for command, comp in pairs(permissionTbl.commands) do

				if comp.guide then

					local category = comp.category or "Misc"

					if not self.categories[category] then
						self.categories[category] = vgui.Create("GalacticItemListView")
						self.categories[category]:DisableScrollbar(true)
						self.categories[category]:SetPaintBackground(false)
						table.insert(self.categoryPanels, self.categories[category])
						local collapsibleCategory = self.categories:Add(category)
						collapsibleCategory:SetContents(self.categories[category])
						self.categories[category].OnRowSelected = function(this, index, line)
							for k,v in ipairs(self.categoryPanels) do
								if v != this then
									v:ClearSelection()
								end
							end

							self.content:Clear()
							if table.IsEmpty(line.guide) then
								self.width = 406
								LocalPlayer():ConCommand(string.format("orb %q %q", line.command, self:GetPlayerUniqueId(self:GetSelected())))
								this:ClearSelection()
							else
								self.width = 612
								for _, guide in ipairs(line.guide) do
									
									local text = guide
									if istable(guide) then
										text = guide[1]
									end
									
									local value = guide
									if istable(guide) then
										value = guide[2]
									end

									local contentLine = self.content:AddLine(text)
									contentLine.command = line.command
									contentLine.value = value

								end
							end
						end
					end

					local line = self.categories[category]:AddLine(comp.title)
					line.command = command
					line.guide = comp.guide
					
				end




				/*if signature.guide then
					if table.IsEmpty(signature.guide) then
						local btn = self.categories:Add("DButton")
						btn:Dock(TOP)
						btn:SetText(signature.title)
						btn.DoClick = function(this)
							LocalPlayer():ConCommand(string.format("orb %q %q", command, self:GetPlayerUniqueId(self:GetSelected())))
						end
					else
						for _, guide in pairs(signature) do
							if istable(guide) then
								local btn = self.categories:Add("DButton")
								btn:Dock(TOP)
								btn:SetText(string.format("%s %s", signature.title, guide[2]))
								btn.DoClick = function(this)
									LocalPlayer():ConCommand(string.format("orb %q %q %q", command, self:GetPlayerUniqueId(self:GetSelected()), guide[1]))
								end
							else
								local btn = self.categories:Add("DButton")
								btn:Dock(TOP)
								btn:SetText(string.format("%s %s", signature.title, guide))
								btn.DoClick = function(this)
									LocalPlayer():ConCommand(string.format("orb %q %q %q", command, self:GetPlayerUniqueId(self:GetSelected()), guide))
								end
							end
						end
					end
				end*/
			end
		end
	end
end

function component:PopulatePlayers()
	self.players:Clear()

	for _, ply in ipairs(player.GetAll()) do
		self:AddPlayer(ply)
	end

	self:SelectionChanged()
end

function component:AddPlayer(ply)
	local line = self.players:AddLine(ply:Nick(), ply)
	line.player = ply
end

function component:RemovePlayerLine(lineId)
	self.players:RemoveLine(lineId)
	
	self:SelectionChanged()
end

function component:Think()
	if self.players:IsValid() then
		local plys = player.GetAll()

		for k, line in pairs(self.players:GetLines()) do
			if not line.player:IsValid() then
				self:RemovePlayerLine(k)
			else
				if line.label:GetText() != line.player:Nick() then
					line.label:SetText(line.player:Nick())
				end
			end
			table.RemoveByValue(plys, line.player)
		end

		for _, ply in ipairs(plys) do
			self:AddPlayer(ply)
		end
	end
end

function component:GetSelected()
	local _, line = self.players:GetSelectedLine()
	if line then
		return line.player
	end
end

function component:GetPlayerUniqueId(ply)
	return ply:IsBot() and ply:Nick():lower() or ply:SteamID()
end

function component:SelectionChanged()
	local ply = self:GetSelected()

	self.categories:SetEnabled(ply)
	self.content:SetEnabled(ply)
end

galactic:Register(component)
