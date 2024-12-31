bloodparticels1 = bloodparticels1 or {}

local tr = {
	filter = function(ent) return not ent:IsPlayer() and not ent:IsRagdoll() end
}

local vecDown = Vector(0, 0, -40)
local vecZero = Vector(0, 0, 0)

bloodparticels_hook[1] = function(anim_pos)
	for i = 1, #bloodparticels1 do
		local part = bloodparticels1[i]

		render.SetMaterial(part[4])
		render.DrawSprite(LerpVector(anim_pos, part[2], part[1]), part[5], part[6])
	end
end

bloodparticels_hook[2] = function(mul)
	for i = 1, #bloodparticels1 do
		local part = bloodparticels1[i]
		if not part then break end

		local pos = part[1]
		local posSet = part[2]
		tr.start = posSet
		tr.endpos = tr.start + part[3] * mul
		result = util.TraceLine(tr)

		local hitPos = result.HitPos

		if result.Hit then
			table.remove(bloodparticels1, i)

			local dir = result.HitNormal

			util.Decal("Blood", hitPos + dir, hitPos - dir)
			sound.Play("ambient/water/drip" .. math.random(1, 4) .. ".wav", hitPos, 60, math.random(230, 240))

			continue
		else
			pos:Set(posSet)
			posSet:Set(hitPos)
		end

		part[3] = LerpVector(0.25 * mul, part[3], vecZero)
		part[3]:Add(vecDown)
	end
end