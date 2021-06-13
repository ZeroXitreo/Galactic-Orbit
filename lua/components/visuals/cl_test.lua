local component = {}
component.title = "Test client"

function component:PreDrawTranslucentRenderables()
	local ply = LocalPlayer()
	//self:GetSafeEyePosition(ply)

	/*for i,v in ipairs(player.GetAll()) do
		self:GetSurrounding(v)
	end*/
	//self:GetSurrounding(ply)
end


function component:GetSafeEyePosition(ply, extraFilter)

	// TODO: Add ledge detection

	local trace = ply:GetEyeTrace()
	local eyePos = ply:EyePos()
	local plyPos = ply:GetPos()
	local vec, vec2 = ply:GetCollisionBounds()
	local tr = {}
	tr.filter = {}
	if istable(extraFilter) then
		table.Merge(tr.filter, extraFilter)
	end
	table.insert(tr.filter, ply)

	// First line away from player
	render.DrawWireframeSphere(trace.HitPos, 2, 4, 4, Color(255, 0, 0, 255))

	tr.start = trace.HitPos
	tr.endpos = trace.HitPos - Vector(0, 0, vec2.z)
	local trace = util.TraceLine(tr)
	render.DrawWireframeSphere(trace.HitPos, 2, 4, 4, Color(255, 0, 255, 255))

	local hitPosHeightAdjusted = trace.HitPos
	local eyePos = eyePos - Vector(0, 0, trace.Fraction * (eyePos.z - plyPos.z))
	render.DrawWireframeSphere(trace.HitPos, 2, 4, 4, Color(255, 0, 0, 255))
	render.DrawWireframeBox(trace.HitPos, Angle(0, 0, 0), vec, vec2, Color(255, 0, 0, 255))


	// Box away from ground
	tr.start = trace.HitPos
	tr.endpos = eyePos
	local trace = util.TraceEntity(tr, ply)
	render.DrawWireframeBox(trace.StartPos, Angle(0, 0, 0), vec, vec2, Color(0, 255, 0, 255))


	// Box towards player
	tr.start = trace.StartPos
	tr.endpos = eyePos
	local trace = util.TraceEntity(tr, ply)
	render.DrawWireframeBox(trace.HitPos, Angle(0, 0, 0), vec, vec2, Color(0, 0, 255, 255))


	// Box towards endpoint
	tr.start = trace.HitPos
	tr.endpos = hitPosHeightAdjusted
	local trace = util.TraceEntity(tr, ply)
	render.DrawWireframeBox(trace.HitPos, Angle(0, 0, 0), vec, vec2, Color(255, 255, 255, 255))

	return trace.HitPos

end

function component:GetSurrounding(ply, extraFilter)
	local vec, vec2 = ply:GetCollisionBounds()
	local eyePos = ply:EyePos()
	local plyPos = ply:GetPos()
	local resolution = 8
	local distance = 64
	local tr = {}
	tr.filter = extraFilter or ply
	local spawnTbl = {}

	for i = 1, resolution do

		local b = (vec2.x + vec2.y)
		local degrees = i / resolution * 360
		local alpha = degrees
		local switch = 22.5

		while alpha > 45 do
			alpha = alpha - 45
			switch = -switch
		end

		local c = b / math.cos(math.rad(alpha - 22.5 + switch))



		tr.start = plyPos + Angle(0, degrees, 0):Forward() * c
		tr.endpos = plyPos + Angle(0, degrees, 0):Forward() * distance
		local trace = util.TraceEntity(tr, ply)

		local col = Color(0, 255, 0)

		if trace.Hit then
			col = Color(255, 255, 0)
		end

		if trace.StartSolid then
			col = Color(255, 0, 0)
		end

		render.DrawLine(tr.start, trace.HitPos, col)

		if not trace.StartSolid then
			render.DrawWireframeBox(trace.HitPos, Angle(0, 0, 0), vec, vec2)
			table.insert(spawnTbl, trace.HitPos)
		end
	end

	return spawnTbl
end

galactic:Register(component)