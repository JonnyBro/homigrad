AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Armor"
ENT.Spawnable = false
ENT.IsHGArmor = true

if CLIENT then
	-- Head armor welded to the owner's fake ragdoll would block their own first-person camera
	function ENT:Draw()
		if self:GetNWBool("hgHeadArmor") and self:GetNWEntity("hgArmorOwner") == LocalPlayer() then return end

		self:DrawModel()
	end

	return
end

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create(self.ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 40)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	local info = hg.ArmorTable[self.ArmorName]

	self:SetModel(info.mdl)
	self:SetMaterial(info.mat or "")

	if info.clr and not self.ArmorColor then self:SetColor(Color(info.clr.r, info.clr.g, info.clr.b)) end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass(4)
		phys:Wake()
	end

	self.ArmorDurability = self.ArmorDurability or info.dur
	self.ArmorID = self.ArmorID or hg.NewArmorID()
end

function ENT:PhysicsCollide(data)
	if data.DeltaTime > 0.2 and data.Speed > 25 then self:EmitSound("Body.ImpactSoft") end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	if self.IsArmor or dmginfo:GetDamage() < 5 then return end

	self.ArmorDurability = self.ArmorDurability - dmginfo:GetDamage() / 2
	if self.ArmorDurability <= 0 then self:Remove() end
end

function ENT:Use(activator)
	if not activator:IsPlayer() or not activator:KeyDown(IN_WALK) then return end

	hg.EquipArmor(activator, self)
	activator:EmitSound("snd_jack_clothequip.wav", 70, 100)
end
