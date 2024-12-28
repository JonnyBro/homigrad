AddCSLuaFile()

SWEP.Category			= "[LVS]"
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= false
SWEP.ViewModel		= "models/weapons/c_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_pistol.mdl"
SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 53
SWEP.Weight 			= 42
SWEP.AutoSwitchTo 		= true
SWEP.AutoSwitchFrom 	= true
SWEP.HoldType			= "pistol"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo		= "none"

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity",0, "Car" )
	self:NetworkVar( "Bool",0, "Active" )
end

if (CLIENT) then
	SWEP.PrintName		= "Remote Controller"
	SWEP.Purpose			= "remote controls [LVS] - Cars [Fake Physics] vehicles"
	SWEP.Instructions		= "Left-Click on a Fake Physics Car to link. Press the Use-Key to start remote controlling."
	SWEP.Author			= "Blu"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 10

	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( "j", "WeaponIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	end

	hook.Add( "PreDrawHalos", "s_remote_halos", function()
		local ply = LocalPlayer()
		local weapon = ply:GetActiveWeapon()
		
		if IsValid( ply ) and IsValid( weapon ) then
			if ply:InVehicle() then return end
			
			if weapon:GetClass() == "weapon_simremote" then
				if not weapon:GetActive() then
					local car = weapon:GetCar()
					
					if IsValid( car ) then
						halo.Add( {car}, Color( 0, 127, 255 ) )
					end
				end
			end
		end
	end )
	
	
	function SWEP:PrimaryAttack()
		if self:GetActive() then return false end
		
		local trace = self:GetOwner():GetEyeTrace()
		local ent = trace.Entity
		
		if not simfphys.IsCar( ent ) then return false end
		
		self.Weapon:EmitSound( "Weapon_Pistol.Empty" )
		
		return true
	end

	function SWEP:SecondaryAttack()
		if self:GetActive() then return false end
		
		self.Weapon:EmitSound( "Weapon_Pistol.Empty" )
		
		return true
	end
	
	return
end

function SWEP:Initialize()
	self.Weapon:SetHoldType( self.HoldType )
end

function SWEP:OwnerChanged()
end

function SWEP:Think()
	if self:GetOwner():KeyPressed( IN_USE ) then
		if self:GetActive() or not IsValid( self:GetCar() ) then
			self:Disable()
		else
			self:Enable()
		end
	end
end

function SWEP:PrimaryAttack()
	if self:GetActive() then return false end
	
	local ply = self:GetOwner()
	local trace = ply:GetEyeTrace()
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	self:SetCar( ent )
	
	ply:ChatPrint("Remote Controller linked.")
	
	return true
end

function SWEP:SecondaryAttack()
	if self:GetActive() then return false end
	
	if IsValid( self:GetCar() ) then
		self:SetCar( NULL )
		self:GetOwner():ChatPrint("Remote Controller unlinked.")
		
		return true
	end
	
	return false
end

function SWEP:Enable()
	local car = self:GetCar()

	if not IsValid( car ) then return end

	local ply = self:GetOwner()

	if IsValid( car:GetDriver() ) then
		ply:ChatPrint("vehicle is already in use")

		return
	end

	if car:GetlvsLockedStatus() then
		ply:ChatPrint("vehicle is locked")
	else
		self:SetActive( true )
		self.OldMoveType = ply:GetMoveType()

		ply:SetMoveType( MOVETYPE_NONE )
		ply:DrawViewModel( false )

		car.RemoteDriver = ply
	end
end

function SWEP:Disable()

	local ply = self:GetOwner()
	local car = self:GetCar()
	
	if self:GetActive() then
		if self.OldMoveType then
	    		ply:SetMoveType( self.OldMoveType )
		else
	    		ply:SetMoveType( MOVETYPE_WALK )
		end
	end
	
	self:SetActive( false )
	self.OldMoveType = nil
	ply:DrawViewModel( true )
	
	if IsValid( car ) then
		car.RemoteDriver = nil
	end
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return true
end

function SWEP:Holster()
	if IsValid( self:GetCar() ) then
		self:Disable()
	end
	return true
end

function SWEP:OnDrop()
	if IsValid( self:GetCar() ) then
		self:Disable()
		self.TheCar = nil
	end
end
