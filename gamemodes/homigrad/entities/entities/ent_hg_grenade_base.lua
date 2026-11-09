AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Grenade Base"
ENT.Spawnable = false
ENT.Model = "models/weapons/w_grenade.mdl"
ENT.Mass = 10
ENT.ImpactSound = {"weapons/m67/m67_bounce_01.wav", "weapons/m67/m67_bounce_02.wav"}
ENT.SpoonModel = nil
ENT.SpoonScale = nil
ENT.HardThrowStr = 500
ENT.SoftThrowStr = 250

ENT.STATE_BROKEN = -1
ENT.STATE_OFF = 0
ENT.STATE_PRIMED = 2
ENT.STATE_ARMING = 3
ENT.STATE_ARMED = 4

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

if CLIENT then return end

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create(self.ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 20)
	ent.Owner = ply
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)

	if self.Material then self:SetMaterial(self.Material) end
	if self.ModelScale then self:SetModelScale(self.ModelScale, 0) end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass(self.Mass)
		phys:Wake()
	end

	self:SetState(self.STATE_OFF)
end

function ENT:PhysicsCollide(data)
	if data.DeltaTime > 0.2 and data.Speed > 30 then self:EmitSound(self.ImpactSound[math.random(#self.ImpactSound)]) end
end

function ENT:OnTakeDamage(dmginfo)
	if self.Exploded or dmginfo:GetInflictor() == self then return end

	self:TakePhysicsDamage(dmginfo)

	local dmg = dmginfo:GetDamage()
	if dmg < 4 then return end

	if dmginfo:IsDamageType(DMG_BLAST) and math.Rand(0, 1) < dmg / 150 then
		self:Detonate()
	elseif math.random(1, 10) == 3 and self:GetState() ~= self.STATE_BROKEN then
		self:SetState(self.STATE_BROKEN)
		self:EmitSound("Metal_Box.Break")
		SafeRemoveEntityDelayed(self, 10)
	end
end

local throwHolders = {}

function ENT:Use(activator)
	if self.Exploded or not IsValid(activator) or not activator:IsPlayer() then return end

	self.Owner = activator
	activator:PickupObject(self)
	throwHolders[activator] = self
end

-- Throwing a held grenade: attack throws it hard, alt-attack lobs it
hook.Add("KeyPress", "hg_grenade_throw", function(ply, key)
	local ent = throwHolders[ply]
	if not ent then return end

	if not IsValid(ent) or not ent:IsPlayerHolding() then
		throwHolders[ply] = nil

		return
	end

	local strength, dir

	if key == IN_ATTACK then
		strength, dir = ent.HardThrowStr, ply:GetAimVector()
	elseif key == IN_ATTACK2 then
		strength, dir = ent.SoftThrowStr, ply:GetAimVector()
		dir.z = dir.z + 0.3
	else
		return
	end

	throwHolders[ply] = nil
	ply:DropObject()

	timer.Simple(0, function()
		if not IsValid(ent) then return end

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then phys:ApplyForceCenter(dir * strength * phys:GetMass()) end
	end)
end)

function ENT:SpoonEffect()
	local spoon = ents.Create("ent_hg_spoon")

	if self.SpoonModel then spoon:SetModel(self.SpoonModel) end
	if self.SpoonScale then spoon:SetModelScale(self.SpoonScale) end

	spoon:SetPos(self:GetPos())
	spoon:Spawn()

	local phys = spoon:GetPhysicsObject()
	if IsValid(phys) then phys:SetVelocity(self:GetPhysicsObject():GetVelocity() + VectorRand() * 250) end

	self:EmitSound("snd_jack_spoonfling.wav", 60, math.random(90, 110))
end

function ENT:Think()
	local state = self:GetState()

	if self.CustomThink then self:CustomThink(state, CurTime()) end

	if not IsValid(self) or self.Exploded then return end

	if state == self.STATE_PRIMED and not self:IsPlayerHolding() then self:Arm() end

	-- Smoke grenade burn time depends on this 0.5s rate
	if state == self.STATE_ARMED then
		local snd = ents.Create("ai_sound")
		snd:SetPos(self:GetPos())
		snd:SetKeyValue("volume", "500")
		snd:SetKeyValue("duration", "0.5")
		snd:SetKeyValue("soundtype", "8")
		snd:Spawn()
		snd:Activate()
		snd:Fire("EmitAISound")
		SafeRemoveEntityDelayed(snd, 1)

		self:NextThink(CurTime() + 0.5)

		return true
	end
end

function ENT:Prime()
	self:SetState(self.STATE_PRIMED)
	self:EmitSound("weapons/pinpull.wav", 60, 100)
	self:SetBodygroup(1, 1)
end

function ENT:Arm()
	self:SetBodygroup(2, 1)
	self:SetState(self.STATE_ARMED)
	self:SpoonEffect()
end

function ENT:Detonate()
	if self.Exploded then return end

	self.Exploded = true
	self:Remove()
end
