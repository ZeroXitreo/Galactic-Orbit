local component = {}
component.dependencies = {"messages", "roleManager", "consoleManager"}
component.title = "Unlimited ammunition"
component.description = "Give unlimited ammunition to players"
component.command = "uammo"
component.tip = "[players|1/0] [1/0]"
component.permission = component.title
component.category = "Manipulation"
component.guide = {{"Enable", 1}, {"Disable", 0}}

function component:Execute(ply, args)
	local enabled = galactic.consoleManager:TryArgToBool(args, #args, true)
	local players = galactic.consoleManager:GetLowerPlayers(ply, args)
	if players then
		for _, pl in ipairs(players) do
			pl.hasUnlimitedAmmunition = enabled
			if enabled then
				for _, wep in ipairs(pl:GetWeapons()) do
					self:FillClips(pl, wep)
				end
			end
		end
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		if enabled then
			table.insert(announcement, {"text", " has given unlimited ammunition to "})
		else
			table.insert(announcement, {"text", " has taken unlimited ammunition from "})
		end
		galactic.messages:MessageList(announcement, players, #player.GetAll(), function(ply) return ply:Nick() end)
		galactic.messages:Announce(unpack(announcement))
	end
end

function component:Tick()
	for _, ply in ipairs( player.GetAll() ) do
		if ply.hasUnlimitedAmmunition and ply:Alive() and ply:GetActiveWeapon() then
			self:FillClips(ply, ply:GetActiveWeapon())
		end
	end
end

function component:FillClips(ply, wep)
	if wep:Clip1() < 1337 then wep:SetClip1(1337) end
	if wep:Clip2() < 1337 then wep:SetClip2(1337) end
	if ply:GetAmmoCount(wep:GetPrimaryAmmoType()) < 1337 then ply:SetAmmo(1337, wep:GetPrimaryAmmoType()) end
	if ply:GetAmmoCount(wep:GetSecondaryAmmoType()) < 1337 then ply:SetAmmo(1337, wep:GetSecondaryAmmoType()) end
end

galactic:Register(component)
