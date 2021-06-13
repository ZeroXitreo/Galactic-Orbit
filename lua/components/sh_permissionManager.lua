local component = {}
component.dependencies = {"network"}
component.namespace = "permissionManager"
component.title = "Permission manager"

component.nwString = component.namespace

component.permissions = component.permissions or {}
component.weapons = component.weapons or {}
component.tools = component.tools or {}
component.entities = component.entities or {}

if SERVER then

	function component:Constructor()
		util.AddNetworkString(self.nwString)
		for _, comp in ipairs(galactic.components) do
			self:ComponentInitialized(comp)
		end
	end

	function component:ComponentInitialized(comp)
		if comp.permission then
			self:AddPermission(comp)
		end
	end

	function component:AddPermission(comp)
		if not self.permissions[comp.permission] then

			local permissionTable = {}
			permissionTable.permission = comp.permission
			permissionTable.command = comp.command
			permissionTable.tip = comp.tip

			self.permissions[comp.permission] = permissionTable
		end


		if comp.command then
			if not self.permissions[comp.permission].commands then
				self.permissions[comp.permission].commands = {}
			end

			self.permissions[comp.permission].commands[comp.command] = {} // Specific command

			if comp.tip then
				self.permissions[comp.permission].commands[comp.command].tip = comp.tip
			end

			if comp.title then
				self.permissions[comp.permission].commands[comp.command].title = comp.title
			end

			if comp.guide then
				self.permissions[comp.permission].commands[comp.command].guide = comp.guide
			end

			if comp.category then
				self.permissions[comp.permission].commands[comp.command].category = comp.category
			end
		end
	end

	function component:PlayerLoaded(ply)
		net.Start(self.nwString)
		net.WriteCompressedTable(self.permissions)
		net.Send(ply)
	end

else // Client
	component.hookRunPermissionManagerUpdated = "PermissionManagerUpdated"
	function component:Constructor()
		net.Receive(self.nwString, function(len) self:Receive(len) end)
	end

	function component:PostGamemodeLoaded()
		self:InitWeapons()
		self:InitEntities()
		self:InitTools()
	end

	function component:Receive(len)
		self.permissions = net.ReadCompressedTable()
		hook.Run(self.hookRunPermissionManagerUpdated)
	end

	function component:InitWeapons()
		self.weapons = {}
		for key, wep in pairs(list.Get("Weapon")) do
			self.weapons[key] = wep.PrintName
		end
	end

	function component:InitEntities()
		self.entities = {}
		for key, ent in pairs(list.Get("SpawnableEntities")) do
			self.entities[key] = ent.PrintName
		end
	end

	function component:InitTools()
		self.tools = {}
		local toolMenus = spawnmenu.GetTools()
		for _, toolMenu in pairs(toolMenus) do
			for _, categories in ipairs(toolMenu.Items) do
				for _, line in ipairs(categories) do
					if line.Command != "" then
						self.tools[line.ItemName] = line.Text
					end
				end
			end
		end
	end
end

galactic:Register(component)
