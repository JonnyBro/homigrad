include("shared.lua")

local healsound = Sound("snd_jack_bandage.wav")

function SWEP:Heal(ent)
	local usses

	if ent.pain > 50 then
		ent.painlosing = 0
		ent.pain = 0
		usses = true
	end

	if ent.Bloodlosing > 0 then
		ent.Bloodlosing = 0
		usses = true
	end

	if ent:Health() < 100 then
		ent:SetHealth(math.Clamp(self:GetOwner():Health() + 75, 0, 100))
		usses = true
	end

	if usses then
		sound.Play(healsound, ent:GetPos(), 75, 100, 0.5)

		self:Remove()
	end
end