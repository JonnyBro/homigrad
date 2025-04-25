-- Yonked from https://github.com/chominapisaLi/HomiFork <3

AddCSLuaFile("shared.lua")
include("shared.lua")

local secondAll = {"weapon_mateba", "food_spongebob_home", "painkiller", "med_band_big", "med_band_small", "medkit", "weapon_handcuffs", "weapon_pepperspray", "weapon_taser", "weapon_kukri", "weapon_knife", "weapon_kabar", "weapon_hg_kitknife"}
local mainHeavy = {"weapon_hg_shovel", "weapon_hg_sledgehammer", "weapon_hg_fubar", "weapon_pipe"}
local grenades = {"weapon_hg_f1", "weapon_hg_rgd5"}

function ENT:Initialize()
	self:SetModel("models/Items/ammocrate_smg1.mdl")

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

	local randomWeapon = RandomFromTable(mainHeavy)
	self.Info.Weapons[randomWeapon] = {
		Clip1 = -2
	}

	if random >= 500 then
		local randomWeaponss = RandomFromTable(secondAll)
		self.Info.Weapons[randomWeaponss] = {
			Clip1 = -2
		}
	end

	if random >= 888 then
		local randomWeaponsss = RandomFromTable(grenades)
		self.Info.Weapons[randomWeaponsss] = {
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