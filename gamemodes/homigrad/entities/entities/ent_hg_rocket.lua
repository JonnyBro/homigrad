AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Rocket"
ENT.Spawnable = false
ENT.Model = "models/weapons/w_missile_launch.mdl"
ENT.Speed = 2500
ENT.Gravity = 0.15
ENT.LifeTime = 8

if CLIENT then
	function ENT:Draw()
		self:DrawModel()

		local dlight = DynamicLight(self:EntIndex())

		if dlight then
			dlight.pos = self:GetPos() - self:GetForward() * 20
			dlight.r = 255
			dlight.g = 160
			dlight.b = 60
			dlight.brightness = 2
			dlight.decay = 1000
			dlight.size = 150
			dlight.dietime = CurTime() + .1
		end
	end

	return
end

local hullMins, hullMaxs = Vector(-2, -2, -2), Vector(2, 2, 2)

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:DrawShadow(false)

	self.Velocity = self:GetForward() * self.Speed + (self.InheritVelocity or vector_origin)
	self.DieTime = CurTime() + self.LifeTime

	util.SpriteTrail(self, 0, Color(200, 200, 200, 150), false, 12, 40, 1.5, 1 / 26, "trails/smoke")

	self.EngineSound = CreateSound(self, "weapons/rpg/rocket1.wav")
	self.EngineSound:Play()

	self:NextThink(CurTime())
end

function ENT:Think()
	local time = CurTime()
	local dt = FrameTime()
	local pos = self:GetPos()

	self.Velocity = self.Velocity + physenv.GetGravity() * self.Gravity * dt

	local nextPos = pos + self.Velocity * dt
	local owner = self.Shooter

	local tr = util.TraceHull({
		start = pos,
		endpos = nextPos,
		mins = hullMins,
		maxs = hullMaxs,
		mask = MASK_SHOT,
		filter = function(ent)
			if ent == self or ent == owner then return false end
			if IsValid(owner) and ent == owner:GetNWEntity("Ragdoll") then return false end

			return true
		end
	})

	if tr.HitSky then
		self:Remove()

		return
	end

	if tr.Hit or time > self.DieTime then
		self:Detonate(tr.Hit and tr.HitPos - self.Velocity:GetNormalized() * 4 or pos)

		return
	end

	self:SetPos(nextPos)
	self:SetAngles(self.Velocity:Angle())
	self:NextThink(time)

	return true
end

function ENT:Detonate(pos)
	if self.Exploded then return end

	self.Exploded = true

	local owner = IsValid(self.Shooter) and self.Shooter or game.GetWorld()

	ParticleEffect("pcf_jack_groundsplode_medium", pos, vector_up:Angle())
	util.ScreenShake(pos, 30, 30, 1.5, 2000)
	util.Decal("Scorch", pos + vector_up * 10, pos - vector_up * 50)

	sound.Play("BaseExplosionEffect.Sound", pos, 120, math.random(90, 110))
	sound.Play("explosions/doi_ty_01_close.wav", pos, 140, math.random(90, 110))

	hg.Sploom(owner, pos, 200)
	hg.FragSplosion(self, pos, 600, 300, 1500, owner)
	hg.WreckBuildings(self, pos, 3)
	hg.BlastDoors(self, pos, 4)

	util.BlastDamage(self, owner, pos, 350, 250)

	self:Remove()
end

function ENT:OnRemove()
	if self.EngineSound then self.EngineSound:Stop() end
end
