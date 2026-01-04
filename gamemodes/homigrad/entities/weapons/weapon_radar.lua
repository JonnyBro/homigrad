SWEP.Base = "weapon_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.radar.name")
	SWEP.Author = "Secret Society" -- Thanks Harrison!
	SWEP.Instructions = language.GetPhrase("hg.radar.inst")
	SWEP.Category = language.GetPhrase("hg.category.traitors")
	SWEP.IconOverride = "materials/items_icons/radaricon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

-- SWEP primary properties
SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

SWEP.Slot = 3
SWEP.SlotPos = 5

-- Model for the SWEP
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/w_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

-- Range and other properties
SWEP.Range = 5000
SWEP.LastUpdate = 0
SWEP.UpdateInterval = 30 -- Time in seconds between updates
SWEP.PlayerLocations = {}

-- Cooldown properties
SWEP.LastPrimaryAttack = 0
SWEP.PrimaryAttackCooldown = 25 -- Cooldown time in seconds

-- Initialize the SWEP
function SWEP:Initialize()
	self:SetHoldType("slam")
end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttack()
	local curTime = CurTime()

	-- Check for cooldown
	if curTime < self.LastPrimaryAttack + self.PrimaryAttackCooldown then return end

	-- Check if there's enough ammo (charges) left
	if self.Primary.ClipSize > 0 then
		self:UpdatePlayerLocations() -- Perform the update

		-- Decrease the clip size
		self.Primary.ClipSize = self.Primary.ClipSize - 1

		-- Set the last attack time
		self.LastPrimaryAttack = curTime

		-- Play sound for the action
		self:GetOwner():EmitSound("ambient/energy/zap" .. math.random(1, 3) .. ".wav", 75, 100, 0.25)
	else
		-- Optionally notify the player that there are no charges left
		if not IsFirstTimePredicted() then self:GetOwner():ChatPrint("#hg.radar.nocharges") end

		self:GetOwner():EmitSound("common/wpn_denyselect.wav")
	end

	return
end

-- Helper function to update player positions
function SWEP:UpdatePlayerLocations()
	-- Clear existing locations
	self.PlayerLocations = {}

	-- Iterate through all players in the game
	for _, ply in ipairs(player.GetAll()) do
		if ply:Team() ~= TEAM_SPECTATOR and ply:IsPlayer() and ply:Alive() and ply ~= self:GetOwner() then
			local plyPos = ply:GetPos() + Vector(0, 0, 30) -- Raise the marker slightly above ground

			table.insert(self.PlayerLocations, {
				pos = plyPos,
				ply = ply
			})
		end
	end
end

-- Material for the sprite (can be replaced with any sprite)
local material = Material("sprites/grip")

hook.Add("HUDPaint", "DrawPlayerSprites", function()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()

	-- Ensure the player is holding the SWEP
	if IsValid(wep) and wep:GetClass() == "weapon_radar" and wep.PlayerLocations and #wep.PlayerLocations > 0 then
		cam.Start3D() -- Start 3D rendering context
			for _, data in ipairs(wep.PlayerLocations) do
				local plyPos = data.pos
				local size = 64 -- Size of the sprite

				-- Decrement the alpha value over time
				data.alpha = data.alpha or 255 -- Initialize alpha if not present
				data.alpha = data.alpha - .12 -- Decrease alpha (adjust this value to control speed)

				-- Clamp the alpha value to not go below 0
				if data.alpha < 0 then data.alpha = 0 end

				-- Set sprite material and draw it at the player's position
				render.SetMaterial(material)
				render.DrawSprite(plyPos, size, size, Color(255, 0, 0, data.alpha)) -- Bright red sprite
			end
		cam.End3D() -- End 3D rendering context
	end
end)

function SWEP:OnRemove()
	-- self.PlayerLocations = {}

	return
end

function SWEP:Deploy()
	self.LastUpdate = 0
end

function SWEP:Holster(wep)
	return true
end