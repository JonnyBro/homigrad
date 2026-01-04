SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("InstaGib Grenade Launcher")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("Loaded with tons of grenades, ribbed for YOUR pleasure!")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/igibicon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 6666
SWEP.Primary.DefaultClip = 6666
SWEP.Primary.Ammo = "RPG_Round"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.TwoHands = true

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "smg"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/w_jmod_milkormgl.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_milkormgl.mdl"

SWEP.ShootWait = 0.3

SWEP.Automatic = false
SWEP.vbwPos = Vector(14, 5, -7)
SWEP.vbwAng = Angle(60, 0, 90)
SWEP.ThrowVel = 55000
SWEP.addAng = Angle(-8, 0, -90)

SWEP.SightPos = Vector(-35, -1.1, -5)

function SWEP:PrimaryAttack()
	self.ShootNext = self.NextShot or NextShot

	if self.NextShot > CurTime() then return end
	if self:Clip1() <= 0 then return end

	self.NextShot = CurTime() + self.ShootWait

	local pos, ang = self:GetTrace()

	if CLIENT then self.eyeSpray:Add(Angle(-2, math.random(-2, 2), 0)) end

	if SERVER then
		local cmm = ents.Create("ent_hgjack_40mm_contact")
		cmm:SetPos(pos)
		cmm:SetAngles(ang)
		cmm:Spawn()
		cmm:Arm()

		local cmm2 = cmm:GetPhysicsObject()

		if IsValid(cmm2) then
			cmm2:ApplyForceCenter(ang:Forward() * self.ThrowVel + self:GetOwner():GetVelocity() * 1)
		end
	end

	-- self:TakePrimaryAmmo(1)
end

-- models/weapons/insurgency/w_rpg7.mdl
-- models/weapons/insurgency/w_rpg7_projectile.mdl