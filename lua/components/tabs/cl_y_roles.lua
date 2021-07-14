local component = {}
component.dependencies = {"menu", "theme", "roleManager", "permissionManager", "io"}
component.title = "Roles"

component.description = "Manage roles"
component.icon = "group"
component.width = 192 * 3 + 6 * 2
component.tickPath = "icon16/tick.png"

function component:OrbitRolePopulated()
	self.container.menu.roles:Clear()
	for id, role in ipairs(galactic.roleManager.roles) do
		self:OrbitRoleAdded(id, role)
	end
	self:RoleSelectedChanged()
end

function component:OrbitRoleRemoved(id)
	local moveInt = 0
	for i, line in pairs(self.container.menu.roles:GetLines()) do
		if line.id == id then
			self.container.menu.roles:RemoveLine(i)
			moveInt = moveInt + 1
		end
		line.id = line.id - moveInt
	end
	self:RoleSelectedChanged()
end

function component:OrbitRoleUpdated(id, role)
	for i, line in pairs(self.container.menu.roles:GetLines()) do
		if line.id == id then
			line.icon:SetImage(role.icon)
			line.label:SetText(role.title)
		end
	end
	self:RoleSelectedChanged()
end

function component:OrbitRoleAdded(id, role)
	self:AddRole(id, role)
end

function component:InitializeTab(parent)

	self.container = vgui.Create("DPanel", parent)
	self.container:Dock(FILL)
	self.container.Paint = nil

	self.container.menu = vgui.Create("DPanel", self.container)
	self.container.menu:Dock(LEFT)
	self.container.menu:SetWide(192)
	self.container.menu.Paint = nil

	self.container.menu.roles = self.container.menu:Add("GalacticItemListView")
	self.container.menu.roles:Dock(FILL)
	self.container.menu.roles:DisableScrollbar(true)
	self.container.menu.roles.OnRowRightClick = function(this, lineId, line)
		local role = self:GetSelectedRole()
		if role then
			local menu = DermaMenu()
			menu:AddOption("Copy shorthand", function()
				SetClipboardText(role.shorthand)
			end)
			menu:AddOption("Rename", function()
				galactic.io:String("Rename " .. role.title, "What would you like to rename " .. role.title .. " to?", function(name)
					LocalPlayer():ConCommand(string.format("orb renamerole %q %q", role.shorthand, name))
				end, "Apply", "Name", role.title)
			end)
			if not role.protected then
				menu:AddOption("Remove", function()
					galactic.io:Boolean("Remove role", "Are you sure you want to remove " .. role.title .. "?", function(result)
						if result and role == self:GetSelectedRole() then
							LocalPlayer():ConCommand(string.format("orb removerole %q", role.shorthand))
						end
					end)
				end)
			end
			if not role.allPermissions then
				menu:AddOption("Clear permissions", function()
					galactic.io:Boolean("Clear permissions", "Are you sure you want to clear all permissions for " .. role.title .. "?", function(result)
						if result then
							LocalPlayer():ConCommand(string.format("orb clearrolepermissions %q", role.shorthand))
						end
					end)
				end)
				menu:AddOption("Give all permissions", function()
					galactic.io:Boolean("Give all permissions", "Are you sure you want to give all permissions to " .. role.title .. "?", function(result)
						if result then
							for _, category in ipairs({{"permissions", "rolepermission"}, {"tools", "roletool"}, {"weapons", "roleweapon"}, {"entities", "roleentity"}}) do
								for _, line in ipairs(self.container.permissions.editor[category[1]]:GetLines()) do
									LocalPlayer():ConCommand(string.format("orb %q %q %q", category[2], role.shorthand, line.permission))
								end
							end
						end
					end)
				end)
			end
			menu:Open()
		end
	end
	self.container.menu.roles.OnRowSelected = function(this, index, line)
		self:RoleSelectedChanged()
	end

	self.container.menu.new = self.container.menu:Add("GaButton")
	self.container.menu.new:Dock(BOTTOM)
	self.container.menu.new:DockMargin(0, 6, 0, 0)
	self.container.menu.new:SetText("New role")
	self.container.menu.new.DoClick = function()
		galactic.io:String("Create new role", "Name of the new role", function(title)
			galactic.io:String("Create new role", "Shorthand for the role", function(shorthand)
				local role = self:GetSelectedRole()
				if role then
					galactic.io:Boolean("Create new role", "Inherit role from " .. role.title .. "?", function(result)
						if result then
							LocalPlayer():ConCommand(string.format("orb newrole %q %q %q", shorthand, title, role.shorthand))
							return
						else
							LocalPlayer():ConCommand(string.format("orb newrole %q %q", shorthand, title))
						end
					end, _, _)
				else
					LocalPlayer():ConCommand(string.format("orb newrole %q %q", shorthand, title))
				end
			end, "Next", "Shorthand", title:lower())
		end, "Next", "e.g. Donator", _)
	end

	self.container.configuration = self.container:Add("DPanel")
	self.container.configuration:Dock(LEFT)
	self.container.configuration:DockMargin(6, 0, 0, 0)
	self.container.configuration:SetWide(192)
	self.container.configuration.Paint = nil

	self.container.configuration.usergroup = self.container.configuration:Add("DComboBox")
	self.container.configuration.usergroup:Dock(TOP)
	self.container.configuration.usergroup:SetTall(24)
	self.container.configuration.usergroup:DockMargin(0, 0, 0, 6)
	self.container.configuration.usergroup:SetSortItems(false)
	for i, v in ipairs(galactic.roleManager.userGroups) do
		self.container.configuration.usergroup:AddChoice(v)
	end
	self.container.configuration.usergroup.OnSelect = function(this, index, text, data)
		local role = self:GetSelectedRole()
		if role then
			LocalPlayer():ConCommand(string.format("orb setrolegroup %q %q", role.shorthand, text))
		end
	end

	self.container.configuration.color = self.container.configuration:Add("DColorMixer")
	self.container.configuration.color:Dock(BOTTOM)
	self.container.configuration.color:SetPalette(true)
	self.container.configuration.color:SetTall(200)
	self.container.configuration.color:SetAlphaBar(false)
	self.container.configuration.color:DockMargin(0, 6, 0, 0)
	self.container.configuration.color.ValueChanged = function(this, col) self:OnColorValueChanged(col) end

	self.container.configuration.iconBrowser = self.container.configuration:Add("DIconBrowser");
	self.container.configuration.iconBrowser:Dock(FILL)
	self.container.configuration.iconBrowser.OnChange = function(this)
		local role = self:GetSelectedRole()
		if role then
			LocalPlayer():ConCommand(string.format("orb setroleicon %q %q", role.title, this:GetSelectedIcon()))
		end
	end

	self.container.permissions = self.container:Add("DPanel")
	self.container.permissions:Dock(FILL)
	self.container.permissions.Paint = nil
	self.container.permissions:DockMargin(6, 0, 0, 0)

	self.container.permissions.editor = self.container.permissions:Add("DCategoryList")
	self.container.permissions.editor:Dock(FILL)

	self.container.permissions.editor.permissions = vgui.Create("GalacticItemListView")
	self.container.permissions.editor.permissions:DisableScrollbar(true)
	self.container.permissions.editor.permissions:SetPaintBackground(false)
	local collapsibleCategory = self.container.permissions.editor:Add("Permissions")
	collapsibleCategory:SetContents(self.container.permissions.editor.permissions)
	self.container.permissions.editor.permissions.DoDoubleClick = function(this, index, line)
		local role = self:GetSelectedRole()
		if role then
			line.icon:ToggleVisible()
			LocalPlayer():ConCommand(string.format("orb rolepermission %q %q %q", role.shorthand, line.permission, line.icon:IsVisible() and 1 or 0))
			this:ClearSelection()
		end
	end

	self:PermissionManagerUpdated()

	for _, category in ipairs({{"tools", "Tools", "roletool"}, {"weapons", "Weapons", "roleweapon"}, {"entities", "Entities", "roleentity"}}) do
		local categoryKey = category[1]
		local categoryName = category[2]
		local categoryCommand = category[3]


		self.container.permissions.editor[categoryKey] = vgui.Create("GalacticItemListView")
		self.container.permissions.editor[categoryKey]:DisableScrollbar(true)
		self.container.permissions.editor[categoryKey]:SetPaintBackground(false)
		local collapsibleCategory = self.container.permissions.editor:Add(categoryName)
		collapsibleCategory:SetContents(self.container.permissions.editor[categoryKey])
		self.container.permissions.editor[categoryKey].DoDoubleClick = function(this, index, line)
			local role = self:GetSelectedRole()
			if role then
				line.icon:ToggleVisible()
				LocalPlayer():ConCommand(string.format("orb %q %q %q %q", categoryCommand, role.shorthand, line.permission, line.icon:IsVisible() and 1 or 0))
				this:ClearSelection()
			end
		end
		for key, name in SortedPairsByValue(galactic.permissionManager[categoryKey]) do
			local line = self.container.permissions.editor[categoryKey]:AddLine(name, self.tickPath)
			line.permission = key
		end
	end

	self:OrbitRolePopulated()
end

function component:PermissionManagerUpdated()
	if self.container then
		self.container.permissions.editor.permissions:Clear()

		for key, _ in SortedPairs(galactic.permissionManager.permissions) do
			local line = self.container.permissions.editor.permissions:AddLine(key, self.tickPath)
			line.permission = key
		end
	end
end

function component:Think()
	if self.container:IsValid() then
		local col = self.container.configuration.color:GetColor()

		local _, line = self.container.menu.roles:GetSelectedLine()
		if line then
			local role = galactic.roleManager.roles[line.id]
			if not role or role.color == col then
				self.triggerColorChange = false
			end

			if self.triggerColorChange and not input.IsMouseDown(MOUSE_LEFT) then
				self.triggerColorChange = false

				LocalPlayer():ConCommand(string.format("orb colorrole %q %q %q %q", role.title, col.r, col.g, col.b))
			end
		end
	end
end

function component:AddRole(id, role)

	local line = self.container.menu.roles:AddLine(role.title, role.icon)
	line.id = id
	line.role = role

	local imageSize = 16
	local dataHeight = self.container.menu.roles:GetDataHeight()
	local imagePadding = (dataHeight - imageSize) / 2

	line.moveDown = line:Add("DImageButton")
	line.moveDown:SetImage("icon16/arrow_down.png")
	line.moveDown:SetSize(imageSize, imageSize)
	line.moveDown:SetVisible(false)
	line.moveDown:Dock(RIGHT)
	line.moveDown:DockMargin(0, imagePadding, imagePadding, imagePadding)
	line.moveDown.DoClick = function()
		local _, line = self.container.menu.roles:GetSelectedLine()
		if line then
			local role = galactic.roleManager.roles[line.id]
			LocalPlayer():ConCommand(string.format("orb rolemovedown %q", role.shorthand))
		end
	end

	line.moveUp = line:Add("DImageButton")
	line.moveUp:SetImage("icon16/arrow_up.png")
	line.moveUp:SetSize(imageSize, imageSize)
	line.moveUp:SetVisible(false)
	line.moveUp:Dock(RIGHT)
	line.moveUp:DockMargin(0, imagePadding, imagePadding, imagePadding)
	line.moveUp.DoClick = function()
		local _, line = self.container.menu.roles:GetSelectedLine()
		if line then
			local role = galactic.roleManager.roles[line.id]
			LocalPlayer():ConCommand(string.format("orb rolemoveup %q", role.shorthand))
		end
	end

	return line
end

function component:OnColorValueChanged(col)
	self.triggerColorChange = true
end

function component:GetSelectedRole()
	local i, line = self.container.menu.roles:GetSelectedLine()
	if line then
		return galactic.roleManager.roles[line.id]
	end
end

function component:RoleSelectedChanged()
	local role = self:GetSelectedRole()

	for _, line in pairs(self.container.menu.roles:GetLines()) do
		line.moveUp:SetVisible(role and line.role == role and line.id != 1 and not galactic.roleManager.roles[line.id - 1].allPermissions)
		line.moveDown:SetVisible(role and line.role == role and line.id != table.Count(self.container.menu.roles:GetLines()) and not line.role.allPermissions)
	
		line:InvalidateLayout()
	end

	self.container.configuration:SetDisabled(not role)
	self.container.configuration.color:SetColor(role and role.color or Color(0, 0, 0))
	if role then
		if self.container.configuration.iconBrowser:GetSelectedIcon() != role.icon then
			local userGroupOnSelect = self.container.configuration.iconBrowser.OnChange
			self.container.configuration.iconBrowser.OnChange = function() end
			self.container.configuration.iconBrowser:SelectIcon(role and role.icon)
			self.container.configuration.iconBrowser.OnChange = userGroupOnSelect
			self.container.configuration.iconBrowser:ScrollToSelected()
		end
	end
	self.container.configuration.usergroup:SetDisabled(role and role.allPermissions or not role)
	local userGroupOnSelect = self.container.configuration.usergroup.OnSelect
	self.container.configuration.usergroup.OnSelect = function() end
	self.container.configuration.usergroup:ChooseOption(role and role.userGroup or "")
	self.container.configuration.usergroup.OnSelect = userGroupOnSelect

	self.container.permissions:SetDisabled(role and role.allPermissions or not role)
	for _, category in ipairs({"permissions", "tools", "weapons", "entities"}) do
		for _, line in ipairs(self.container.permissions.editor[category]:GetLines()) do
			line.icon:SetVisible(role and (role.allPermissions or role[category] and role[category][line.permission]))
		end
	end
end

galactic:Register(component)
