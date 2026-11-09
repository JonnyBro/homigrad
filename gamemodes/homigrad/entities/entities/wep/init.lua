AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("weps.lua")

function ENT:Initialize()
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end

	self:GetOwner().wep = self
end

function ENT:Clip1()
	self.Clip1 = IsValid(lootInfo.Weapons[self.Class]) and lootInfo.Weapons[self.Class]:Clip1() or self.Clip1 or 0

	return self.Clip1
end

function ENT:SetClip1(val)
	if IsValid(lootInfo.Weapons[self.Class]) then lootInfo.Weapons[self.Class]:SetClip1(val) end
end

function ENT:GetPrimaryAmmoType()
	self.AmmoType = IsValid(lootInfo.Weapons[self.Class]) and lootInfo.Weapons[self.Class]:GetPrimaryAmmoType() or self.AmmoType or weapons.Get(self.Class):GetPrimaryAmmoType()

	return self.AmmoType
end

function ENT:Use(taker)
	local ply = RagdollOwner(self:GetOwner()) or self:GetOwner()

	SavePlyInfo(ply)

	if not ply:IsPlayer() or ply.unconscious then
		local weapon = ply.ActiveWeapon

		if IsValid(weapon) then
			local can = hook.Run("PlayerCanPickupWeapon", taker, weapon)

			if can then
				if ply:IsPlayer() then ply:DropWeapon(weapon) end

				timer.Simple(0, function() taker:PickupWeapon(weapon) end)

				self:Remove()
			end
		end
	end
end