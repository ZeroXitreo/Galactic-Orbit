local component = {}
component.namespace = "roleManager"
component.title = "Role manager"

component.roles = {}
component.userGroups = {"superadmin", "admin", "guest"}

if SERVER then
	component.dependencies = {"data", "pdManager", "arc"}
	component.fileName = "roles"

	function component:Load()
		table.Empty(self.roles)
		if galactic.data:TableExists(self.fileName) then
			table.Merge(self.roles, galactic.data:GetTable(self.fileName))
		else
			table.Merge(self.roles, self:GetDefault())
		end
	end

	function component:Save()
		galactic.data:SetTable(self.fileName, self.roles)
	end
end

function component:Constructor()
	if SERVER then
		self:Load()
	
		function galactic.registry.Entity:GetLower(plys)
			local plysFiltered = {}

			if self:ShouldBypassPermissions() then
				for _, pl in pairs(plys) do
					table.insert(plysFiltered, pl)
				end

				return plysFiltered
			end

			for _, pl in pairs(plys) do
				if self == pl then
					table.insert(plysFiltered, pl)
				elseif self:GreaterThan(pl) then
					table.insert(plysFiltered, pl)
				end
			end

			return plysFiltered
		end
	end

	function galactic.registry.Player:Roles()

		return component:RolesByInfo(self:Info())
	end

	function galactic.registry.Player:IsAdmin()
		local userGroup = "admin"
		if self:IsUserGroup(userGroup) or self:IsSuperAdmin() then return true end

		local roles = component:RolesByInfo(self:Info())
		for _, role in ipairs(roles) do
			if role.userGroup == userGroup then return true end
		end

		return false
	end

	function galactic.registry.Player:IsSuperAdmin()
		local userGroup = "superadmin"
		if self:IsUserGroup(userGroup) then return true end

		local roles = component:RolesByInfo(self:Info())
		for _, role in ipairs(roles) do
			if role.userGroup == userGroup then return true end
		end

		return false
	end

	function galactic.registry.Player:Color()
		local _, _, color = component:RolesByInfo(self:Info())
		return color
	end

	function galactic.registry.Player:Icon()
		local _, _, _, icon = component:RolesByInfo(self:Info())
		return icon
	end

	function galactic.registry.Entity:ShouldBypassPermissions()
		return SERVER and self.IsListenServerHost and self:IsListenServerHost() or game.SinglePlayer() or not self:IsValid()
	end

	function galactic.registry.Entity:HasPermission(permission)
		if self:ShouldBypassPermissions() then return true end

		local roles = self:Roles()
		for _, role in ipairs(roles) do
			if role.allPermissions or role.permissions and role.permissions[permission] then
				return true
			end
		end

		return false
	end

	function galactic.registry.Player:HasWeaponPermission(wep)
		if self:ShouldBypassPermissions() then return true end

		local roles = self:Roles()
		for _, role in ipairs(roles) do
			if role.allPermissions or role.weapons and role.weapons[wep] then
				return true
			end
		end

		return false
	end

	function galactic.registry.Player:HasEntityPermission(ent)
		if self:ShouldBypassPermissions() then return true end

		local roles = self:Roles()
		for _, role in ipairs(roles) do
			if role.allPermissions or role.entities and role.entities[ent] then
				return true
			end
		end

		return false
	end

	function galactic.registry.Player:HasToolPermission(tool)
		if self:ShouldBypassPermissions() then return true end

		local roles = self:Roles()
		for _, role in ipairs(roles) do
			if role.allPermissions or role.tools and role.tools[tool] then
				return true
			end
		end

		return false
	end

	function galactic.registry.Entity:Rank()
		if self:ShouldBypassPermissions() then return 0 end

		local roles = self:Roles()
		for i, role in ipairs(component.roles) do
			if table.HasValue(roles, role) then
				return i
			end
		end
	end

	function galactic.registry.Entity:GreaterThan(ply)

		return self:Rank(ply) < ply:Rank(ply)
	end

	function galactic.registry.Entity:Nick()
		if not self:IsValid() then
			return "Console"
		end
	end

	galactic.arc:Setup(self.namespace, self.roles)
end

function component:RolesByInfo(info)
	local rolesStrTbl = info.roles

	local rolesTbl = {}
	local guestRole = {}
	local authority = nil
	local color = Color(255, 255, 100)
	local icon = "icon16/user.png"
	for i, role in ipairs(galactic.roleManager.roles) do
		if role.shorthand == "guest" then
			guestRole = role
			if not authority or authority > i then
				authority = i
				color = Color(role.color.r, role.color.g, role.color.b)
				icon = role.icon
			end
		end
		if table.HasValue(rolesStrTbl, role.shorthand) then
			table.insert(rolesTbl, role)
			if not authority or authority > i then
				authority = i
				color = Color(role.color.r, role.color.g, role.color.b)
				icon = role.icon
			end
		end
	end

	if table.IsEmpty(rolesTbl) then
		table.insert(rolesTbl, guestRole)
	end

	return rolesTbl, authority, color, icon
end

function component:OnGamemodeLoaded()
	if engine.ActiveGamemode() == "sandbox" then
		function GAMEMODE:GetTeamColor(ent)
			return ent:Color()
		end
	end
end

if SERVER then

	function component:GetDefault()
		local roles = {}

		// Owner
		role = {}
		role.shorthand = "owner"
		role.title = "Owner"
		role.icon = "icon16/key.png"
		role.color = Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		role.userGroup = "superadmin"
		role.protected = true
		role.allPermissions = true
		table.insert(roles, role)

		// Guest
		role = {}
		role.shorthand = "guest"
		role.title = "Guest"
		role.icon = "icon16/user.png"
		role.color = Color(255, 255, 100)
		role.userGroup = "guest"
		role.protected = true
		table.insert(roles, role)

		return roles
	end

	function component:AddRole(shorthand, title, inheritFrom)
		role = {}

		role.shorthand = shorthand
		role.title = title
		role.icon = "icon16/user.png"
		role.color = Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		role.userGroup = "guest"


		for i, rol in ipairs(self.roles) do
			if rol.shorthand == inheritFrom then
				local roleToInheritFrom = rol
				role.icon = roleToInheritFrom.icon
				role.userGroup = roleToInheritFrom.userGroup

				if roleToInheritFrom.weapons then
					role.weapons = table.Copy(roleToInheritFrom.weapons)
				end

				if roleToInheritFrom.permissions then
					role.permissions = table.Copy(roleToInheritFrom.permissions)
				end

				if roleToInheritFrom.entities then
					role.entities = table.Copy(roleToInheritFrom.entities)
				end

				if roleToInheritFrom.tools then
					role.tools = table.Copy(roleToInheritFrom.tools)
				end
			end
		end

		local id = table.insert(self.roles, role)

		galactic.arc:Add(self.namespace, id, role)

		self:Save()
	end

	function component:RenameRole(shorthand, title)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand then
				role.title = title
				galactic.arc:Add(self.namespace, i, role)
			end
		end

		self:Save()
	end

	function component:SetColorRole(title, col)
		for i, role in ipairs(self.roles) do
			if role.title == title then
				role.color = col
				galactic.arc:Add(self.namespace, i, role)
			end
		end

		self:Save()
	end

	function component:RemoveRole(shorthand)
		// TODO: Remove roles from all players in all informations
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand and not role.protected then
				table.remove(self.roles, i)
				galactic.arc:Remove(self.namespace, i)
			end
		end

		self:Save()
	end

	function component:SetRoleIcon(title, icon)
		for i, role in ipairs(self.roles) do
			if role.title == title then
				role.icon = icon
				galactic.arc:Add(self.namespace, i, role)
			end
		end

		self:Save()
	end

	function component:SetRoleUserGroup(shorthand, userGroup)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand and table.HasValue(self.userGroups, userGroup) and role.userGroup != userGroup then
				role.userGroup = userGroup
				galactic.arc:Add(self.namespace, i, role)
			end
		end

		self:Save()
	end

	function component:AddRoleWeapon(shorthand, wep)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand then
				if not role.weapons then
					role.weapons = {}
				end
				if not role.weapons[wep] then
					role.weapons[wep] = true
					galactic.arc:Add(self.namespace, i, role)
				end
			end
		end

		self:Save()
	end

	function component:RemoveRoleWeapon(shorthand, wep)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand and role.weapons and role.weapons[wep] then
				role.weapons[wep] = nil
				galactic.arc:Add(self.namespace, i, role)
			end
		end

		self:Save()
	end

	function component:AddRoleEntity(shorthand, ent)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand then
				if not role.entities then
					role.entities = {}
				end
				if not role.entities[ent] then
					role.entities[ent] = true
					galactic.arc:Add(self.namespace, i, role)
				end
			end
		end

		self:Save()
	end

	function component:RemoveRoleEntity(shorthand, ent)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand and role.entities and role.entities[ent] then
				role.entities[ent] = nil
				galactic.arc:Add(self.namespace, i, role)
			end
		end

		self:Save()
	end

	function component:AddRoleTool(shorthand, tool)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand then
				if not role.tools then
					role.tools = {}
				end
				if not role.tools[tool] then
					role.tools[tool] = true
					galactic.arc:Add(self.namespace, i, role)
				end
			end
		end

		self:Save()
	end

	function component:RemoveRoleTool(shorthand, tool)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand and role.tools and role.tools[tool] then
				role.tools[tool] = nil
				galactic.arc:Add(self.namespace, i, role)
			end
		end

		self:Save()
	end

	function component:AddRolePermission(shorthand, permission)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand then
				if not role.permissions then
					role.permissions = {}
				end
				if not role.permissions[permission] then
					role.permissions[permission] = true
					galactic.arc:Add(self.namespace, i, role)
				end
			end
		end

		self:Save()
	end

	function component:RemoveRolePermission(shorthand, permission)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand and role.permissions and role.permissions[permission] then
				role.permissions[permission] = nil
				galactic.arc:Add(self.namespace, i, role)
			end
		end

		self:Save()
	end

	function component:MoveRoleUp(shorthand)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand and i != 1 and not self.roles[i - 1].allPermissions then
				table.remove(self.roles, i)
				table.insert(self.roles, i - 1, role)

				galactic.arc:Add(self.namespace, (i - 1), role)
				galactic.arc:Add(self.namespace, i, self.roles[i])
			end
		end

		self:Save()
	end

	function component:MoveRoleDown(shorthand)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand and not role.allPermissions and i != #self.roles then
				table.remove(self.roles, i)
				table.insert(self.roles, i + 1, role)

				galactic.arc:Add(self.namespace, (i + 1), role)
				galactic.arc:Add(self.namespace, i, self.roles[i])

				break
			end
		end

		self:Save()
	end

	function component:ClearPermissions(shorthand)
		for i, role in ipairs(self.roles) do
			if role.shorthand == shorthand then
				role.weapons = nil
				role.entities = nil
				role.tools = nil
				role.permissions = nil
				galactic.arc:Add(self.namespace, i, role)
			end
		end

		self:Save()
	end

end

if CLIENT then
	function component:ArcOnLoad(tblContent)
		table.Empty(self.roles)
		table.Merge(self.roles, tblContent)
		hook.Run("OrbitRolePopulated")
	end

	function component:ArcOnRemove(id)
		id = tonumber(id)
		table.remove(self.roles, id)
		hook.Run("OrbitRoleRemoved", id)
	end

	function component:ArcOnAdd(id, tblContent)
		id = tonumber(id)
		if self.roles[id] then
			table.Empty(self.roles[id])
			table.Merge(self.roles[id], tblContent)
			hook.Run("OrbitRoleUpdated", id, tblContent)
		else
			self.roles[id] = tblContent
			hook.Run("OrbitRoleAdded", id, tblContent)
		end
	end
end

galactic:Register(component)
