AddCSLuaFile()

SWEP.PrintName			= "Graffiti Swep"			
SWEP.Author				= "HK47 / Reuploaded by Just"
SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base				= "mhs_weapon_base"
SWEP.Category			= "Разное"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false

SWEP.ViewModel = "models/weapons/v_smg1.mdl" //hardcore
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.DrawAmmo = true

SWEP.Weight				= 3
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.HoldType               = "pistol"
SWEP.UseHands = false

SWEP.ShowWorldModel = false

SWEP.ViewModelFlip = true

SWEP.ViewModelBoneMods = { //HAND!!!11
	["ValveBiped.Bip01_L_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 21.111, 0) },
	["ValveBiped.Bip01_L_Finger11"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 45.555, 0) },
	["ValveBiped.base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(2.036, -6.853, 11.666), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger02"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -14.445, 0) },
	["ValveBiped.Bip01_L_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(-6.853, 6.48, 5.369), angle = Angle(-23.334, -1.111, 43.333) },
	["ValveBiped.Bip01_L_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -30, -47.778) },
	["ValveBiped.Bip01_L_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(7.777, -23.334, -12.223) },
	["ValveBiped.Bip01_L_Finger3"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -12.223, -3.333) },
	["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-50, -56.667, 81.111) }
}
//SWEP.UseHands = true

local MAXIMUM_BALS = 600 //constant

if SERVER then SWEP.bals = MAXIMUM_BALS end

if CLIENT then
	surface.CreateFont("Spraymhs", { //cool font ;D
		font = "Impact",
		size = 70,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = true,
	})

	SWEP.WepSelectIcon = Material("mhstextures/selection_spraymhs.png")
	
	SWEP.VElements = {
		["m"] = { type = "Model", model = "models/props_junk/propane_tank001a.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(-1.558, -4.676, 1.5), angle = Angle(66.623, 66.623, 87.662), size = Vector(0.4, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	
	SWEP.Bals = MAXIMUM_BALS
	SWEP.color = Vector(0, 0, 0)

	SWEP.WElements = {
		["spr"] = { type = "Model", model = "models/props_junk/propane_tank001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.5, 2.596), angle = Angle(0, -100, 180), size = Vector(0.36, 0.36, 0.36), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

if SERVER then
	util.AddNetworkString("sprayMhs")
	
	//main table 
	SWEP.Decal = 1
	
	SWEP.Decaltable = {
		[1] = { type = "mhsSprayGreen", color = Vector(0, 255, 0), colortype = "green" },
		[2] = { type = "mhsSprayRed", color = Vector(255, 0, 0), colortype = "red" },
		[3] = { type = "mhsSprayBlue", color = Vector(0, 0, 255), colortype = "blue" },
		[4] = { type = "mhsSprayYellow", color = Vector(255, 255, 0), colortype = "yellow" }
	}
end

function SWEP:DrawHUD() //hud stuff
	if SERVER then return end

	net.Receive("sprayMhs", function()
		local self = net.ReadEntity()
		local get_bals = net.ReadFloat()
		
		self.Bals = get_bals
	end)
	
	draw.DrawText("Spray: " .. self.Bals, "Spraymhs", (ScrW() / 2) + 150, ScrH() - 100, Color(255, 255, 255))
	
	surface.SetDrawColor(Color(255 - (self.Bals / 2.4), self.Bals / 2.4, 0))
	
	local x = (ScrW() / 2) - 400
	local y = ScrH() - 90
	local n = self.Bals * 0.834
	
	surface.DrawRect(x, y, n, 50)
	
	surface.SetDrawColor(Color(255, 0, 0))
	
	surface.DrawOutlinedRect(x - 1.5, y - 1.5, 504, 54)	//drawing line
end

function SWEP:Holster()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	if self.Sound then self.Sound:Stop() self.Sound = nil end
	
	return true
end

function SWEP:PrimaryAttack()
	if SERVER then self.Owner:SetNWFloat("mhsSprayClS", self.bals) end

	if self.Owner:GetNWFloat("mhsSprayClS") <= 0 then self:Reload() return end //checking minimum (as CanPrimaryAttack())
	if CurTime() < self.time then return end //checking if reloading
	
	if not self.Sound then
		self.Sound = CreateSound(self.Owner, "ambient/gas/cannister_loop.wav")
		self.Sound:Play()
	else
		self.Sound:ChangeVolume(1, 0.1)
	end
	
	self:SetNextPrimaryFire(CurTime() + 0.01)
	
	local ef = EffectData()
	ef:SetEntity(self.Weapon)
	ef:SetAttachment(1)
	ef:SetOrigin(self.Owner:GetShootPos())
	ef:SetStart(self.Owner:GetNWVector("mhsSprayColor"))
	ef:SetNormal(self.Owner:GetAimVector())
	util.Effect("effect_spray_mhs", ef)
	
	if SERVER then //server stuff
		self.bals = self.bals - 1
		
		net.Start("sprayMhs")
			net.WriteEntity(self)
			net.WriteFloat(self.bals)
		net.Send(self.Owner)
		
		local tr = self.Owner:GetEyeTrace()
		
		if tr.HitPos:Distance(self.Owner:GetPos()) >= 140 then return end
		
		if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			tr.Entity:TakeDamage(0.15)
		end
		
		local dec = self.Decaltable[self.Decal].type //saving
			
		timer.Simple(0.35, function()
			util.Decal(dec, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		end)
	end
end

SWEP.time = 0  //server-client variable for check reloading

function SWEP:Reload()
	if CurTime() < self.time then return end //checking if reloading

	self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
	self.Owner:SetAnimation(PLAYER_RELOAD)
	
	if CurTime() > self.time then
		timer.Simple(0.5, function()
			self.Weapon:EmitSound("ambient/water/drip2.wav")
		end)
		
		self.time = CurTime() + 1.5
		
		if SERVER then
			self.bals = MAXIMUM_BALS
		
			net.Start("sprayMhs")
				net.WriteEntity(self)
				net.WriteFloat(self.bals)
			net.Send(self.Owner)
		end
	end
end

function SWEP:Think()
	if SERVER then return end
	
	net.Receive("sprayShit", function()
		local col = net.ReadVector()
		
		self.color = col
	end)
end

function SWEP:SecondaryAttack() //fixed
	if SERVER and self.Owner:KeyPressed(IN_ATTACK2) then
		self.Decal = self.Decal + 1
		if self.Decal > 4 then self.Decal = 1 end
		
		self.Owner:SetNWVector("mhsSprayColor", self.Decaltable[self.Decal].color)
		self.Owner:ChatPrint("Spray color is " .. self.Decaltable[self.Decal].colortype .. " now")
	end
end

function SWEP:Think()
	if self.Owner:KeyReleased(IN_ATTACK) or CurTime() < self.time then
		if self.Sound then self.Sound:ChangeVolume(0, 0.1) end
	end
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:SetNWVector("mhsSprayColor", self.Decaltable[self.Decal].color)
	end
end

