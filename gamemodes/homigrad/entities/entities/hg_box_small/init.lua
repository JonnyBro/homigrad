-- Yonked from https://github.com/chominapisaLi/HomiFork <3

AddCSLuaFile("shared.lua")
include("shared.lua")

local food = {"food_spongebob_home", "food_lays", "food_fishcan"}
local knife = {"weapon_hg_kitknife"}
local other = {"weapon_handcuffs", "med_band_small", "weapon_pepperspray"}

function ENT:Initialize()
	self:SetModel("models/props_junk/cardboard_box003a.mdl")

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

	if random == 1 then
		local randomWeapon = RandomFromTable(knife)
		self.Info.Weapons[randomWeapon] = {
			Clip1 = -2
		}
	end

	if random >= 7 then
		local randomWeapon = RandomFromTable(other)
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