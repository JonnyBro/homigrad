AddCSLuaFile("shared.lua")

include("shared.lua")

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
	if not IsValid(ent) then return end

	ent = ent:IsPlayer() and ent or RagdollOwner(ent) or ent:GetClass() == "prop_ragdoll" and ent
	if not ent then return end

	if self:Heal(ent) then
		if ent:IsPlayer() then
			local dmg = DamageInfo()
			dmg:SetDamage(-5)
			dmg:SetAttacker(self)
			local att = self:GetOwner()

			if GuiltLogic(att, ent, dmg, true) then att.Guilt = math.max(att.Guilt - 10, 0) end
		end

		owner:SetAnimation(PLAYER_ATTACK1)

		self:Remove()

		self:GetOwner():SelectWeapon("weapon_hands")
	end
end

function SWEP:GetEyeTraceDist(dist)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local trace = util.TraceLine({
		start = owner:EyePos(),
		endpos = owner:EyePos() + owner:EyeAngles():Forward() * dist,
		filter = owner
	})

	return trace
end

local healsound = "snd_jack_bandage.wav"

function SWEP:Heal(ent)
	if not ent or not ent:IsPlayer() then
		sound.Play(healsound, ent:GetPos(), 75, 100, 0.5)

		return true
	end

	if ent.pain > 50 then
		ent.painlosing = math.Clamp(ent.painlosing + 2.5, 1, 15)

		sound.Play(healsound, ent:GetPos(), 75, 100, 0.5)

		return true
	end

	if ent.Bloodlosing > 0 then
		ent.Bloodlosing = math.max(ent.Bloodlosing - 30, 0)

		sound.Play(healsound, ent:GetPos(), 75, 100, 0.5)

		return true
	end

	-- NOTE: If there is a bug here, probably just remove.
	if ent.LeftLeg < 1 or ent.RightLeg < 1 then
		ent.LeftLeg = 1
		ent.RightLeg = 1

		sound.Play(healsound, ent:GetPos(), 75, 100, 0.5)

		return true
	end

	if ent:Health() < 150 then
		ent:SetHealth(math.Clamp(ent:Health() + 10, 0, 150))

		ent.hungryregen = ent.hungryregen + 6

		sound.Play(healsound, ent:GetPos(), 75, 100, 0.5)

		return true
	end
end