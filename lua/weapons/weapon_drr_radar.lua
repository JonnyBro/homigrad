AddCSLuaFile()

SWEP.PrintName	= "Radar"
SWEP.Category = "Drones Rewrite Tools"

SWEP.Spawnable	= true
SWEP.UseHands	= true
SWEP.DrawAmmo	= false

SWEP.ViewModelFOV	= 50
SWEP.Slot			= 0
SWEP.SlotPos		= 5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.ViewModel = "models/dronesrewrite/c_radar/c_radar.mdl"
SWEP.WorldModel = "models/dronesrewrite/c_radar/c_radar.mdl"

function SWEP:DoIdle()
	timer.Create("weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function()
		if IsValid(self) then 
			self:SendWeaponAnim(ACT_VM_IDLE) 
			self:DoIdle()
		end 
	end)
end

function SWEP:OnDrop() return false end

function SWEP:Initialize()
	self:SetHoldType("shotgun")

	if CLIENT then self.RangeRadar = 60 end
end

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

function SWEP:OnRemove()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("weapon_active" .. self:EntIndex())

	self:SetNWBool("DRRActivated", false)
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:DoIdle()

	timer.Create("weapon_active" .. self:EntIndex(), 1.8, 1, function()
		if IsValid(self) then self:SetNWBool("DRRActivated", true) end
	end)

	return true
end

if CLIENT then
	local function Circle(x, y, radius, seg)
		-- Code from wiki.garrysmod.com

		local cir = { }

		table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
		for i = 0, seg do
			local a = math.rad((i / seg) * -360)
			table.insert(cir, { 
				x = x + math.sin(a) * radius, 
				y = y + math.cos(a) * radius, 
				u = math.sin(a) / 2 + 0.5, 
				v = math.cos(a) / 2 + 0.5 
			})
		end

		local a = math.rad(0) -- This is needed for non absolute segment counts

		table.insert( cir, { 
			x = x + math.sin(a) * radius, 
			y = y + math.cos(a) * radius, 
			u = math.sin(a) / 2 + 0.5, 
			v = math.cos(a) / 2 + 0.5 
		})

		--surface.SetMaterial(mat)
		--draw.NoTexture()
		surface.DrawPoly(cir)
	end

	function SWEP:ViewModelDrawn()
		if not self:GetNWBool("DRRActivated", false) then return end

		local vm = self.Owner:GetViewModel()

		local bone = vm:LookupBone("ValveBiped.Bip01_L_Hand")
		if not bone then return end

		local pos, ang
		local m = vm:GetBoneMatrix(bone)
		if m then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end

		if not pos or not ang then return end

		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Forward(), -7)

		pos = pos + ang:Right() * 8.6
		pos = pos - ang:Forward() * 0.3
		pos = pos + ang:Up() * 2.4

		cam.Start3D2D(pos, ang, 0.012)
			surface.SetDrawColor(Color(0, 255, 0, 100))

			for i = 1, 15 do surface.DrawLine(i * 50 - 400, -250, i * 50 - 400, 250) end
			for i = 1, 15 do surface.DrawLine(-250, i * 50 - 400, 250, i * 50 - 400) end

			surface.SetDrawColor(Color(100, 255, 100))
			Circle(0, 0, 6, 6)

			surface.SetDrawColor(Color(0, 255, 0, 255))

			for k, v in pairs(DRONES_REWRITE.GetDrones()) do
				if v:GetNWBool("NoDRRRadar", false) then continue end

				local dist = (v:GetPos() - self.Owner:GetPos()):GetNormal()
				dist:Rotate(Angle(0, -self.Owner:EyeAngles().y + 180, 0))

				dist = dist * (v:GetPos():Distance(self.Owner:GetPos()) / self.RangeRadar)
				if dist:Length() > 240 then continue end
					
				Circle(dist.x, dist.y, math.Clamp(12 - self.RangeRadar * 0.1, 4, 12) + math.sin(CurTime() * 10) * 0.5, 12)
			end
		cam.End3D2D()
	end

	function SWEP:Think()
		if IsValid(self.Owner) then
			if self.Owner:KeyDown(IN_ATTACK) then
				self.RangeRadar = math.Approach(self.RangeRadar, 10, 1)
			end

			if self.Owner:KeyDown(IN_ATTACK2) then
				self.RangeRadar = math.Approach(self.RangeRadar, 200, 1)
			end
		end
	end
end
