AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "ai_translations.lua" )

include('shared.lua')

SWEP.Weight				= 30		// Decides whether we should switch from/to this
SWEP.AutoSwitchTo			= true		// Auto switch to  we pick it up
SWEP.AutoSwitchFrom			= true		// Auto switch from  you pick up a better weapon

SWEP.Cooldown_Timer         = false

function SWEP:Initialize()
		self:SetWeaponHoldType("ar2")
		
	if self.Owner:GetClass() == "npc_combine_s" then
		if self.Weapon.Owner:LookupSequence("cover_crouch_low") == nil then return end
		local crouchseq = self.Weapon.Owner:LookupSequence("cover_crouch_low") 
				if self.Weapon.Owner:GetSequenceName(crouchseq) == "cover_crouch_low" then	
					self:SetWeaponHoldType("ar2")
					else
					self:SetWeaponHoldType("pistol")
				end
	end
	
	if self.Owner:GetClass() == "npc_metropolice" then
	self:SetWeaponHoldType("smg")	
    end
	
	if self.Owner:GetClass() == "npc_combine_s" or self.Owner:GetClass() == "npc_metropolice" then
	self:Proficiency()
	end
	
	if self.Owner:GetClass() == "npc_combine_s" then
	hook.Add( "Think", self, self.onThink )
	end
	
	self.Weapon.Owner:SetKeyValue( "spawnflags", "256" )
	
	if self.Owner:GetClass() == "npc_citizen" then
	self.Weapon.Owner:Fire( "DisableWeaponPickup" )
	end
end

function SWEP:onThink()
if self.Owner:IsNPC() then
self:NextFire()
end
	end
	
function SWEP:NextFire()
	if !self:IsValid() or !self.Owner:IsValid() then return; end

	if self.Owner:GetActivity() == 16 then
		self:Combine_Shoot_Primary()
			hook.Remove("Think", self)
			
	timer.Simple(0.3, function()
		hook.Add("Think", self, self.NextFire)
		end)
	end
end

function SWEP:Proficiency()
timer.Simple(0.5, function()
if !IsValid(self) or !IsValid(self.Owner) then return; end
		self.Owner:SetCurrentWeaponProficiency(3)
	end)
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:NpcReload()
	if !self:IsValid() or !self.Owner:IsValid() then return; end
	self.Owner:SetSchedule(SCHED_RELOAD)

end

function SWEP:NPCShoot_Primary( ShootPos, ShootDir )
	if (!self:IsValid()) or (!self.Owner:IsValid()) then return;end 

		if self.Owner:GetClass() == "npc_combine_s" then 
			if self.Owner:GetActivity() == 11 then
				self:Combine_Shoot_Primary()
			end
			return
		elseif self.Cooldown_Timer == false then
			self.Cooldown_Timer = true
			self:PrimaryAttack()
			
			timer.Simple(0.175, function()
				if (!self:IsValid()) or (!self.Owner:IsValid()) then
					return;
				end
				if (!self.Owner:GetEnemy()) then
					return;
				end 
				self:PrimaryAttack()
			end)
			
			timer.Simple(0.35, function()
				if (!self:IsValid()) or (!self.Owner:IsValid()) then
					return;
				end
				if (!self.Owner:GetEnemy()) then
					return;
				end 
				self:PrimaryAttack()
			end)

		timer.Simple(0.175, function()
			self.Cooldown_Timer = false
		end)		
	end
end
	
function SWEP:Combine_Shoot_Primary()
	if self.Owner:GetClass() == "npc_combine_s" then
		self:PrimaryAttack()
		
		timer.Simple(0.175, function()
			if (!self:IsValid()) or (!self.Owner:IsValid()) then 
				return;
			end
			if (!self.Owner:GetEnemy()) then 
				return; 
			end 
			self:PrimaryAttack()
		end)
	end
end
