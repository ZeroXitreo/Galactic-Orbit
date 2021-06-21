hook.Add("PostGamemodeLoaded", "GalacticFail", function(ply)
	if not galactic && not galacticFail then
		galacticFail = true
		if SERVER then
			MsgC(Color(255, 55, 55), "Galactic Core not installed, please install it from the workshop!\n")
		else
			chat.AddText(Color(255, 55, 55), "Galactic Core not installed, please install it from the workshop!")
		end
	end
end)