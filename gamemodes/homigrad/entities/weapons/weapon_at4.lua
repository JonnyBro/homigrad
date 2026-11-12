SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.at4.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.at4.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/at4icon.png"
end

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

SWEP.ReloadTime = 3
SWEP.ReloadSound = "weapons/ar2/ar2_reload_rotate.wav"
SWEP.RecoilPush = 250

local base = baseclass.Get("salat_base")

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self:Clip1() <= 0 or self:IsReloaded() then return end

	local pos, ang = self:GetTrace()
	local owner = self:GetOwner()
	local back = -ang:Forward()

	if SERVER then
		local rocket = ents.Create("ent_hg_rocket")
		rocket:SetPos(pos)
		rocket:SetAngles(ang)

		rocket.Shooter = owner
		rocket.InheritVelocity = owner:GetVelocity()

		rocket:Spawn()

		local rag = owner:GetNWEntity("Ragdoll")

		if IsValid(rag) then
			for i = 0, rag:GetPhysicsObjectCount() - 1 do
				local phys = rag:GetPhysicsObjectNum(i)
				if IsValid(phys) then phys:AddVelocity(back * self.RecoilPush) end
			end
		elseif owner:IsPlayer() then
			owner:SetVelocity(back * self.RecoilPush * (owner:OnGround() and .6 or 1))
		end
	end

	if CLIENT and owner == LocalPlayer() then
		self.eyeSpray = self.eyeSpray or Angle()
		self.eyeSpray:Add(Angle(-7, math.Rand(-2.5, 2.5), 0))
	end

	self:EmitSound("weapons/rpg/rocketfire1.wav", 100)
	self:SetLastShootTime()
	self:SetNWFloat("LastShoot", CurTime())

	self:TakePrimaryAmmo(1)
end

function SWEP:Reload()
	local wasReloading = self:IsReloaded()

	base.Reload(self)

	if CLIENT or wasReloading or not self:IsReloaded() then return end

	timer.Simple(self.ReloadTime * .6, function()
		if IsValid(self) and self:IsReloaded() then self:EmitSound("weapons/ar2/ar2_reload_push.wav", 65) end
	end)
end

function SWEP:GetTransform(model, force)
	local pos, ang = base.GetTransform(self, model, force)
	if not pos or not ang then return pos, ang end

	local owner = self:GetOwner()
	if not force and IsValid(owner) and IsValid(owner:GetNWEntity("ragdollWeapon")) then return pos, ang end

	local kick = math.max(self:GetNWFloat("LastShoot", 0) + .3 - CurTime(), 0) / .3
	if kick <= 0 then return pos, ang end

	-- Model axes of the AT4 don't match the barrel, so offsets go along the aim instead
	local aim = IsValid(owner) and owner:EyeAngles() or ang

	pos = pos - aim:Forward() * 6 * kick
	ang:RotateAroundAxis(aim:Right(), 8 * kick)

	return pos, ang
end
