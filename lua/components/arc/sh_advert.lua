local component = {}
component.dependencies = {"messages", "data", "arc"}
component.namespace = "advertManager"
component.title = "Advert manager"

component.adverts = {}

if SERVER then
	component.fileName = "adverts"
end

function component:Constructor()
	if SERVER then
		self:Load()
	end
	galactic.arc:Setup(self.namespace, self.adverts)
end

if SERVER then
	function component:Load()
		for id, advert in pairs(self.adverts) do
			timer.Remove(self.namespace .. id)
		end
		if galactic.data:TableExists(self.fileName) then
			table.Empty(self.adverts)
			table.Merge(self.adverts, galactic.data:GetTable(self.fileName))
		end
		for id, advert in pairs(self.adverts) do
			timer.Create(self.namespace .. id, advert.delay * 60, 0, function()
				galactic.messages:Announce(unpack(advert.message))
			end)
		end
	end

	function component:Save()
		galactic.data:SetTable(self.fileName, self.adverts)
	end

	function component:Add(id, delay, args)
		if self.adverts[id] then
			table.Empty(self.adverts[id])
		else
			self.adverts[id] = {}
		end
		self.adverts[id].delay = delay
		self.adverts[id].message = {}

		while args[1] and args[2] do
			table.insert(self.adverts[id].message, {table.remove(args, 1), table.remove(args, 1)})
		end

		timer.Create(self.namespace .. id, self.adverts[id].delay * 60, 0, function()
			galactic.messages:Announce(unpack(self.adverts[id].message))
		end)

		galactic.arc:Add(self.namespace, id, self.adverts[id])
		self:Save()
	end

	function component:Remove(id)
		self.adverts[id] = nil
		timer.Remove(self.namespace .. id)

		galactic.arc:Remove(self.namespace, id)
		self:Save()
	end

	function component:SetId(id, newId)
		self.adverts[newId] = self.adverts[id]
		self.adverts[id] = nil

		galactic.arc:Add(self.namespace, newId, self.adverts[newId])
		galactic.arc:Remove(self.namespace, id)
		self:Save()
	end
end

if CLIENT then
	function component:ArcOnLoad(tblContent)
		table.Empty(self.adverts)
		table.Merge(self.adverts, tblContent)
		hook.Run("OrbitAdvertPopulate")
	end

	function component:ArcOnRemove(id)
		self.adverts[id] = nil
		hook.Run("OrbitAdvertDeleted", id)
	end

	function component:ArcOnAdd(id, tblContent)
		if self.adverts[id] then
			table.Empty(self.adverts[id])
			table.Merge(self.adverts[id], tblContent)
			hook.Run("OrbitAdvertUpdated", id, tblContent)
		else
			self.adverts[id] = tblContent
			hook.Run("OrbitAdvertCreated", id, tblContent)
		end
	end
end

galactic:Register(component)