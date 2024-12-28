SWEP.Gun					= ("weapon_nightstick")
SWEP.PrintName				= "Nightstick"
SWEP.Slot		       		= 1
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.BounceWeaponIcon		= false
SWEP.DrawCrosshair			= true
SWEP.ViewModel				= "models/drover/baton.mdl"	
SWEP.ViewModelFOV			= 70
SWEP.WorldModel				= "models/drover/w_baton.mdl"
SWEP.HoldType				= "melee"	
SWEP.UseHands           	= true

-- Other settings
SWEP.Weight					= 0
SWEP.AutoSwitchTo			= true
SWEP.Spawnable				= true

-- Weapon info
SWEP.Author					= "Haze_of_dream"
SWEP.Contact				= "https://steamcommunity.com/id/Haze_of_dream/"
SWEP.Purpose				= "Easily apprehend criminals, or beat people I guess."
SWEP.Instructions			= "Beat people you dislike."
SWEP.Category 				= "Ближний Бой"	

-- Primary fire settings
SWEP.Primary.Damage			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ""

-- Secondary fire settings
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			= ""

-- Misc
SWEP.SelectIcon				= "hud/weaponicons/nightstick"

-- Nightstick Specific Settings
SWEP.RecoveryTime			= 3 -- This is how long you can go between hits before your hit tracker resets

local BatonVersion = "2.0"

-- Add CVars and required internal tables
CreateConVar("sv_nightstick_stuns", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How many hits the stun stick requires before stunning a user")
CreateConVar("sv_nightstick_stuntime", 4, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How long the nightstick will stun a user (In Seconds)")
CreateConVar("sv_nightstick_disarm", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable or disable disarming someone on hit.")

SWEP.hitRequireForStun = GetConVar("sv_nightstick_stuns"):GetInt() 
SWEP.StunTime = GetConVar("sv_nightstick_stuntime"):GetInt()

local StunnedUsers = StunnedUsers or {}

if SERVER then
	util.AddNetworkString("baton_stunned")
end

-- Render all the clientside text
if CLIENT then

	-- Visibility check for convenience and not esp lmao
	local function canSee(ply)
		if ply == LocalPlayer() then return false end
		if LocalPlayer():GetShootPos():Distance(ply:GetPos()) > 1500 then return false end

		local trace = util.TraceLine({
			start = LocalPlayer():GetShootPos(), 
			endpos = ply:GetPos() + Vector(0, 0, 40),
			mask = CONTENTS_SOLID,
			filter = LocalPlayer()
		})

		if trace.Hit then return false end
		return true
	end

	-- visual slump when hit
	net.Receive("baton_stunned", function()
		local ply = net.ReadEntity()
		local stunned = net.ReadBool()
		if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
			if stunned then
				ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_HL2MP_IDLE_SLAM, false)   
			else
				ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
			end
		end	
	end)
	
	function SWEP:DrawHUD()
		for _, ply in pairs(player.GetAll()) do 
			if ply:GetNWInt("baton_stun_text", 0) + self.StunTime > CurTime() then
				if canSee(ply) then 
					local ang = (LocalPlayer():EyePos() - ply:EyePos()):Angle()
					ang.p = 0
					cam.Start3D()
					cam.Start3D2D(ply:EyePos() + LocalPlayer():GetRight() * - 12 - Vector(0,0, 20), ang + Angle(0, 90, 90), 0.15)
						draw.SimpleText("STUNNED", "TargetID", 41, 1, Color(25, 25, 25)) -- shadow outline
						draw.SimpleText("STUNNED", "TargetID", 40, 0, Color(255, 255, 255))
					cam.End3D2D()
					cam.End3D()	
				end
			end	 
		end
	end
end

function SWEP:Initialize()
    self:SetWeaponHoldType("melee")
end

-- Convenient function for stuns
function SWEP:Stun(ply)
	if not SERVER then return end
	
	StunnedUsers[ply:SteamID()] = true
	
	ply:Freeze(true)
	ply:SetEyeAngles(Angle(60, ply:EyeAngles()[2], ply:EyeAngles()[3]))
	ply:SetNWInt('baton_stun_text', CurTime())
	net.Start("baton_stunned") 
		net.WriteEntity(ply) 
		net.WriteBool(true) 
	net.Broadcast()

	timer.Create("baton_unstun" .. tostring(ply:EntIndex()), self.StunTime, 1, function()
		if IsValid(ply) then
			StunnedUsers[ply:SteamID()] = nil

			ply:Freeze(false)
			net.Start("baton_stunned")
				net.WriteEntity(ply)
				net.WriteBool(false)
			net.Broadcast()
		end
	end)
end

-- magic happens here
function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire( CurTime() + 0.43 )

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	-- tables condense code, also makes it easier to add/remove materials
	local ValidMaterials = {
		[89] = true, -- Glass
		[76] = true, -- Plastic
		[87] = true, -- Wood
		[67] = true, -- Concrete
		[68] = true, -- Dirt
		[77] = true, -- Metal
		[85] = true -- Grass
	}

	local MaterialSounds = {
		[67] = "physics/concrete/concrete_impact_hard",
		[68] = "physics/concrete/concrete_impact_hard",
		[87] = "physics/wood/wood_box_impact_hard",
		[77] = "physics/metal/metal_barrel_impact_hard",
		[85] = "player/footsteps/grass"
	}

	--  changed to a hulltrace for leniancy
    local batonTrace = {
        start = self.Owner:GetShootPos(),
        endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 90,
        mins = Vector( -5, -5, -5 ),
        maxs = Vector( 5, 5, 5 ),
        filter = self.Owner
    }
	
	-- lag compensation or melee is ass lmao
	self:GetOwner():LagCompensation(true)
    local trace = util.TraceHull(batonTrace)
	self:GetOwner():LagCompensation(false)

    if trace.Hit then
		if ValidMaterials[trace.MatType] and not trace.Entity:IsPlayer() then
			self.Weapon:EmitSound(string.format("%s%i%s", MaterialSounds[trace.MatType], math.random(1.3), ".wav"))
		end

		if trace.Entity:IsPlayer() then
			self.Weapon:EmitSound(string.format("%s%i%s", "physics/body/body_medium_impact_soft", math.random(1, 7), ".wav"))

			local ply = trace.Entity

			if StunnedUsers[ply:SteamID()] then return end

			-- pull data from previous tick if available otherwise set values
			local hits = ply.hitByStick or 0
			local lTime = ply.lastStickHit or CurTime()
		
			-- calculate required hits via server time
			if CurTime() > lTime + self.RecoveryTime then 
				hits = 0
			end
			local increase = 1

			-- store data for next check
			ply.hitByStick = hits + increase
			ply.lastStickHit = CurTime()

			-- if successful, run code
			if hits + increase >= self.hitRequireForStun then
				-- add knockback but prevent bhop abuse to get sent flying away from police
				if trace.Entity:IsOnGround() then
					trace.Entity:SetVelocity((trace.Entity:GetPos() - self:GetOwner():GetPos()) * 5)
				else
					trace.Entity:SetVelocity(trace.Entity:GetAngles():Up() * -80)
				end
			
				-- we still want baton physics but this will just not run if the user is already stunned
				if not StunnedUsers[trace.Entity:SteamID()] then
					self:Stun(trace.Entity)

					if GetConVar("sv_nightstick_disarm"):GetInt() == 1 then
						trace.Entity:SetActiveWeapon(nil)
					end
				end
			end
		end
    else
        self.Weapon:EmitSound(Sound("WeaponFrag.Throw"))
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:OnDrop()
	return true
end

function SWEP:OnRemove()
	return true
end

-- draws weapon info
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	if self.SelectIcon then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetTexture(surface.GetTextureID(self.SelectIcon))
		surface.DrawTexturedRect(x + 20, y + 20, 200, 120)
	else
		draw.SimpleText(self.IconLetter, self.SelectFont, x + wide / 2, y + tall * 0.2, Color(255, 210, 0, alpha), TEXT_ALIGN_CENTER)
	end

	y = y + 10
	x = x + 10
	wide = wide - 20

	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end

function SWEP:Precache()
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheModel(self.ViewModel)
	util.PrecacheModel(self.WorldModel)
end

-- recently added console command, really only for the developer/powerusers
concommand.Add("nightstick_info", function()
	local InfoTable = {
		"https://steamcommunity.com/sharedfiles/filedetails/?id=2482351689 created by Haze_of_dream",
		"",
		"Contact at: ",
		"STEAM_0:1:75838598",
		"https:/steamcommunity.com/id/Haze_of_dream",
		"",
		string.format("Nightstick Version: %s", BatonVersion)
	}
	
	for _, msg in pairs(InfoTable) do
		print(msg)
	end
end)