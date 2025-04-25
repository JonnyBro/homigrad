-- Yonked from https://github.com/chominapisaLi/HomiFork <3

AddCSLuaFile("shared.lua")
include("shared.lua")

local guns = {"weapon_mp5", "weapon_xm1014", "weapon_remington870", "weapon_mp7", "weapon_civil_famas", "weapon_galil", "weapon_m4a1"}
local pistols = {"weapon_p220", "weapon_glock", "weapon_hk_usp", "weapon_fiveseven", "weapon_mateba"}
local grenades = {"weapon_hg_f1", "weapon_hg_rgd5", "weapon_hg_smokenade", "weapon_hg_molotov", "weapon_hg_flashbang"}

function ENT:Initialize()
	self:SetModel("models/Items/item_item_crate.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	self.Info = {
		Weapons = {},
		Ammo = {}
	}

	local random = math.random(1000)

	local randomWeapon = RandomFromTable(pistols)
	self.Info.Weapons[randomWeapon] = {
		Clip1 = -2
	}

	if random > 550 then
		local randomWeapon = RandomFromTable(guns)
		self.Info.Weapons[randomWeapon] = {
			Clip1 = -2
		}
	end

	if random > 900 then
		local randomWeapon = RandomFromTable(grenades)
		self.Info.Weapons[randomWeapon] = {
			Clip1 = -2
		}
	end
end

function ENT:Use(activator, caller)
	if activator:IsPlayer() and self.Info then
		net.Start("hg_inventory")
			net.WriteEntity(self)
			net.WriteTable(self.Info.Weapons)
			net.WriteTable(self.Info.Ammo)
		net.Send(activator)
	end
end