AddCSLuaFile()

SWEP.Base = "medkit"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.adrenaline.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.adrenaline.inst")
	SWEP.Category = language.GetPhrase("hg.category.medicine")
	SWEP.IconOverride = "materials/items_icons/adrenalineicon.png"
end

SWEP.Spawnable = true

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.ViewModel = "models/weapons/w_models/w_jyringe_jroj.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_jyringe_jroj.mdl"

SWEP.dwsPos = Vector(7, 7, 7)
SWEP.dwsItemPos = Vector(2, 0, 2)

SWEP.vbwPos = Vector(0, -1, -12)
SWEP.vbwAng = Angle(0, 0, 0)
SWEP.vbwModelScale = 1

SWEP.dwmModeScale = 1
SWEP.dwmForward = 4
SWEP.dwmRight = 1
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = 90
SWEP.dwmAForward = 0