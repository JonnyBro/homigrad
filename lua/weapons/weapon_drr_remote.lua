AddCSLuaFile()

SWEP.PrintName	= "Remote Controller"
SWEP.Category = "Drones Rewrite Tools"
SWEP.Purpose = "Tool that allows you drive drones"

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

SWEP.ViewModel = "models/dronesrewrite/c_controller/c_controller.mdl"
SWEP.WorldModel = "models/dronesrewrite/w_controller/w_controller.mdl"

SWEP.TargetDRR = NULL
SWEP.IndexDRR = 0
SWEP.WaitDRR = 0

SWEP.RemoteDRRDistance = 4096

function SWEP:DoIdle()
	timer.Create("weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function() 
		if IsValid(self) then 
			self:SendWeaponAnim(ACT_VM_IDLE) 
			self:DoIdle()
		end 
	end)
end

function SWEP:Initialize()
	self:SetHoldType("slam")
end

function SWEP:DrawHUD()
	if SERVER then return end
	if self.Owner:GetNWEntity("DronesRewriteDrone"):IsValid() then return end

	local tr = util.TraceLine({
		start = EyePos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.RemoteDRRDistance,
		filter = self.Owner
	})

	local ent = tr.Entity
	local text = "Drone that you're looking at - "

	if not IsValid(ent) then 
		ent = self:GetNWEntity("DronesRewriteDrone") 
		text = "Chosen drone - "
	end

	if IsValid(ent) and ent.IS_DRR then
		local x, y = ScrW() / 2, ScrH() - 220
		draw.SimpleText(text .. ent:GetUnit(), "DronesRewrite_customfont2_1", x, y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER)

		local pos = ent:LocalToWorld(ent:OBBCenter())
		local tr = util.TraceLine({
			start = EyePos(),
			endpos = pos,
			filter = self.Owner
		})

		if tr.Hit and tr.Entity != ent then return end

		local pos = pos:ToScreen()

		local size = math.sin(CurTime() * 2) * 30
		surface.DrawCircle(pos.x, pos.y, size, Color(255, 255, 255, 50))

		local size = math.sin(CurTime() * 4) * 30
		surface.DrawCircle(pos.x, pos.y, size, Color(255, 255, 255, 50))

		surface.SetMaterial(Material("stuff/signal"))
		surface.SetDrawColor(Color(255, 255, 255, math.abs(math.sin(CurTime()) * 128)))
		surface.DrawTexturedRect(pos.x - 64, pos.y - 16, 32, 32)

		--surface.SetDrawColor(Color(255, 255, 255, 10 + math.sin(CurTime() * 6) * 10))
		--surface.DrawLine(x, y, pos.x, pos.y)
	end
end

function SWEP:Think()
	if SERVER and IsValid(self.TargetDRR) then
		if self.TargetDRR:IsFarFarAway(self.Owner) then
			self.TargetDRR = NULL
			self:SetNWEntity("DronesRewriteDrone", NULL)

			self:EmitSound("drones/alarm.wav", 75, 64)
		end
	end

	if CLIENT and self.Owner:KeyDown(IN_RELOAD) and CurTime() > self.WaitDRR and not self.Owner:GetNWEntity("DronesRewriteDrone"):IsValid() then
		self.WaitDRR = CurTime() + 0.3

		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.RemoteDRRDistance,
			filter = self.Owner
		})

		local drone = tr.Entity
		if not IsValid(drone) then drone = self:GetNWEntity("DronesRewriteDrone") end
		if not drone.IS_DRR then return end
		--if not drone:CanBeControlledBy(self.Owner) then return end

		local win = DRONES_REWRITE.CreateWindow(365, 400)
		local p = DRONES_REWRITE.CreateScrollPanel(0, 25, 365, 375, win)

		win:SetTitle("This is key menu")

		local count = 1
		for bind, v in SortedPairs(DRONES_REWRITE.Keys) do
			local btn = DRONES_REWRITE.CreateButton(bind, 1, 1 + (count - 1) * 21, 242, 20, p, function()
				net.Start("dronesrewrite_clickkey")
					net.WriteEntity(drone)
					net.WriteString(bind)
				net.SendToServer()
			end)

			local btn = DRONES_REWRITE.CreateButton("Press / Unpress", 244, 1 + (count - 1) * 21, 120, 20, p, function(btn)
				net.Start("dronesrewrite_presskey")
					net.WriteEntity(drone)
					net.WriteInt(DRONES_REWRITE.ClientCVars.Keys[bind]:GetString(), 8)
				net.SendToServer()
			end)

			count = count + 1
		end
	end
end

function SWEP:PrimaryAttack()
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.RemoteDRRDistance,
		filter = self.Owner
	})

	local ent = tr.Entity
	if not IsValid(tr.Entity) then ent = self.TargetDRR end

	if IsValid(ent) and ent.IS_DRR then
		self:SetNextPrimaryFire(CurTime() + 0.5)
		self:SetNextSecondaryFire(CurTime() + 0.5)

		if SERVER then ent:SetDriver(self.Owner) end
	end
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.9)
	self:SetNextSecondaryFire(CurTime() + 0.9)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	self:DoIdle()

	timer.Create("request_drone" .. self:EntIndex(), self:SequenceDuration() * 0.35, 1, function()
		if not IsValid(self) then return end

		self.Owner:EmitSound("ambient/machines/keyboard7_clicks_enter.wav", 65, 150)

		if CLIENT then return end

		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.RemoteDRRDistance,
			filter = self.Owner
		})

		if tr.Hit and IsValid(tr.Entity) and tr.Entity.IS_DRR then
			self.TargetDRR = tr.Entity
		else
			local function foo()
				local tab

				if DRONES_REWRITE.ServerCVars.NoSignalLimit:GetBool() then
					tab = DRONES_REWRITE.GetDronesRewrite()
				else
					tab = { }

					for k, v in pairs(DRONES_REWRITE.GetDronesRewrite()) do
						if not v:IsFarFarAway(self.Owner) then
							table.insert(tab, v)
						end
					end
				end

				local old = self.TargetDRR

				self.TargetDRR = table.Random(tab)
				if #tab > 1 and IsValid(self.TargetDRR) and self.TargetDRR == old then foo() end
			end

			foo()
		end

		if not IsValid(self.TargetDRR) then 
			self.Owner:EmitSound("buttons/lightswitch2.wav", 65, 160) 
		elseif self.TargetDRR:CanBeControlledBy(self.Owner) then
			self:SetNWBool("Draw", true)

			local pitch = 200
			timer.Create("dosounds" .. self:EntIndex(), 0.1, 3, function()
				if not IsValid(self) then return end

				self:EmitSound("buttons/button17.wav", 65, pitch)
				pitch = pitch + 15
			end)
		end

		self:SetNWEntity("DronesRewriteDrone", self.TargetDRR)
	end)
end

function SWEP:OnRemove()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("request_drone" .. self:EntIndex())
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:DoIdle()

	self:SetDeploySpeed(0.7)
	
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration() * 0.8)
	self:SetNextSecondaryFire(CurTime() + self:SequenceDuration() * 0.8)

	return true
end
