AddCSLuaFile() -- TODO: Replace code with weapon_medkit

SWEP.Base = "medkit"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.megamedkit.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.megamedkit.inst")
	SWEP.Category = language.GetPhrase("hg.category.medicine")
	SWEP.IconOverride = "materials/items_icons/megamedkiticon.png"
end

SWEP.Spawnable = true

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.ViewModel = "models/w_models/weapons/w_eq_medkit.mdl"
SWEP.WorldModel = "models/w_models/weapons/w_eq_medkit.mdl"
SWEP.UseHands = true

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(15, 15, 15)

SWEP.vbw = false
SWEP.vbwPos = Vector(0, -2, 7)
SWEP.vbwAng = Angle(0, 90, 180)
SWEP.vbwModelScale = 1.7