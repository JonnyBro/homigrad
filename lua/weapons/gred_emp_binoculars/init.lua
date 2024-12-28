include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("gred_net_emp_striketype")

local sky = Vector(0,0,100000000)

net.Receive("gred_net_emp_striketype",function(len,ply)
	local self = ply:GetActiveWeapon()
	local int = net.ReadUInt(2)
	
	if not IsValid(self) or self:GetClass() != "gred_emp_binoculars" then return end
	
	self:MarkTarget(int)
end)

function SWEP:PrimaryAttack()
	if self.Owner:KeyDown(IN_ATTACK2) then return end
	
	local tab = self:GetTableFromTrace()
	
	if not tab then return end
	
	self:PairEmplacement(tab[1])
end

function SWEP:SecondaryAttack()
	
end

function SWEP:CanReload(ct)
	return self.NextReload <= ct
end

function SWEP:Reload()
	local ct = CurTime()
	
	if not self:CanReload(ct) then return end
	self.NextReload = ct + 0.3
	
	
end

function SWEP:PairEmplacement(ent)
	if self.PairedEmplacementsIDs[ent] then
		self.Owner:PrintMessage(HUD_PRINTCENTER,gred.Lang[self.Owner:GetInfo("gred_cl_lang") or "en"].EmplacementBinoculars.info_emplacement_unpaired..string.gsub(ent.PrintName,"%[EMP]",""))
		
		if not ent.Unpair then
			ent.Unpair = function(ent,swep)
				ent.PairedWeapons[ent.PairedWeaponsIDs[swep]] = nil
				ent.PairedWeaponsIDs[swep] = nil
			end
		end
		
		self.PairedEmplacements[self.PairedEmplacementsIDs[ent]] = nil
		self.PairedEmplacementsIDs[ent] = nil
		
		ent:Unpair(self)
	else
		self.Owner:PrintMessage(HUD_PRINTCENTER,gred.Lang[self.Owner:GetInfo("gred_cl_lang") or "en"].EmplacementBinoculars.info_emplacement_paired..string.gsub(ent.PrintName,"%[EMP]",""))
		
		if not ent.Pair then
			ent.PairedWeapons = {}
			ent.PairedWeaponsIDs = {}
			
			ent.Pair = function(ent,swep)
				ent.PairedWeaponsIDs[swep] = table.insert(ent.PairedWeapons,swep)
			end
		end
		
		self.PairedEmplacementsIDs[ent] = table.insert(self.PairedEmplacements,ent)
		
		ent:Pair(self)
	end
end



function SWEP:MarkTarget(StrikeType)
	if #self.PairedEmplacements < 0 then return end
	
	local EyeTrace = self.Owner:GetEyeTrace()
	
	local FireMission = {
		self.Owner,
		EyeTrace.HitPos,
		self.FireMissionID,
		CurTime(),
		StrikeType
	}
	
	local tr = util.QuickTrace(EyeTrace.HitPos,EyeTrace.HitPos + sky,EyeTrace.Entity)
	
	if tr.HitSky or !tr.Hit and util.IsInWorld(EyeTrace.HitPos) then
		gred.EmplacementBinoculars.FireMissionID = gred.EmplacementBinoculars.FireMissionID + 1
		self.FireMissionID = gred.EmplacementBinoculars.FireMissionID
		
		self.Owner:PrintMessage(HUD_PRINTCENTER,gred.Lang[self.Owner:GetInfo("gred_cl_lang") or "en"].EmplacementBinoculars.info_firemission.."#"..self.FireMissionID)
		
		for k,v in pairs(self.PairedEmplacements) do
			if !IsValid(v) then
				self.PairedEmplacements[k] = nil
			else
				v.FireMissions = v.FireMissions or {}
				local id = table.insert(v.FireMissions,FireMission)
				
				v.MaxViewModes = #v.FireMissions + v.OldMaxViewModes
				
				net.Start("gred_net_emp_firemission")
					net.WriteEntity(v)
					net.WriteEntity(FireMission[1])
					net.WriteVector(FireMission[2])
					net.WriteUInt(self.FireMissionID,8)
					net.WriteFloat(FireMission[4])
					net.WriteUInt(FireMission[5],2)
				net.Broadcast()
				
				v:EmitSound("buttons/blip1.wav")
				
				if not IsValid(v:GetShooter()) then
					timer.Create("gred_timer_firemission_bip_"..id,1,3,function()
						if IsValid(v) then
							v:EmitSound("buttons/blip1.wav")
						else
							timer.Remove("gred_timer_firemission_bip_"..id)
						end
					end)
				end
				
				timer.Simple(gred.CVars.gred_sv_emplacement_artillery_time:GetFloat(),function()
					if IsValid(v) then
						v.FireMissions[id] = nil
					end
				end)
			end
		end
		
	else
		self.Owner:PrintMessage(HUD_PRINTCENTER,gred.Lang[self.Owner:GetInfo("gred_cl_lang") or "en"].EmplacementBinoculars.info_invalidpos)
	end
end