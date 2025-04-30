-- NOTE: this is what at4 should use but it doesn't work

if true then return end

--[[
AddCSLuaFile()

DEFINE_BASECLASS("base_rocket")

local ExploSnds = {}
ExploSnds[1] = "explosions/doi_ty_01.wav"
ExploSnds[2] = "explosions/doi_ty_02.wav"
ExploSnds[3] = "explosions/doi_ty_03.wav"
ExploSnds[4] = "explosions/doi_ty_04.wav"

local CloseExploSnds = {}
CloseExploSnds[1] = "explosions/doi_ty_01_close.wav"
CloseExploSnds[2] = "explosions/doi_ty_02_close.wav"
CloseExploSnds[3] = "explosions/doi_ty_03_close.wav"
CloseExploSnds[4] = "explosions/doi_ty_04_close.wav"

local DistExploSnds = {}
DistExploSnds[1] = "explosions/doi_ty_01_dist.wav"
DistExploSnds[2] = "explosions/doi_ty_02_dist.wav"
DistExploSnds[3] = "explosions/doi_ty_03_dist.wav"
DistExploSnds[4] = "explosions/doi_ty_03_dist.wav"

local WaterExploSnds = {}
WaterExploSnds[1] = "explosions/doi_ty_01_water.wav"
WaterExploSnds[2] = "explosions/doi_ty_02_water.wav"
WaterExploSnds[3] = "explosions/doi_ty_03_water.wav"
WaterExploSnds[4] = "explosions/doi_ty_04_water.wav"

local CloseWaterExploSnds = {}
CloseWaterExploSnds[1] = "explosions/doi_ty_01_closewater.wav"
CloseWaterExploSnds[2] = "explosions/doi_ty_02_closewater.wav"
CloseWaterExploSnds[3] = "explosions/doi_ty_03_closewater.wav"
CloseWaterExploSnds[4] = "explosions/doi_ty_04_closewater.wav"

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "[ROCKETS]RP-3"
ENT.Author = ""
ENT.Contact = ""
ENT.Category = "Gredwitch's Stuff"

ENT.Model = "models/doi/ty_missile.mdl"
ENT.RocketTrail = "rockettrail"
ENT.RocketBurnoutTrail = "grenadetrail"
ENT.Effect = "doi_mortar_explosion"
ENT.AngEffect = true
ENT.EffectAir = "doi_mortar_explosion"
ENT.EffectWater = "ins_water_explosion"

ENT.ExplosionSound = table.Random(CloseExploSnds)
ENT.FarExplosionSound = table.Random(ExploSnds)
ENT.DistExplosionSound = table.Random(DistExploSnds)
ENT.WaterExplosionSound = table.Random(CloseWaterExploSnds)
ENT.WaterFarExplosionSound = table.Random(WaterExploSnds)

ENT.StartSound = "gunsounds/rocket.wav"
ENT.ArmSound = "npc/roller/mine/rmine_blip3.wav"
ENT.ActivationSound = "buttons/button14.wav"
ENT.EngineSound = "RP3_Engine"
ENT.StartSoundFollow = true

ENT.ExplosionDamage = 7600
ENT.ExplosionRadius = 350
ENT.Mass = 37
ENT.EnginePower = 17760
ENT.TNTEquivalent = 5.4
ENT.FuelBurnoutTime = 5
ENT.LinearPenetration = 75
ENT.MaxVelocity = 480
ENT.Caliber = 76
ENT.Decal = "scorch_big"
-- ENT.RotationalForce = 500

function ENT:SpawnFunction(ply, tr)
	if not tr.Hit then return end

	local ent = ents.Create(self.ClassName)
		ent:SetPhysicsAttacker(ply)
		ent.Owner = ply
		ent:SetPos(tr.HitPos + tr.HitNormal * 16)
		ent:Spawn()
		ent:Activate()
	return ent
end

function ENT:DoPreInit()
	self.ExplosionSound = CloseExploSnds[math.random(#CloseExploSnds)]
	self.FarExplosionSound = ExploSnds[math.random(#ExploSnds)]
	self.DistExplosionSound = DistExploSnds[math.random(#DistExploSnds)]
	self.WaterExplosionSound = CloseWaterExploSnds[math.random(#CloseWaterExploSnds)]
	self.WaterFarExplosionSound = WaterExploSnds[math.random(#WaterExploSnds)]
end --]]