SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.at4.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.at4.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/at4icon.png"
end

-- SWEP.WepSelectIcon = "pwb/sprites/m134"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "RPG_Round"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.TwoHands = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "rpg"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/w_jmod_at4.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_at4.mdl"

SWEP.vbwPos = Vector(14, 5, -7)
SWEP.vbwAng = Angle(60, 0, 90)

SWEP.addAng = Angle(-5.5, -0.3, -90)
SWEP.SightPos = Vector(-40, -3.6, -4.85)

SWEP.ThrowVel = 100000

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end

	local pos, ang = self:GetTrace()

	if SERVER then
		-- NOTE: replaced the gb_rocket_rp3 because i'm to lazy to convert it to current jmod (i should update jmod actually)
		local grenade = ents.Create("ent_hgjack_40mm_contact")
		grenade:SetPos(pos)
		grenade:SetAngles(ang)
		grenade:Spawn()
		grenade:Arm()

		local grenadePhys = grenade:GetPhysicsObject()
		if IsValid(grenadePhys) then grenadePhys:ApplyForceCenter(ang:Forward() * self.ThrowVel + self:GetOwner():GetVelocity() * 1) end
	end

	self:TakePrimaryAmmo(1)
end