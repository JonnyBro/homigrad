SWEP.Base = "weapon_hg_granade_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.hl2nade.name")
	SWEP.Author = "homigrad"
	SWEP.Instructions = language.GetPhrase("hg.hl2nade.inst")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
end

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/w_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"

SWEP.Granade = "ent_hgjack_hl2nade"