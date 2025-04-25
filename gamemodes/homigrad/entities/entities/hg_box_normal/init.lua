-- Yonked from https://github.com/chominapisaLi/HomiFork <3

AddCSLuaFile("shared.lua")
include("shared.lua")

local cuffs = {"weapon_handcuffs", "weapon_pepperspray"}
local food = {"food_spongebob_home", "food_lays", "food_fishcan"}
local melee = {"weapon_bat", "weapon_hg_kitknife", "weapon_hg_crowbar", "weapon_hg_metalbat", "weapon_hg_fireaxe", "weapon_hg_hatchet"}

function ENT:Initialize()
	self:SetModel("models/props_junk/cardboard_box002a.mdl")

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

	local random = math.random(10)

	local randomWeapon = RandomFromTable(food)
	self.Info.Weapons[randomWeapon] = {
		Clip1 = -2
	}

	if random >= 5 then
		local randomWeaponss = RandomFromTable(melee)
		self.Info.Weapons[randomWeaponss] = {
			Clip1 = -2
		}
	end

	if random >= 7 then
		local randomWeaponsss = RandomFromTable(cuffs)
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