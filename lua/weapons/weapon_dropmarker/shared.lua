-- Adapted from TTT Base Grenade

AddCSLuaFile( )

SWEP.Author = "Kamshak"
SWEP.Contact = ""
SWEP.Purpose = "Marks a Pointshop 2 Airdrop"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.HoldReady = "grenade"
SWEP.HoldNormal = "slam"

SWEP.PrintName = "Airdrop Marker"
SWEP.Slot = 1
SWEP.SlotPos = 8
SWEP.Instructions = "Left click to throw."
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

if CLIENT then
   SWEP.Instructions		= "Throw to call in an airdrop"
   SWEP.Slot				= 3
   SWEP.SlotPos			= 0

   SWEP.Icon = "vgui/ttt/icon_nades"
end

SWEP.Base	= "weapon_base"

SWEP.ViewModel			= "models/weapons/cstrike/c_eq_smokegrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_smokegrenade.mdl"
SWEP.Model = "models/weapons/w_eq_smokegrenade.mdl"
SWEP.Weight			= 5
SWEP.UseHands = true
SWEP.AutoSpawnable      = false
SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54

SWEP.AutoSwitchFrom		= true

SWEP.DrawCrosshair		= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Delay = 1.0
SWEP.Primary.Ammo		= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.IsGrenade = true
SWEP.NoSights = true

SWEP.was_thrown = false
SWEP.detonate_timer = 5
SWEP.DeploySpeed = 1.5

SWEP.Kind = WEAPON_EQUIP1
SWEP.LimitedStock = true
SWEP.AllowDrop = false
SWEP.CanBuy = { }

AccessorFunc(SWEP, "det_time", "DetTime")

function SWEP:SetupDataTables()
   self:NetworkVar("Bool", 0, "Pin")
   self:NetworkVar("Int", 0, "ThrowTime")
end

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

   self:PullPin()
end

function SWEP:SecondaryAttack()
end

function SWEP:PullPin()
   if self:GetPin() then return end

   local ply = self.Owner
   if not IsValid(ply) then return end

   self:SendWeaponAnim(ACT_VM_PULLPIN)

   if self.SetHoldType then
      self:SetHoldType(self.HoldReady)
   end

   self:SetPin(true)

   self:SetDetTime(CurTime() + self.detonate_timer)
end


function SWEP:Think()
   local ply = self.Owner
   if not IsValid(ply) then return end

   -- pin pulled and attack loose = throw
   if self:GetPin() then
      -- we will throw now
      if not ply:KeyDown(IN_ATTACK) then
         self:StartThrow()

         self:SetPin(false)
         self:SendWeaponAnim(ACT_VM_THROW)

         if SERVER then
            self.Owner:SetAnimation( PLAYER_ATTACK1 )
         end
      else
         -- still cooking it, see if our time is up
         if SERVER and self:GetDetTime() < CurTime() then
            self:BlowInFace()
         end
      end
   elseif self:GetThrowTime() > 0 and self:GetThrowTime() < CurTime() then
      self:Throw()
   end
end


function SWEP:BlowInFace()
   local ply = self.Owner
   if not IsValid(ply) then return end

   if self.was_thrown then return end

   self.was_thrown = true

   -- drop the grenade so it can immediately explode

   local ang = ply:GetAngles()
   local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())
   src = src + (ang:Right() * 10)

   self:CreateGrenade(src, Angle(0,0,0), Vector(0,0,1), Vector(0,0,1), ply)

   self:SetThrowTime(0)
   self:Remove()
end

function SWEP:StartThrow()
   self:SetThrowTime(CurTime() + 0.1)
end

function SWEP:Throw()
   if CLIENT then
      self:SetThrowTime(0)
   elseif SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end

      if self.was_thrown then return end

      self.was_thrown = true

      local ang = ply:EyeAngles()
      local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())+ (ang:Forward() * 8) + (ang:Right() * 10)
      local target = ply:GetEyeTraceNoCursor().HitPos
      local tang = (target-src):Angle() -- A target angle to actually throw the grenade to the crosshair instead of fowards
      -- Makes the grenade go upgwards
      if tang.p < 90 then
         tang.p = -10 + tang.p * ((90 + 10) / 90)
      else
         tang.p = 360 - tang.p
         tang.p = -10 + tang.p * -((90 + 10) / 90)
      end
      tang.p=math.Clamp(tang.p,-90,90) -- Makes the grenade not go backwards :/
      local vel = math.min(800, (90 - tang.p) * 6)
      local thr = tang:Forward() * vel + ply:GetVelocity()
      self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, math.random(-1200, 1200), 0), ply)

      self:SetThrowTime(0)
      self:Remove()
   end
end

-- subclasses must override with their own grenade ent
function SWEP:GetGrenadeName()
   return "sent_dropmarkernade"
end


function SWEP:CreateGrenade(src, ang, vel, angimp, ply)
   local gren = ents.Create(self:GetGrenadeName())
   if not IsValid(gren) then return end

   gren:SetPos(src)
   gren:SetAngles(ang)

   --   gren:SetVelocity(vel)
   gren:SetOwner(ply)
   gren:SetThrower(ply)

   gren:SetGravity(0.4)
   gren:SetFriction(0.2)
   gren:SetElasticity(0.45)

   gren:Spawn()

   gren:PhysWake()

   local phys = gren:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocity(vel)
      phys:AddAngleVelocity(angimp)
   end

   return gren
end

function SWEP:PreDrop()
   -- if owner dies or drops us while the pin has been pulled, create the armed
   -- grenade anyway
   if self:GetPin() then
      self:BlowInFace()
   end
end

function SWEP:Deploy()

   if self.SetHoldType then
      self:SetHoldType(self.HoldNormal)
   end

   self:SetThrowTime(0)
   self:SetPin(false)
   return true
end

function SWEP:Holster()
   if self:GetPin() then
      return false -- no switching after pulling pin
   end

   self:SetThrowTime(0)
   self:SetPin(false)
   return true
end

function SWEP:Reload()
   return false
end

function SWEP:Initialize()
  self = self.Weapon
   if self.SetHoldType then
      self:SetHoldType(self.HoldNormal)
   end

   self:SetDeploySpeed(self.DeploySpeed)

   self:SetDetTime(0)
   self:SetThrowTime(0)
   self:SetPin(false)

   self.was_thrown = false

  if engine.ActiveGamemode( ) != "terrortown" then
    return
  end

  local tttbase = weapons.GetStored('weapon_tttbase')
  local MARKER  = weapons.GetStored('weapon_dropmarker')
  MARKER.StoredAmmo = 0
  MARKER.GetIronsights = function() end
  MARKER.IsEquipment = tttbase.IsEquipment
  MARKER.PreDrop = tttbase.PreDrop
  MARKER.DampenDrop = tttbase.DampenDrop
  MARKER.Ammo1 = tttbase.Ammo1
  MARKER.Equip = function( self )
    tttbase.Equip( self )
  end
  MARKER.WasBought = MARKER.WasBought
  MARKER.DyingShot = function( ) end
  MARKER.GetHeadshotMultiplier = function( ) end
end
