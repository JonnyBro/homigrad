include("shared.lua")

local healsound = Sound("snd_jack_bandage.wav")

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Delay)

	local owner = self:GetOwner()

	if self:Heal(owner) then
		owner:SetAnimation(PLAYER_ATTACK1)

		self:Remove()

		self:GetOwner():SelectWeapon("weapon_hands")
	end
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Delay)

	local owner = self:GetOwner()
	local trace = self:GetEyeTraceDist(150)

	local ent = trace.Entity
	ent = (ent:IsPlayer() and ent) or RagdollOwner(ent) or (ent:GetClass() == "prop_ragdoll" and ent)
	if not ent then return end

	if self:Heal(ent) then
		if ent:IsPlayer() then
			local dmg = DamageInfo()
				dmg:SetDamage(-5)
				dmg:SetAttacker(self)
			local att = self:GetOwner()

			if GuiltLogic(att, ent, dmg, true) then
				att.Guilt = math.max(att.Guilt - 20, 0)
			end
		end

		owner:SetAnimation(PLAYER_ATTACK1)

		self:Remove()

		self:GetOwner():SelectWeapon("weapon_hands")
	end
end

function SWEP:GetEyeTraceDist(dist)
	local owner = self:GetOwner()
	if not owner or not owner:IsValid() then return end

	local trace = util.TraceLine({
		start = owner:EyePos(),
		endpos = owner:EyePos() + owner:EyeAngles():Forward() * dist,
		filter = owner
	})

	return trace
end

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

	if ent:Health() < 100 then
		ent:SetHealth(math.Clamp(self:GetOwner():Health() + 75, 0, 100))

		used = true
	end

	if used then
		sound.Play(healsound, ent:GetPos(), 75, 100, 0.5)

		self:Remove()
	end
end