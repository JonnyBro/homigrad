bloodparticels2 = bloodparticels2 or {}

local tr = {
	filter = function(ent) return not ent:IsPlayer() and not ent:IsRagdoll() end
}

local vecZero = Vector(0, 0, 0)
local color = Color(255, 255, 255, 255)

bloodparticels_hook[3] = function(anim_pos)
	local time = CurTime()

	for i = 1, #bloodparticels2 do
		local part = bloodparticels2[i]

		color.a = 255 * (part[7] - time) / part[8]

		render.SetMaterial(part[4])
		render.DrawSprite(LerpVector(anim_pos, part[2], part[1]), part[5], part[6], color)
	end
end

bloodparticels_hook[4] = function(mul)
	local time = CurTime()

	for i = 1, #bloodparticels2 do
		local part = bloodparticels2[i]
		if not part then break end

		local pos = part[1]
		local posSet = part[2]

		tr.start = posSet
		tr.endpos = tr.start + part[3] * mul
		result = util.TraceLine(tr)

		local hitPos = result.HitPos

		if result.Hit or part[7] - time <= 0 then
			table.remove(bloodparticels2, i)
			continue
		else
			pos:Set(posSet)
			posSet:Set(hitPos)
		end

		part[3] = LerpVector(0.5 * mul, part[3], vecZero)
	end
end