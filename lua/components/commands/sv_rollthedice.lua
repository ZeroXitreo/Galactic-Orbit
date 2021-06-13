local component = {}
component.title = "Roll the dices"
component.description = "Roll the dices, this could be fun"
component.command = "roll"
component.permission = component.title

function component:Execute(ply, args)
	if not ply.rtdTimer or ply.rtdTimer < CurTime() then
		local announcement = {}
		table.insert(announcement, {"blue", ply:Nick()})
		table.insert(announcement, {"text", " rolled the dice and "})

		local roll = math.random(1, 2)
		if roll == 1 then
			local delay = math.random(5, 15)
			ply:Lock()
			timer.Simple(delay, function()
				ply:UnLock()
			end)
			
			table.insert(announcement, {"text", "has been "})
			table.insert(announcement, {"red", "paralysed"})
			table.insert(announcement, {"text", " for "})
			table.insert(announcement, {"yellow", string.NiceTime(delay)})
		elseif roll == 2 then
			local amount = math.random(10, 50)
			ply:SetArmor(ply:Armor() + amount)
			
			table.insert(announcement, {"text", "found some "})
			table.insert(announcement, {"red", "armor"})
			table.insert(announcement, {"text", " with "})
			table.insert(announcement, {"yellow", amount})
			table.insert(announcement, {"text", " left on it"})
		end

		ply.rtdTimer = CurTime() + 60

		galactic.messages:Announce(unpack(announcement))
	else
		local announcement = {}
		table.insert(announcement, {"text", "Please wait "})
		table.insert(announcement, {"red", string.NiceTime(ply.rtdTimer - CurTime())})
		table.insert(announcement, {"text", " before you roll again"})
		galactic.messages:Notify(ply, unpack(announcement))
	end
end

function component:RollTheDice( ply )
	local choice = math.random( 1, 7 )
	if ( choice == 1 ) then
		local hp = math.random( 5, 20 ) * 10
		ply:SetHealth( ply:Health() + hp )
		
		return "received " .. hp .. " health"
	elseif ( choice == 2 ) then
		ply:Kill()
		
		return "was killed by a mysterious virus"
	elseif ( choice == 3 ) then
		ply:SetHealth( ply:Health() * 0.1 )
		
		return "was struck by lightning"
	elseif ( choice == 4 ) then
		ply:StripWeapons()
		
		return "was robbed by a homeless guy"
	elseif ( choice == 5 ) then
		ply:Ignite( 20, 1 )
		
		return "was ignited by a pyromaniac"
	elseif ( choice == 6 ) then
		ply:GodEnable()
		timer.Simple( 10, function() ply:GodDisable() end )
		
		return "suddenly received invincibility for 10 seconds"
	end
end

galactic:Register(component)