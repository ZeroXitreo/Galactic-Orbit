local component = {}
if CLIENT then
	component.dependencies = {"theme"}
end
component.title = "Player name tags"
component.description = "Display player name tags"
component.permission = component.title
component.secondsTillAFK = 300

function component:Constructor()
	local PLAYER = FindMetaTable("Player")
	function PLAYER:IsAFK()
		return self:GetNWInt("isAFK") < os.time() - component.secondsTillAFK or false
	end
end

if SERVER then

	function component:PlayerSpawn(ply)
		ply:SetNWInt("isAFK", os.time())
	end

	function component:KeyPress(ply)
		ply:SetNWInt("isAFK", os.time())
	end

	function component:PlayerSay( ply )
		ply:SetNWInt("isAFK", os.time())
	end

else

	component.iconUser = Material( "icon16/user.png" )
	component.iconChat = Material( "icon16/comments.png" )
	component.iconAFK = Material( "icon16/hourglass.png" )

	local icons = {}

	function component:HUDPaintBackground()



		if !LocalPlayer():HasPermission(component.permission) then return end
		if engine.ActiveGamemode() != "sandbox" then return end
		
		// Set order of players and exclude the ones who should not be drawn
		local players = player.GetAll()
		for i = #players, 1, -1 do
			local ply = players[i]

			if ply == LocalPlayer() or not ply:Alive() then
				table.remove(players, i)
			else
				local td = {}
				td.start = LocalPlayer():GetShootPos()
				td.endpos = ply:GetShootPos()
				td.filter = player.GetAll()
				td.mask = MASK_SHOT
				local trace = util.TraceLine(td)

				if trace.Hit then
					table.remove(players, i)
				end
			end
		end

		table.sort(players, function(a, b)
			local ply = LocalPlayer():GetShootPos()
			local distanceA = ply:Distance(a:GetShootPos())
			local distanceB = ply:Distance(b:GetShootPos())
			return distanceA > distanceB
		end)

		local distanceBeforeFalloff = 512
		local falloffMax = 2048
		local padding = 0
		local border = 2
		local iconSize = 16
		for _, pl in ipairs(players) do

			if not icons[pl:Icon()] then
				icons[pl:Icon()] = Material(pl:Icon())
			end





			surface.SetFont("GalacticDefault")
			local w = surface.GetTextSize(pl:Nick()) + iconSize + padding
			local h = iconSize
			local padding = 4
			local radius = galactic.theme.round
			local extraPadding = 4
			
			local pos = pl:GetShootPos()
			
			local drawPos = pos:ToScreen()
			drawPos.x = drawPos.x - w / 2
			drawPos.y = drawPos.y - h - 24 - padding
			
			local col = GAMEMODE:GetTeamColor(pl)
			local distance = LocalPlayer():GetShootPos():Distance(pos)
			local alpha = 255
			if (distance > distanceBeforeFalloff) then
				alpha = 255 - math.Clamp( ( distance - distanceBeforeFalloff ) / ( falloffMax - distanceBeforeFalloff ) * 255, 0, 255 )
			end
			

			local backgroundColor = Color(galactic.theme.colors.blockFaint.r, galactic.theme.colors.blockFaint.g, galactic.theme.colors.blockFaint.b, alpha)
			local accentColor = Color(col.r, col.g, col.b, alpha)
			draw.RoundedBoxEx(radius, drawPos.x - padding * 1, drawPos.y, padding, h + padding * 2, accentColor, true, false, true, false )
			draw.RoundedBoxEx(radius, drawPos.x, drawPos.y, w + padding * 4, h + padding * 2, backgroundColor, false, true, false, true)
			
			if pl:IsTyping() then
				surface.SetMaterial( self.iconChat )
			elseif pl:IsAFK() then
				surface.SetMaterial( self.iconAFK )
			elseif icons[pl:Icon()] then
				surface.SetMaterial(icons[pl:Icon()])
			else
				surface.SetMaterial( self.iconUser )
			end
			
			surface.SetDrawColor(255, 255, 255, alpha)
			surface.DrawTexturedRect(drawPos.x + padding, drawPos.y + padding, iconSize, iconSize)

			local fontHeight = draw.GetFontHeight("GalacticDefault")
			local setFontHeight = drawPos.y - (fontHeight - iconSize - padding * 2) / 2
			draw.WordBox(0, drawPos.x + iconSize + padding * 2, setFontHeight, pl:Nick(), "GalacticDefault", Color(0, 0, 0, 0), accentColor)
		end
	end
end

galactic:Register(component)
