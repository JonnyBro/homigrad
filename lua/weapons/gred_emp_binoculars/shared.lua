
SWEP.Base 						= "weapon_base"

SWEP.Spawnable					= true
SWEP.AdminSpawnable				= true

SWEP.Category					= "Gredwitch's SWEPs"
SWEP.Author						= "Gredwitch"
SWEP.Contact					= ""
SWEP.Purpose					= ""
SWEP.Instructions				= "Mark targets with the fire button."
SWEP.PrintName					= "Emplacement Binoculars"


SWEP.WorldModel					= "models/weapons/gredwitch/w_binoculars.mdl"
SWEP.ViewModel 					= "models/weapons/gredwitch/v_binoculars.mdl"

SWEP.Primary					= {
								Ammo 		= "None",
								ClipSize 	= -1,
								DefaultClip = -1,
								Automatic 	= false,
								
								---------------------
								
								NextShot	= 0,
								FireRate	= 0.3
}
SWEP.Secondary					= SWEP.Primary
SWEP.NextReload					= 0
SWEP.DrawAmmo					= false

SWEP.Zoom						= {}
SWEP.Zoom.FOV					= 70
SWEP.Zoom.Rate					= 0.02
SWEP.Zoom.Val					= 0

SWEP.FireMissionID				= 0
SWEP.UseHands					= true
SWEP.PairedEmplacements			= {}
SWEP.PairedEmplacementsIDs		= {}
SWEP.MaxPairDistance			= 500^2

function SWEP:InitChoices()
	self.Choices = {
		{
			name = "",
			Decor = true
		},
		{
			name = "Request high explosive artillery",
			-- Decor = true
		},
		{
			name = "",
			Decor = true
		},
		{
			name = "Request white phosphorus artillery",
			-- Decor = true
		},
		{
			name = "",
			Decor = true
		},
		{
			name = "",
			Decor = true
		},
		{
			name = "",
			Decor = true
		},
		{
			name = "Request smoke artillery",
			-- Decor = true
		},
	}
end

function SWEP:Holster(wep)
	return true
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	
	return true
end

function SWEP:Initialize()
	self:SetHoldType("camera")
	
	self:InitChoices()
end

function SWEP:GetEntitiesTable(ent)
	return ent:IsPairable() and ent.Entities or nil
end

function SWEP:GetTableFromTrace()
	local tr = self.Owner:GetEyeTrace()
	
	if IsValid(tr.Entity) and tr.StartPos:DistToSqr(tr.HitPos) < self.MaxPairDistance then
		if IsValid(tr.Entity.GredEMPBaseENT) then
			return self:GetEntitiesTable(tr.Entity.GredEMPBaseENT)
		elseif tr.Entity.IsEmplacement then
			return self:GetEntitiesTable(tr.Entity)
		end
	end
	
	return nil
end