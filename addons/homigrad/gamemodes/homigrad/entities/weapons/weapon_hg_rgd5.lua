SWEP.Base = "weapon_hg_granade_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.rgd5.name")
	SWEP.Author = "homigrad"
	SWEP.Instructions = language.GetPhrase("hg.f1.inst")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
end

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/pwb/weapons/w_rgd5.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_rgd5.mdl"

SWEP.Granade = "ent_hgjack_rgd5nade"