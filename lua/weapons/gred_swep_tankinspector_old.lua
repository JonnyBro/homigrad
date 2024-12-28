AddCSLuaFile()
--[[
hello
this was made for the module system
there's nothing to see here
bye
]]
SWEP.Base 						= "weapon_base"

SWEP.Spawnable					= false
SWEP.AdminSpawnable				= false

SWEP.Category					= "Gredwitch's SWEPs"
SWEP.Author						= "Gredwitch"
SWEP.Contact					= ""
SWEP.Purpose					= ""
SWEP.Instructions				= ""
SWEP.PrintName					= "Tank Inspector SWEP"


SWEP.WorldModel					= "models/mm1/box.mdl"
SWEP.ViewModel 					= "models/mm1/box.mdl"

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
SWEP.Text						= ""

if true then return end

	local COL_RED = Color(255,0,0,255)
	local COL_GREEN = Color(0,255,0,255)
	local COL_BLUE = Color(0,0,255,255)
	local COL_YELLOW = Color(150,200,0,255)
	local COL_WHITE = Color(255,255,255,255)
	local COL_BLACK = Color(0,0,0,255)
	local boxNormals = {
		Vector(0,1,1),
		Vector(0,1,0),
		Vector(0,1,1),
		Vector(-1,0,0),
		Vector(0,-1,0),
		Vector(0,-1,1)
	}
	local test_maxs = Vector(5,5,5)
	local test_mins = -test_maxs

	gred.RenderModule = function(vehicle,pos,Mins,Maxs,ang,ft,Name,col)
		-- if Name == "Ammo" then
			-- debugoverlay.BoxAngles(pos,Mins,Maxs,ang,ft,COL_RED)
		-- elseif Name == "Engine" then
			-- debugoverlay.BoxAngles(pos,Mins,Maxs,ang,ft,COL_GREEN)
		-- elseif Name == "Transmission" then
			-- debugoverlay.BoxAngles(pos,Mins,Maxs,ang,ft,COL_BLUE)
		-- elseif Name == "GunBreach" then
			-- debugoverlay.BoxAngles(pos,Mins,Maxs,ang,ft,COL_WHITE)
		-- elseif Name == "LeftTrack" or Name == "RightTrack" then
			-- debugoverlay.BoxAngles(pos,Mins,Maxs,ang,ft,COL_YELLOW)
		-- else
			-- debugoverlay.BoxAngles(pos,Mins,Maxs,ang,ft,COL_BLACK)
		-- end
		debugoverlay.BoxAngles(pos,Mins,Maxs,ang,ft,col)
	end
	
	gred.RenderVehicleModules = function(vehicle,ft)
		ft = ft or FrameTime() * 2
		for Name,Tab in pairs(gred.simfphys[vehicle.CachedSpawnList].Armour.Modules) do
			for k,v in pairs(Tab) do
				if v.Attachment and vehicle.ModuleAttachments[v.Attachment] then
					att = vehicle:GetAttachment(vehicle.ModuleAttachments[v.Attachment])
					att.LPos,att.LAng = vehicle:WorldToLocal(att.Pos),vehicle:WorldToLocalAngles(att.Ang)
					pos,ang = LocalToWorld(v.Pos,angle_zero,att.LPos,att.LAng)
					pos = vehicle:LocalToWorld(pos)
					ang = vehicle:LocalToWorldAngles(ang)
				else
					pos,ang = vehicle:LocalToWorld(v.Pos),vehang and vehang or vehicle:GetAngles()
				end
				gred.RenderModule(vehicle,pos,v.Mins,v.Maxs,ang,ft,Name,color_white)
			end
		end
	end
	
	local function GetCorners(pos1,mins1,maxs1,pos2,mins2,maxs2)
		local BottomLeftStartPos = pos1 + mins1
		local BottomLeftEndPos = pos2 + mins2
		local BottomLeftDir = BottomLeftStartPos - BottomLeftEndPos
		
		local TopLeftStartPos = pos1 + Vector(mins1.x,mins1.y,maxs1.z)
		local TopLeftEndPos = pos2 + Vector(mins2.x,mins2.y,maxs2.z)
		local TopLeftDir = TopLeftStartPos - TopLeftEndPos
		
		local BottomRightStartPos = pos1 + Vector(maxs1.x,maxs1.y,mins1.z)
		local BottomRightEndPos = pos2 + Vector(maxs2.x,maxs2.y,mins2.z)
		local BottomRightDir = BottomRightStartPos - BottomRightEndPos
		
		local TopRightStartPos = pos1 + maxs1
		local TopRightEndPos = pos2 + maxs2
		local TopRightDir = TopRightStartPos - TopRightEndPos
		
		return BottomLeftStartPos,BottomLeftEndPos,BottomLeftDir,TopLeftStartPos,TopLeftEndPos,TopLeftDir,BottomRightStartPos,BottomRightEndPos,BottomRightDir,TopRightStartPos,TopRightEndPos,TopRightDir
	end
	
	local function VectorToNormal(vec)
		local len = vec:Length()
		return vec / len,len
	end
	
	
	local MinsVal = Vector(-1,-1,-1)
	local MaxsVal = -MinsVal
	local Mins,Maxs = Vector(),Vector()
	
	local function WithinSweptBox(pos,Mins,Maxs)
		return (Mins.z <= pos.z and pos.z <= Maxs.z) and (Mins.y <= pos.y and pos.y <= Maxs.y) and (Mins.x <= pos.x and pos.x <= Maxs.x)
	end
	
	local function DebugAABBBox(StartPos,Mins1,Maxs1,EndPos,Mins2,Maxs2,ft)
		ft = ft or FrameTime() * 2
		debugoverlay.Line(StartPos+Mins1,EndPos+Mins2,ft,color_white) -- bottom left
		debugoverlay.Line(StartPos+Vector(Mins1.x,Mins1.y,Maxs1.z),EndPos+Vector(Mins2.x,Mins2.y,Maxs2.z),ft,color_white) -- top left
		debugoverlay.Line(StartPos+Vector(Maxs1.x,Maxs1.y,Mins1.z),EndPos+Vector(Maxs2.x,Maxs2.y,Mins2.z),ft,color_white) -- bottom right
		debugoverlay.Line(StartPos+Maxs1,EndPos+Maxs2,ft,color_white) -- top right
		debugoverlay.Box(StartPos,Mins1,Maxs1,ft,color_white)
		debugoverlay.Box(EndPos,Mins2,Maxs2,ft,COL_BLACK)
	end
	

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

local ang = Angle(0,180)
local angle_zero = Angle()
local vector_zero = Vector()

gred.CalculateArmourThickness = function(tr,vehicle)
	tr.CalculatedImpactCos = math.abs(math.cos(math.rad(tr.HitNormalAngle.y))*math.cos(math.rad(tr.HitNormalAngle.p)))
	tr.EffectiveArmourThicknessKE = tr.ArmourThicknessKE / tr.CalculatedImpactCos
	tr.EffectiveArmourThicknessCHEMICAL = tr.ArmourThicknessCHEMICAL / tr.CalculatedImpactCos
	return tr
end

gred.GetImpactInfo = function(tr,vehicle)
	vehicle = vehicle or tr.Entity
	tr.HitNormalAngleLocal = vehicle:WorldToLocalAngles(tr.HitNormal:Angle())
	tr.NormalAngle = tr.Normal:Angle()
	tr.LocalNormalAngle = vehicle:WorldToLocalAngles(tr.NormalAngle)
	tr.LocalNormal = tr.LocalNormalAngle:Forward()
	tr.HitNormalAngle = vehicle:WorldToLocalAngles(tr.NormalAngle + tr.HitNormalAngleLocal - ang)
	tr.LocalHitPos = vehicle:WorldToLocal(tr.HitPos)
	
	tr.YawSideDetection = (tr.HitNormalAngleLocal.y <= -45 and tr.HitNormalAngleLocal.y >= -145)
		and GRED_TANK_RIGHT
	or ((tr.HitNormalAngleLocal.y >= 145 or tr.HitNormalAngleLocal.y <= -145)
		and GRED_TANK_REAR
		or ((tr.HitNormalAngleLocal.y >= 45 and tr.HitNormalAngleLocal.y <= 145)
			and GRED_TANK_LEFT
			or GRED_TANK_FRONT))
	
	tr.PitchSideDetection = tr.HitNormalAngleLocal.p <= -45 
		and GRED_TANK_TOP 
		or (tr.HitNormalAngleLocal.p >= 45 
			and GRED_TANK_BOTTOM 
			or GRED_TANK_NONE)
	-- if tr.PitchSideDetection != GRED_TANK_NONE then math.abs(tr.HitNormalAngleLocal.p != 
	return gred.simfphys[tr.Entity.CachedSpawnList].Armour.GetArmourThickness(vehicle,tr)
end

gred.DoModuleStuff = function(tr,vehicle,self)
	local HitModules = {}
	tr.Caliber = tr.Caliber or 75
	tr.ShellLastVel = tr.ShellLastVel or 700
	local SphereRadius = tr.TNTEquivalent and (1 / tr.TNTEquivalent)*2.5 or nil
	local Caliber = tr.Caliber * 0.3
	local vehang = vehicle:GetAngles()
	local vehpos = vehicle:GetPos()
	local ft = FrameTime() * 2
	
	
	local Normal = tr.Normal * ((tr.StartPos:Distance(tr.HitPos)) + tr.ShellLastVel*0.0025) -- Direction + Speed of the shell * Fuse time
	local EndPos = tr.StartPos + Normal
	local HEATMins,HEATMaxs = MinsVal * Caliber,MaxsVal * Caliber
	local ModelMins,ModelMaxs = vehicle.ModelBounds.mins,vehicle.ModelBounds.maxs
	local ModelSize = ModelMaxs - ModelMins
	
	local DirTest = LocalToWorld(tr.LocalNormal,vehang,vector_zero,angle_zero)
	local pos,ang,Lpos,Lang,Direction,Length
	local WithinRayPos,WithinRayNormal,WithinRayFraction
	local WithinSpherePos,WithinSphereNormal,WithinSphereFraction
	local WithinBoxPos,WithinBoxNormal,WithinBoxFraction
	
	local BoundingHitPos = tr.LocalHitPos + DirTest * (ModelMaxs - ModelMins):Length()
	BoundingHitPos = vehicle:LocalToWorld(BoundingHitPos)
	
	-- DebugAABBBox(tr.HitPos,MinsVal,MaxsVal,BoundingHitPos,HEATMins,HEATMaxs,ft)
	
	local BottomLeftStartPos,BottomLeftEndPos,BottomLeftDir,TopLeftStartPos,TopLeftEndPos,TopLeftDir,BottomRightStartPos,BottomRightEndPos,BottomRightDir,TopRightStartPos,TopRightEndPos,TopRightDir = GetCorners(tr.HitPos,Mins,Maxs,BoundingHitPos,HEATMins,HEATMaxs)
	--[[local BottomLeftStartPos,BottomLeftEndPos,BottomLeftDir,TopLeftStartPos,TopLeftEndPos,TopLeftDir,BottomRightStartPos,BottomRightEndPos,BottomRightDir,TopRightStartPos,TopRightEndPos,TopRightDir = GetCorners(tr.LocalHitPos,HEATMins,HEATMaxs,BoundingHitPos,HEATMins,HEATMaxs)
	
	Mins = Vector()
	Maxs = Vector()
	Mins.x = BottomLeftStartPos.x <= TopRightEndPos.x and BottomLeftStartPos.x or TopRightEndPos.x
	Mins.y = BottomLeftStartPos.y <= TopRightEndPos.y and BottomLeftStartPos.y or TopRightEndPos.y
	Mins.z = BottomLeftStartPos.z <= TopRightEndPos.z and BottomLeftStartPos.z or TopRightEndPos.z
	Maxs.x = BottomLeftStartPos.x >= TopRightEndPos.x and BottomLeftStartPos.x or TopRightEndPos.x
	Maxs.y = BottomLeftStartPos.y >= TopRightEndPos.y and BottomLeftStartPos.y or TopRightEndPos.y
	Maxs.z = BottomLeftStartPos.z >= TopRightEndPos.z and BottomLeftStartPos.z or TopRightEndPos.z
	Mins = LocalToWorld(Mins,vehang,vector_zero,angle_zero)
	Maxs = LocalToWorld(Maxs,vehang,vector_zero,angle_zero)
	
	debugoverlay.SweptBox(tr.HitPos,BoundingHitPos,HEATMins,HEATMaxs,angle_zero,FrameTime()*2,COL_BLACK)]]
	-- print(SphereRadius)
	if SphereRadius then
		-- debugoverlay.Line(tr.StartPos,tr.StartPos + Normal,5,color_white)
		-- debugoverlay.Sphere(tr.StartPos + Normal,SphereRadius,5,COL_WHITE)
	end
	
	for Name,Tab in pairs(gred.simfphys[vehicle.CachedSpawnList].Armour.Modules) do
		local v
		for k = 1,#Tab do
			v = Tab[k]
			if v then
				if vehicle.ModuleAttachments and v.Attachment and vehicle.ModuleAttachments[v.Attachment] then
					att = vehicle:GetAttachment(vehicle.ModuleAttachments[v.Attachment])
					att.LPos,att.LAng = vehicle:WorldToLocal(att.Pos),vehicle:WorldToLocalAngles(att.Ang)
					Lpos,Lang = LocalToWorld(v.Pos,angle_zero,att.LPos,att.LAng)
					pos = vehicle:LocalToWorld(Lpos)
					ang = vehicle:LocalToWorldAngles(Lang)
				else
					Lpos,Lang = v.Pos,angle_zero
					pos,ang = vehicle:LocalToWorld(v.Pos),vehang
				end
				
				local HealthRatio = math.Clamp(vehicle:GetNWInt("ModuleHealth_"..Name.."_"..v.ID,100),0,100) / 100
				local col = HealthRatio == 0 and COL_BLACK or Color(40 + 215*(1 - HealthRatio),140*HealthRatio,200*HealthRatio,255)
				gred.RenderModule(vehicle,pos,v.Mins,v.Maxs,ang,ft,Name,col)
				
				WithinRayPos,WithinRayNormal,WithinRayFraction = util.IntersectRayWithOBB(tr.StartPos,Normal,pos,ang,v.Mins,v.Maxs)
				Direction,Length = VectorToNormal(pos - EndPos)
				if tr.TNTEquivalent then 
					WithinSpherePos,WithinSphereNormal,WithinSphereFraction = util.IntersectRayWithOBB(EndPos,Direction * SphereRadius,pos,ang,v.Mins,v.Maxs)
				end
				if tr.DoBox then
					if WithinRayPos then
						WithinBoxPos,WithinBoxNormal,WithinBoxFraction = WithinRayPos,WithinRayNormal,WithinRayFraction
					else
						WithinBoxPos,WithinBoxNormal,WithinBoxFraction = util.IntersectRayWithOBB(BottomLeftStartPos,BottomLeftEndPos - BottomLeftStartPos,pos,ang,v.Mins,v.Maxs)
						-- debugoverlay.Line(BottomLeftStartPos,BottomLeftEndPos,ft,color_white)
						if !WithinBoxPos then
							WithinBoxPos,WithinBoxNormal,WithinBoxFraction = util.IntersectRayWithOBB(TopLeftStartPos,TopLeftEndPos - TopLeftStartPos,pos,ang,v.Mins,v.Maxs)
							-- debugoverlay.Line(TopLeftStartPos,TopLeftEndPos,ft,color_white)
							if !WithinBoxPos then
								WithinBoxPos,WithinBoxNormal,WithinBoxFraction = util.IntersectRayWithOBB(BottomRightStartPos,BottomRightEndPos - BottomRightStartPos,pos,ang,v.Mins,v.Maxs)
								-- debugoverlay.Line(BottomRightStartPos,BottomRightEndPos,ft,color_white)
								if !WithinBoxPos then
									WithinBoxPos,WithinBoxNormal,WithinBoxFraction = util.IntersectRayWithOBB(TopRightStartPos,TopRightEndPos - TopRightStartPos,pos,ang,v.Mins,v.Maxs)
								-- debugoverlay.Line(TopRightStartPos,TopRightEndPos,ft,color_white)
								end
							end
						end
						-- local BottomLeftRear,BottomLeftFront,BottomLeftDir,TopLeftRear,TopLeftFront,TopLeftDir,BottomRightRear,BottomRightFront,BottomRightDir,TopRightRear,TopRightFront,TopRightDir = GetCorners(Lpos,v.Mins,v.Maxs,Lpos,v.Mins,v.Maxs)
						
						-- if WithinSweptBox(BottomLeftRear,Mins,Maxs) then
							-- WithinBoxPos = BottomLeftRear
							-- WithinBoxNormal = BottomLeftDir
							-- WithinBoxFraction = 1
						-- elseif WithinSweptBox(BottomLeftFront,Mins,Maxs) then
							-- WithinBoxPos = BottomLeftFront
							-- WithinBoxNormal = -BottomLeftDir
							-- WithinBoxFraction = 1
						-- elseif WithinSweptBox(TopLeftRear,Mins,Maxs) then
							-- WithinBoxPos = TopLeftRear
							-- WithinBoxNormal = TopLeftDir
							-- WithinBoxFraction = 1
						-- elseif WithinSweptBox(TopLeftFront,Mins,Maxs) then
							-- WithinBoxPos = TopLeftFront
							-- WithinBoxNormal = -TopLeftDir
							-- WithinBoxFraction = 1
						-- elseif WithinSweptBox(BottomRightRear,Mins,Maxs) then
							-- WithinBoxPos = BottomRightRear
							-- WithinBoxNormal = BottomRightDir
							-- WithinBoxFraction = 1
						-- elseif WithinSweptBox(BottomRightFront,Mins,Maxs) then
							-- WithinBoxPos = BottomRightFront
							-- WithinBoxNormal = -BottomRightDir
							-- WithinBoxFraction = 1
						-- elseif WithinSweptBox(TopRightRear,Mins,Maxs) then
							-- WithinBoxPos = TopRightRear
							-- WithinBoxNormal = TopRightDir
							-- WithinBoxFraction = 1
						-- elseif WithinSweptBox(TopRightFront,Mins,Maxs) then
							-- WithinBoxPos = TopRightFront
							-- WithinBoxNormal = -TopRightDir
							-- WithinBoxFraction = 1
						-- end
					end
				end
				if WithinSpherePos or WithinRayPos or WithinBoxPos then
					HitModules[Name] = HitModules[Name] or {}
					HitModules[Name][v.ID] = HitModules[Name][v.ID] or {}
					local tab = {}
					
					if WithinRayPos then
						tab.RayData = {
							Pos = WithinRayPos,
							Normal = WithinRayNormal,
							Fraction = WithinRayFraction,
						}
						-- debugoverlay.Line(tr.StartPos,tr.StartPos + Normal,ft,color_white)
					end
					if WithinSpherePos then
						tab.SphereData = {
							Pos = WithinSpherePos,
							Normal = WithinSphereNormal,
							Fraction = WithinSphereFraction,
						}
						-- debugoverlay.Sphere(tr.StartPos + Normal,SphereRadius,ft,COL_WHITE)
					end
					if WithinBoxPos then
						tab.BoxData = {
							Pos = WithinSpherePos,
							Normal = WithinSphereNormal,
							Fraction = WithinSphereFraction,
						}
					end
					HitModules[Name][v.ID][#HitModules[Name][v.ID] + 1] = tab
				end
			end
		end
	end
	
	if IsValid(self) then
		-- gred.RenderVehicleModules(vehicle)
		if table.Count(HitModules) < 1 then
			self:AddText("None")
		else
			for k,v in pairs(HitModules) do
				self:AddText(k.." : "..(
					(v.RayData and "RAY;" or "")..
					(v.SphereData and "SPHERE;" or "")..
					(v.BoxData and "BOX;" or "")
				))
			end
		end
	end
	
	tr.ModulesHit = HitModules
	
	return tr
end

if CLIENT then
	function SWEP:DrawHUD()
		-- local ScrW,ScrH = ScrW(),ScrH()
		local tr = self.Owner:GetEyeTrace()
		self.Text = ""
		if IsValid(tr.Entity) and tr.Entity.CachedSpawnList and gred.simfphys[tr.Entity.CachedSpawnList] then
			self.Text = tr.Entity.CachedSpawnList
			if gred.simfphys[tr.Entity.CachedSpawnList].Armour then
				tr = gred.GetImpactInfo(tr,tr.Entity)
				
				self:AddText("LOCAL TANK IMPACT ANGLE")
				self:AddText(tr.HitNormalAngleLocal)
				self:AddText("IMPACT POS")
				self:AddText(tr.LocalHitPos)
				self:AddText("IMPACT ANGLE")
				self:AddText(tr.HitNormalAngle)
				
				self:AddText(tr.YawSideDetection == GRED_TANK_RIGHT and "RIGHT SIDE" or tr.YawSideDetection == GRED_TANK_FRONT and "FRONT" or tr.YawSideDetection == GRED_TANK_REAR and "REAR" or "LEFT SIDE")
				self:AddText(tr.PitchSideDetection == GRED_TANK_NONE and "FACE" or tr.PitchSideDetection == GRED_TANK_TOP and "TOP" or tr.PitchSideDetection == GRED_TANK_BOTTOM and "BOTTOM" or "NONE")
				self:AddText("ARMOUR PLATE THICKNESS AGAINST KE AMMO")
				self:AddText(tr.ArmourThicknessKE)
				self:AddText("ARMOUR PLATE THICKNESS AGAINST CHEMICAL AMMO")
				self:AddText(tr.ArmourThicknessCHEMICAL)
				
				tr = gred.CalculateArmourThickness(tr,tr.Entity,0)
				
				self:AddText("EFFECTIVE ARMOUR PLATE THICKNESS AGAINST KE AMMO")
				self:AddText(tr.EffectiveArmourThicknessKE)
				self:AddText("EFFECTIVE ARMOUR PLATE THICKNESS AGAINST CHEMICAL AMMO")
				self:AddText(tr.EffectiveArmourThicknessCHEMICAL)
				if gred.simfphys[tr.Entity.CachedSpawnList].Armour.Modules then
					-- self:AddText("MODULES HIT")
					gred.DoModuleStuff(tr,tr.Entity)
				end
			else
				self:AddText("No module!")
			end
		else
			self.Text = "Not an armoured simfphys vehicle!"
		end
		draw.DrawText(self.Text,"Trebuchet24",8,0,color_white,TEXT_ALIGN_LEFT)
	end

	local tostring = tostring
	function SWEP:AddText(text)
		self.Text = self.Text.."\n"..tostring(text)
		return self.Text
	end
end