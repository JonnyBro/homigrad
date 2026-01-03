AddCSLuaFile()

SWEP.Base = "medkit"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.bloodbag.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.bloodbag.inst")
	SWEP.Category = language.GetPhrase("hg.category.medicine")
	SWEP.IconOverride = "materials/items_icons/bloodbagicon.png"
end

SWEP.Spawnable = true

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.ViewModel = "models/blood_bag/models/blood_bag.mdl"
SWEP.WorldModel = "models/blood_bag/models/blood_bag.mdl"

SWEP.dwsPos = Vector(55, 55, 20)

SWEP.vbwPos = Vector(2, 6, -8)
SWEP.vbwAng = Angle(0, 0, 0)
SWEP.vbwModelScale = 0.25

SWEP.vbwPos2 = Vector(0, 3, -8)
SWEP.vbwAng2 = Angle(0, 0, 0)

function SWEP:vbwFunc(ply)
	local ent = ply:GetWeapon("medkit")
	if ent and ent.vbwActive then return self.vbwPos, self.vbwAng end

	return self.vbwPos2, self.vbwAng2
end

if CLIENT then
	net.Receive("blood_gotten", function(len)
		local wep = net.ReadEntity()

		wep.bloodinside = net.ReadBool()
		wep.PrintName = wep.bloodinside and language.GetPhrase("hg.bloodbag.namefull") or language.GetPhrase("hg.bloodbag.name")
	end)

	SWEP.dwmModeScale = 1
	SWEP.dwmForward = 5
	SWEP.dwmRight = 5
	SWEP.dwmUp = -1
	SWEP.dwmAUp = 30
	SWEP.dwmARight = 90
	SWEP.dwmAForward = 0
end