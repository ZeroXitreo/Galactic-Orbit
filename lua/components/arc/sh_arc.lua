local component = {}
component.dependencies = {"network"}
component.namespace = "arc"
component.title = "Arc networking"

component.netLoad = "Load"
component.netRemove = "Remove"
component.netAdd = "Add"

function component:Setup(namespace, tblContent)
	local nsClass = galactic[namespace]

	if SERVER then
		util.AddNetworkString(namespace .. self.netLoad)
		util.AddNetworkString(namespace .. self.netRemove)
		util.AddNetworkString(namespace .. self.netAdd)

		timer.Simple(0, function()
			net.Start(namespace .. self.netLoad)
			net.WriteCompressedTable(tblContent)
			net.Broadcast()
		end)

		function nsClass:PlayerLoaded(ply)
			net.Start(namespace .. component.netLoad)
			net.WriteCompressedTable(tblContent)
			net.Send(ply)
		end
	else
		net.Receive(namespace .. self.netLoad, function()
			local tblContent = net.ReadCompressedTable()
			if nsClass.ArcOnLoad then
				nsClass:ArcOnLoad(tblContent)
			end
		end)

		net.Receive(namespace .. self.netRemove, function()
			local id = net.ReadString()
			if nsClass.ArcOnRemove then
				nsClass:ArcOnRemove(id)
			end
		end)

		net.Receive(namespace .. self.netAdd, function()
			local id = net.ReadString()
			local tblContent = net.ReadCompressedTable()
			if nsClass.ArcOnAdd then
				nsClass:ArcOnAdd(id, tblContent)
			end
		end)
	end
end

function component:Add(namespace, id, tblContent)
	net.Start(namespace .. self.netAdd)
	net.WriteString(id)
	net.WriteCompressedTable(tblContent)
	net.Broadcast()
end

function component:Remove(namespace, id)
	net.Start(namespace .. self.netRemove)
	net.WriteString(id)
	net.Broadcast()
end

galactic:Register(component)
