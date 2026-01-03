AddCSLuaFile()

SWEP.Base = "medkit"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.morphine.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.morphine.inst")
	SWEP.Category = language.GetPhrase("hg.category.medicine")
	SWEP.IconOverride = "materials/items_icons/morphineicon.png"
end

SWEP.Spawnable = true

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.ViewModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"
SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"

SWEP.dwsPos = Vector(15, 15, 5)
SWEP.dwsItemPos = Vector(0, 0, 2)

SWEP.vbwPos = Vector(-2, -1.5, -7)
SWEP.vbwAng = Angle(-90, 90, 180)
SWEP.vbwModelScale = 0.8

SWEP.vbwPos2 = Vector(-3, 0.2, -7)
SWEP.vbwAng2 = Angle(-90, 90, 180)

function SWEP:vbwFunc(ply)
	local ent = ply:GetWeapon("medkit")
	if ent and ent.vbwActive then return self.vbwPos, self.vbwAng end

	return self.vbwPos2, self.vbwAng2
end