SWEP.Base = "weapon_hg_grenade_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.hl2nade.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.hl2nade.inst")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
	SWEP.IconOverride = "materials/items_icons/hl2nadeicon.png"
end

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/w_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"

SWEP.Grenade = "ent_hgjack_hl2nade"