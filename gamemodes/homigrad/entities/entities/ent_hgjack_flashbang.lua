-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_hg_grenade_base"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZHG Flashbang"
ENT.Category = "Homigrad"
ENT.Spawnable = true
ENT.Model = "models/jmod/explosives/grenades/flashbang/flashbang.mdl"
ENT.ModelScale = 0.8
ENT.SpoonScale = 2

if SERVER then
	function ENT:Arm()
		self:SetBodygroup(2, 1)
		self:SetState(self.STATE_ARMED)
		self:SpoonEffect()

		local time = 2.5
		timer.Simple(time - 1, function()
			if IsValid(self) then
				player.EventPoint(self:GetPos(), "flashbang pre detonate", 1024, self)
			end
		end)

		timer.Simple(time, function()
			if IsValid(self) then
				self:Detonate()
			end
		end)
	end

	function ENT:CanSee(ent)
		if not IsValid(ent) then return false end
		local TargPos, SelfPos = ent:LocalToWorld(ent:OBBCenter()), self:LocalToWorld(self:OBBCenter()) + vector_up * 10

		local Tr = util.TraceLine({
			start = SelfPos,
			endpos = TargPos,
			filter = {self, ent},
			mask = MASK_SHOT + MASK_WATER
		})

		return not Tr.Hit
	end

	function ENT:Detonate()
		if self.Exploded then return end

		self.Exploded = true

		local SelfPos = self:GetPos() + Vector(0, 0, 10)

		hg.Sploom(self:GetOwner(), self:GetPos(), 20)

		self:EmitSound("snd_jack_fragsplodeclose.wav", 511, 140)
		self:EmitSound("snd_jack_fragsplodeclose.wav", 511, 140)

		local plooie = EffectData()
		plooie:SetOrigin(SelfPos)

		util.Effect("hg_flashbang", plooie, true, true)

		util.ScreenShake(SelfPos, 20, 20, .2, 1000)

		self:SetColor(Color(0, 0, 0))

		timer.Simple(.1, function()
			if not IsValid(self) then return end
			util.BlastDamage(self, self:GetOwner() or self, SelfPos, 1000, 2)
		end)

		local Pos = self:GetPos()

		sound.Play("hmgd/ear_ringing.wav", Pos, nil, nil, .5)

		for _, ply in player.Iterator() do
			local plyPos = ply:GetPos()
			local dis = Pos:Distance(plyPos)

			if dis < 1000 then
				if not util.TraceLine({
					start = Pos,
					endpos = plyPos,
					filter = {self, ply}
				}).Hit then
					player.Event(ply, "flashbang", 1 - dis / 1000)
				end
			end
		end

		SafeRemoveEntityDelayed(self, 10)
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
