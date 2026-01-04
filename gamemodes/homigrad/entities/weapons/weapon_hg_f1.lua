SWEP.Base = "weapon_hg_grenade_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.f1.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.f1.inst")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
	SWEP.IconOverride = "materials/items_icons/f1icon.png"
end

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/pwb/weapons/w_f1.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_f1.mdl"

SWEP.Grenade = "ent_hgjack_f1nade"