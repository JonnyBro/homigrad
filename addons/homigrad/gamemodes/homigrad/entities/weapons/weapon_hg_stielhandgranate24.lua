SWEP.Base = "weapon_hg_granade_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.stielhandgranate.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.stielhandgranate.name")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
end

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/stielhandgranate24/stielhandgranate24.mdl"
SWEP.WorldModel = "models/stielhandgranate24/stielhandgranate24.mdl"

SWEP.Granade = "ent_hgjack_stielhandgranate24"