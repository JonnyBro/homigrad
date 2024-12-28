
SWEP.PrintName = "Extinguisher (Infinite)"
SWEP.Author = "Robotboy655"
SWEP.Category = "Разное"
SWEP.Contact = "http://steamcommunity.com/profiles/76561197996891752"
SWEP.Purpose = "To extinguish fire!"
SWEP.Instructions = "Shoot into a fire, to extinguish it."
SWEP.AdminOnly = true
SWEP.Base = "weapon_extinguisher"

SWEP.SlotPos = 36
SWEP.IsInfinite = true
SWEP.Spawnable = true

SWEP.Primary.Ammo = "none"

function SWEP:Ammo1()
	return 500
end

if ( SERVER ) then return end

SWEP.WepSelectIcon = Material( "icons/rb655_extinguisher_icon_inf.png" )

function SWEP:CustomAmmoDisplay()
	return { Draw = false }
end
