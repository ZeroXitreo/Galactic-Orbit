local component = {}
component.dependencies = {"permissionManager", "roleManager"}
component.title = "Player Loadout"

function component:PlayerSpawn(ply)
	if engine.ActiveGamemode() == "sandbox" then
		timer.Simple(0, function()
			for _, wep in ipairs(ply:GetWeapons()) do
				if not ply:HasWeaponPermission(wep:GetClass()) then
					ply:StripWeapon(wep:GetClass())
				end
			end
		end)
	end
end

galactic:Register(component)
