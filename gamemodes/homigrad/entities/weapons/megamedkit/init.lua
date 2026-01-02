include("shared.lua")

local healsound = "snd_jack_bandage.wav"

function SWEP:Heal(ent)
	local used

	if ent.pain > 50 then
		ent.painlosing = 0
		ent.pain = 0
		used = true
	end

	if ent.Bloodlosing > 0 then
		ent.Bloodlosing = 0
		used = true
	end

	if ent.LeftLeg < 1 then
		ent.LeftLeg = 1
	end

	if ent.RightLeg < 1 then
		ent.RightLeg = 1
	end

	if ent.RightArm < 1 then
		ent.RightLeg = 1
	end

	if ent.LeftArm < 1 then
		ent.RightLeg = 1
	end

	if ent:Health() < 100 then
		ent:SetHealth(math.Clamp(ent:Health() + 75, 0, 100))
		used = true
	end

	if used then
		sound.Play(healsound, ent:GetPos(), nil, nil, .5)

		self:Remove()
	end
end