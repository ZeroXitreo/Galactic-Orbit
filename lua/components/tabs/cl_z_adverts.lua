local component = {}
component.dependencies = {"menu", "advertManager", "theme"}
component.title = "Adverts"

component.description = "Manage adverts"
component.icon = "comment"
component.width = 256 * 2

function component:OrbitAdvertPopulate()
	self.container.menu.adverts:Clear()
	for id, advert in pairs(galactic.advertManager.adverts) do
		self:OrbitAdvertCreated(id, advert)
	end
	self:SelectionChanged()
end

function component:OrbitAdvertDeleted(id)
	for i, line in pairs(self.container.menu.adverts:GetLines()) do
		if line.id == id then
			self.container.menu.adverts:RemoveLine(i)
			self:SelectionChanged()
			break
		end
	end
end

function component:OrbitAdvertUpdated(id, advert)
	for _, line in pairs(self.container.menu.adverts:GetLines()) do
		if line.id == id then
			line:SetColumnText(1, id)
		end
	end
	if id == self:GetSelected() then
		self:SelectionChanged()
	end
end

function component:OrbitAdvertCreated(id, advert)
	local line = self.container.menu.adverts:AddLine(tostring(id))
	line.id = id
	self.container.menu.adverts:SortByColumn(1)
end

function component:SelectionChanged()
	local id, advert = self:GetSelected()

	self.container.details.delay:SetEnabled(id)

	self.container.menu.rename:SetEnabled(id)
	self.container.menu.remove:SetEnabled(id)

	self.container.details:SetEnabled(id)

	if id then
		self.container.details.delay:SetValue(advert.delay)

		local shouldUpdate = false
		local msg = self:GetMessageFromSelected()
		local contextChildren = self.container.details.context:GetChildren()

		if msg and not table.IsEmpty(advert.message) and not table.IsEmpty(contextChildren) and #msg == #advert.message then
			for i,v in ipairs(msg) do
				if v[1] != advert.message[i][1] or v[2] != advert.message[i][2] then
					shouldUpdate = true
				end
			end
		else
			shouldUpdate = true
		end

		if shouldUpdate then
			for _, pnl in ipairs(contextChildren) do
				pnl:Remove()
			end

			self:AddAdvertTextEntry(advert.message[1] and advert.message[1][1], advert.message[1] and advert.message[1][2])

			for i = 2, #advert.message do
				self:AddAdvertTextEntry(advert.message[i] and advert.message[i][1], advert.message[i] and advert.message[i][2])
			end
		end
	end
end

function component:GetSelected()
	local i, line = self.container.menu.adverts:GetSelectedLine()
	if line and galactic.advertManager.adverts[line.id] then
		return line.id, galactic.advertManager.adverts[line.id]
	end
end

function component:InitializeTab(parent)
	self.container = parent:Add("DPanel")
	self.container:Dock(FILL)
	self.container.Paint = nil

	self.container.menu = self.container:Add("DPanel")
	self.container.menu:Dock(LEFT)
	self.container.menu:SetWide(192)
	self.container.menu.Paint = nil

	self.container.menu.adverts = self.container.menu:Add("DListView")
	self.container.menu.adverts:Dock(FILL)
	self.container.menu.adverts:SetMultiSelect(false)
	self.container.menu.adverts:SetHideHeaders(true)
	self.container.menu.adverts:AddColumn("")
	self.container.menu.adverts:SetDataHeight(24)
	self.container.menu.adverts:SetHeaderHeight(0)
	self.container.menu.adverts:DisableScrollbar(true)
	self.container.menu.adverts.OnRowSelected = function(this, index, line)
		self:SelectionChanged()
	end

	self.container.menu.remove = self.container.menu:Add("DButton")
	self.container.menu.remove:Dock(BOTTOM)
	self.container.menu.remove:DockMargin(0, 6, 0, 0)
	self.container.menu.remove:SetTall(24)
	self.container.menu.remove:SetText("Remove")
	self.container.menu.remove:SetDisabled(true)
	self.container.menu.remove.DoClick = function()
		local id, advert = self:GetSelected()
		if advert then
			galactic.io:Boolean("Remove advert", "Are you sure you want to remove " .. id .. "?", function(result)
				local _, advertTemp = self:GetSelected()
				if result and advert == advertTemp then
					LocalPlayer():ConCommand(string.format("orb advertremove %q", id))
				end
			end)
		end
	end

	self.container.menu.new = self.container.menu:Add("DButton")
	self.container.menu.new:Dock(BOTTOM)
	self.container.menu.new:SetTall(24)
	self.container.menu.new:DockMargin(0, 6, 0, 0)
	self.container.menu.new:SetText("New ad")
	self.container.menu.new.DoClick = function()
		galactic.io:String("Create new advert", "Title of the new advert", function(id)
			galactic.io:String("Create new advert", "Delay in minutes (number)", function(delay)
				LocalPlayer():ConCommand(string.format("orb advertadd %q %q", id or "", delay or ""))
			end, "Create")
		end, "Next")
	end

	self.container.menu.rename = self.container.menu:Add("DButton")
	self.container.menu.rename:Dock(BOTTOM)
	self.container.menu.rename:SetTall(24)
	self.container.menu.rename:DockMargin(0, 6, 0, 0)
	self.container.menu.rename:SetText("Rename")
	self.container.menu.rename:SetDisabled(true)
	self.container.menu.rename.DoClick = function()
		local id, advert = self:GetSelected()
		if id then
			galactic.io:String("Rename " .. id, "What would you like to rename " .. id .. " to?", function(name)
				LocalPlayer():ConCommand(string.format("orb advertid %q %q", id, name))
			end, "Rename", "Name", id)
		end
	end

	self.container.details = self.container:Add("DPanel")
	self.container.details:Dock(FILL)
	self.container.details:DockMargin(6, 0, 0, 0)
	self.container.details:DockPadding(12, 12, 12, 12)

	self.container.details.delayLabel = self.container.details:Add("DLabel")
	self.container.details.delayLabel:Dock(TOP)
	self.container.details.delayLabel:SetColor(Color(0, 0, 0))
	self.container.details.delayLabel:SetText("Interval in minutes:")

	self.container.details.delay = self.container.details:Add("DNumberWang")
	self.container.details.delay:Dock(TOP)
	self.container.details.delay:DockMargin(0, 0, 0, 6)
	self.container.details.delay:SetMin(1)
	self.container.details.delay:SetMax(60)
	self.container.details.delay:HideWang()
	self.container.details.delay.OnGetFocus = function()
		galactic.menu:StartKeyFocus()
	end
	self.container.details.delay.OnLoseFocus = function(this)
		galactic.menu:EndKeyFocus()
		local id, advert = self:GetSelected()
		if id and advert.delay != this:GetValue() then
			self:AddAdvert()
		end
	end

	self.container.details.context = self.container.details:Add("DPanel")
	self.container.details.context:Dock(FILL)
	self.container.details.context.Paint = nil

	self:OrbitAdvertPopulate()
end

function component:AddAdvertTextEntry(color, text)
	local singlebar = self.container.details.context:Add("DPanel")
	singlebar:Dock(TOP)
	singlebar.Paint = nil

	singlebar.colPreview = singlebar:Add("DTextEntry")
	singlebar.colPreview:Dock(LEFT)
	singlebar.colPreview:SetWide(24)
	singlebar.colPreview:SetText(color or "text")
	singlebar.colPreview.Paint = function(this, width, height)
		surface.SetDrawColor(galactic.theme.colors[singlebar.color:GetValue()] or Color(0, 0, 0, 0))
		surface.DrawRect(0, 0, width, height)
	end

	singlebar.color = singlebar:Add("DTextEntry")
	singlebar.color:Dock(LEFT)
	singlebar.color:SetWide(40)
	singlebar.color:SetText(color or "text")
	singlebar.color.OnGetFocus = function()
		galactic.menu:StartKeyFocus()
	end
	singlebar.color.OnLoseFocus = function()
		galactic.menu:EndKeyFocus()
		self:AddAdvert()
	end

	singlebar.entry = singlebar:Add("DTextEntry")
	singlebar.entry:Dock(FILL)
	singlebar.entry:SetText(text or "")
	singlebar.entry.OnGetFocus = function()
		galactic.menu:StartKeyFocus()
	end
	singlebar.entry.OnLoseFocus = function()
		galactic.menu:EndKeyFocus()
		self:AddAdvert()
	end
	singlebar.add = singlebar:Add("DButton")
	singlebar.add:SetText("+")
	singlebar.add:SetWide(20)
	singlebar.add:Dock(RIGHT)
	singlebar.add.DoClick = function(this)
		local siblings = self.container.details.context:GetChildren()
		if siblings[#siblings] == this:GetParent() then
			self:AddAdvertTextEntry()
		else
			for i,v in ipairs(siblings) do
				if v == this:GetParent() then
					if i + 1 == #siblings then
						siblings[i].add:SetText("+")
					end
					siblings[i + 1]:Remove()
					break
				end
			end
		end
		timer.Simple(0, function() self:AddAdvert() end)
	end

	local siblings = self.container.details.context:GetChildren()
	if siblings[#siblings - 1] then
		siblings[#siblings - 1].add:SetText("-")
	end
end

function component:AddAdvert()
	local id, advert = self:GetSelected()
	if id then
		local cmd = string.format("orb advertadd %q %q", id, self.container.details.delay:GetValue())
		local messages = self.container.details.context:GetChildren()
		for i,v in ipairs(messages) do
			cmd = cmd .. string.format(" %q %q", v.color:GetText(), v.entry:GetText())
		end
		LocalPlayer():ConCommand(cmd)
	end
end

function component:GetMessageFromSelected()
	local id, advert = self:GetSelected()
	if id then
		local msg = {}
		for i,v in ipairs(self.container.details.context:GetChildren()) do
			table.insert(msg, {v.color:GetText(), v.entry:GetText()})
		end
		return msg
	end
end

galactic:Register(component)
