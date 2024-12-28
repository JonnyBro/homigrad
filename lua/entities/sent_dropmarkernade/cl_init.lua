include('shared.lua')

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:ParticleThink()
	self.lastParticle = self.lastParticle or 0
	if not self.Exploded then
		return
	end

	if CurTime( ) > self.lastParticle + 0.05 then
		local vec = Vector(
			math.sin(math.Rand(0, 360)) * math.Rand(-0.6, 0.6),
			math.cos(math.Rand(0, 360)) * math.Rand(-0.6, 0.6),
			math.sin(math.random()) * math.Rand(-0.6, 0.6)
		)

		local pos = self:GetPos() + Angle(math.Rand(-180, 180), math.Rand(-180, 180), math.Rand(-180, 180)):Forward() * 5
		local part = self.Emitter:Add( "particle/smokesprites_000" .. math.Rand(1, 10), pos )
		part:SetVelocity( vec * 20 )
		part:SetLifeTime(0)
		part:SetRoll(math.random(-180, 180))
    part:SetRollDelta(math.Rand(-0.1, 0.1))
		part:SetDieTime(math.random() * 2 + 10)
		part:SetStartSize(10)
		part:SetEndSize(50)
		part:SetAirResistance(100)
		part:SetGravity(Vector( math.sin(math.Rand(0, 360)) * math.Rand(20, 20), math.cos(math.Rand(0, 360)) * math.Rand(-20, 20), 100))
		part:SetColor(self.color.r, self.color.g, self.color.b)
		part:SetColor(self.color.r, self.color.g, self.color.b)
		part:SetLighting(false)
	end
	self:NextThink(CurTime())
end
