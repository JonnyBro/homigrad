SWEP.Base = "weapon_scout"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.barret.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.barret.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/barreticon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12.7x99 mm"
SWEP.Primary.Damage = 300
SWEP.Primary.Sound = "snd_jack_hmcd_snp_close.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_snp_far.wav"
SWEP.Primary.Force = 600

SWEP.ViewModel = "models/weapons/w_jmod_m107.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_m107.mdl"

function SWEP:ApplyEyeSpray()
	self.eyeSpray = self.eyeSpray - Angle(4, math.Rand(-2, 2), 0)
end

if CLIENT then
	SWEP.opticpos = Vector(0.2, 4, 10)
	SWEP.opticang = Angle(0, -90, 0)

	SWEP.spos = Vector(-25, 0, 3)
	SWEP.sang = Angle(0, 0, 0)

	SWEP.zoomfov = 5
	-- SWEP.scope_mat = Material("")
	-- SWEP.opticmodel = "models/weapons/arccw/atts/magnus.mdl"
	-- SWEP.opticmodel2 = "models/weapons/arccw/atts/magnus_hsp.mdl"
	SWEP.addfov = 60
end

SWEP.vbwPos = Vector(-3, -5, -5)
SWEP.vbwAng = Vector(-80, -20, 0)
SWEP.vbw = false

SWEP.CLR_Scope = 0.05
SWEP.CLR = 0.025

SWEP.addAng = Angle(-5, 0, -90)
SWEP.addPos = Vector(-14, -0.7, -0.5)

SWEP.SightPos = Vector(-58, -1, -8.9) -- Vector(-60, -0.68, -5.4)