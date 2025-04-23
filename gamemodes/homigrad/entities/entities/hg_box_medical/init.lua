-- Yonked from https://github.com/chominapisaLi/HomiFork <3

AddCSLuaFile("shared.lua")
include("shared.lua")

local med1 = {"med_band_small", "med_band_big", "painkiller"}
local med2 = {"medkit"}
local med3 = {"adrenaline", "morphine", "splint"}

function ENT:Initialize()
	self:SetModel("models/props/CS_militia/footlocker01_closed.mdl")

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

	local randomWeapon = RandomFromTable(med1)
	self.Info.Weapons[randomWeapon] = {
		Clip1 = -2
	}

	if random >= 1 and random <= 3 then
		local randomWeapon = RandomFromTable(med3)
		self.Info.Weapons[randomWeapon] = {
			Clip1 = -2
		}
	end

	if random > 6 then
		local randomWeapon = RandomFromTable(med2)
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