-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZHG F1 Grenade"
ENT.Category = "JModHomigrad"
ENT.Spawnable = true
ENT.JModPreferredCarryAngles = Angle(0, -140, 0)
ENT.Model = "models/pwb/weapons/w_f1_thrown.mdl"
ENT.SpoonScale = 2

if SERVER then
	function ENT:Arm()
		self:SetBodygroup(2, 1)
		self:SetState(JMod.EZ_STATE_ARMED)
		self:SpoonEffect()

		local time = math.random(3.2,4.2)
		timer.Simple(time - 1,function()
			if IsValid(self) then
				player.EventPoint(self:GetPos(),"fragnade pre detonate",1024,self)
			end
		end)

		timer.Simple(time, function()
			if IsValid(self) then
				self:Detonate()
			end
		end)
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:GetPos()
		JMod.Sploom(self:GetOwner(), self:GetPos(), math.random(10, 20))
		self:EmitSound("explosions/cache_explode.wav", 90, 100)
		local plooie = EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(.01)
		plooie:SetRadius(.5)
		plooie:SetNormal(vector_up)
		ParticleEffect("pcf_jack_groundsplode_small",SelfPos,vector_up:Angle())
		util.ScreenShake(SelfPos, 20, 20, 1, 1000)

		JMod.FragSplosion(self, SelfPos + Vector(0, 0, 20), 800, 450, 3500, self:GetOwner() or game.GetWorld())
		self:Remove()
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

end
