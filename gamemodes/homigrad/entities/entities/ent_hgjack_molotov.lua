-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_hg_grenade_base"
ENT.Author = "sadsalat"
ENT.PrintName = "EZHG Molotov"
ENT.Category = "Homigrad"
ENT.Spawnable = true
ENT.Material = ""
ENT.Model = "models/w_models/weapons/w_eq_molotov.mdl"
ENT.Mass = 7

if SERVER then
	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 40 and self:IsOnFire() then
			self:Detonate()
		else
			if data.DeltaTime > 0.2 and data.Speed > 30 then
				local sound = Sound("physics/glass/glass_bottle_impact_hard"..math.random(1,3)..".wav")
				self:EmitSound(sound)
			end
		end
	end

	function ENT:Arm()
		self:SetState(self.STATE_ARMING)
		self:SetBodygroup(2, 1)

		timer.Simple(.3, function()
			if IsValid(self) then
				self:SetState(self.STATE_ARMED)
			end
		end)
		self:EmitSound("ambient/fire/mtov_flame2.wav")
		self:Ignite(15)
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:LocalToWorld(self:OBBCenter())
		hg.Sploom(self:GetOwner() or self, SelfPos, 50)
		self:EmitSound("ambient/fire/mtov_flame2.wav")

		hg.SpawnFlames(SelfPos + Vector(0, 0, 30), 5, 0.2)

		self:Remove()
	end
end
