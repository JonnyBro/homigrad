AddCSLuaFile()

SWEP.Base 						= "weapon_base"

SWEP.Spawnable					= true
SWEP.AdminSpawnable				= true

SWEP.Category					= "Other"
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
								FireRate	= 1.5
}
SWEP.Secondary					= SWEP.Primary
SWEP.NextReload					= 0
SWEP.DrawAmmo					= false
SWEP.Text						= ""

local COL_RED = Color(255,0,0,255)
local COL_GREEN = Color(0,255,0,255)
local COL_BLUE = Color(0,0,255,255)
local COL_YELLOW = Color(150,200,0,255)
local COL_WHITE = Color(255,255,255,255)
local COL_BLACK = Color(0,0,0,255)
local MinsVal = Vector(-1,-1,-1)
local MaxsVal = -MinsVal
local Mins,Maxs = Vector(),Vector()
local test_maxs = Vector(5,5,5)
local test_mins = -test_maxs
local mat = Material("models/debug/debugwhite")
local ang = Angle(0,180)
local angle_zero = Angle()
local vector_zero = Vector()

local Tracks = {
	["LeftTrack"]	= true,
	["RightTrack"]	= true,
}

local boxNormals = {
	Vector(0,1,1),
	Vector(0,1,0),
	Vector(0,1,1),
	Vector(-1,0,0),
	Vector(0,-1,0),
	Vector(0,-1,1)
}

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
	
	debugoverlay.BoxAngles(pos,Mins,Maxs,ang,ft,col,false)
	
	-- render.SetMaterial(mat)
	-- render.DrawBox(pos,ang,Mins,Maxs,col)
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



function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end


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
	-- tr.HitNormalAngle = vehicle:WorldToLocalAngles(tr.NormalAngle + tr.HitNormalAngleLocal - ang)
	tr.LocalHitPos = vehicle:WorldToLocal(tr.HitPos)
	_,tr.HitNormalAngle = WorldToLocal(tr.HitPos,tr.NormalAngle,tr.LocalHitPos,tr.HitNormal:Angle())
	tr.HitNormalAngle:RotateAroundAxis(tr.HitNormalAngle:Up(),180)
	
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
	tr = (tr.Entity.CachedSpawnList and gred.simfphys[tr.Entity.CachedSpawnList] and gred.simfphys[tr.Entity.CachedSpawnList].Armour and gred.simfphys[tr.Entity.CachedSpawnList].Armour.GetArmourThickness and gred.simfphys[tr.Entity.CachedSpawnList].Armour.GetArmourThickness(vehicle,tr)) or tr
	
	if not gred.CVars.gred_sv_simfphys_realisticarmour:GetBool() then
		tr.ArmourThicknessKE = tr.Entity:GetMaxHealth()*0.01
		tr.ArmourThicknessCHEMICAL = tr.ArmourThicknessKE
	end
	
	return tr
end

local function HitModule(StartPos,Dir,pos,ang,mins,maxs,HitModules,Name,ID,WithinRayPos,WithinRayNormal,WithinRayFraction,FractionMul)
	WithinRayPos,WithinRayNormal,WithinRayFraction = util.IntersectRayWithOBB(StartPos,Dir,pos,ang,mins,maxs)
	
	if WithinRayPos then
		HitModules[Name] = HitModules[Name] or {}
		HitModules[Name][ID] = HitModules[Name][ID] or {}
		table.insert(HitModules[Name][ID],{
			Pos = WithinRayPos,
			Normal = WithinRayNormal,
			Fraction = WithinRayFraction * FractionMul,
		})
	end
end

gred.DoModuleStuff = function(tr,vehicle,self,ShrapnelTab)
	-- local ft = FrameTime() * 2
	local HitModules = {}
	tr.CachedModulesCoordinates = tr.CachedModulesCoordinates or {}
	tr.EntityAng = tr.EntityAng or vehicle:GetAngles()
	
	
	local pos,ang,Lpos,Lang
	local WithinRayPos,WithinRayNormal,WithinRayFraction
	local ShrapnelTabHeader = ShrapnelTab and ShrapnelTab[0]
	
	for Name,Tab in pairs(gred.simfphys[vehicle.CachedSpawnList].Armour.Modules) do
		local v
		tr.CachedModulesCoordinates[Name] = tr.CachedModulesCoordinates[Name] or {}
		for k = 1,#Tab do
			v = Tab[k]
			if v then
				if !tr.CachedModulesCoordinates[Name][k] then
					tr.CachedModulesCoordinates[Name][k] = {}
					if vehicle.ModuleAttachments and v.Attachment and vehicle.ModuleAttachments[v.Attachment] then
						att = vehicle:GetAttachment(vehicle.ModuleAttachments[v.Attachment])
						att.LPos,att.LAng = vehicle:WorldToLocal(att.Pos),vehicle:WorldToLocalAngles(att.Ang)
						Lpos,Lang = LocalToWorld(v.Pos,angle_zero,att.LPos,att.LAng)
						pos = vehicle:LocalToWorld(Lpos)
						ang = vehicle:LocalToWorldAngles(Lang)
					else
						Lpos,Lang = v.Pos,angle_zero
						pos,ang = vehicle:LocalToWorld(v.Pos),tr.EntityAng
					end
					tr.CachedModulesCoordinates[Name][k][1] = pos
					tr.CachedModulesCoordinates[Name][k][2] = ang
				else
					pos,ang = tr.CachedModulesCoordinates[Name][k][1],tr.CachedModulesCoordinates[Name][k][2]
				end
				
				if self then
					local HealthRatio = math.Clamp(vehicle:GetNWInt("ModuleHealth_"..Name.."_"..v.ID,100),0,100) / 100
					local col = HealthRatio == 0 and COL_BLACK or Color(40 + 215*(1 - HealthRatio),140*HealthRatio,200*HealthRatio,255)
					gred.RenderModule(vehicle,pos,v.Mins,v.Maxs,ang,ft,Name,col)
				end
				
				
				if ShrapnelTabHeader then
					HitModule(tr.HitPos,tr.NormalNormalized * ShrapnelTabHeader[2],pos,ang,v.Mins,v.Maxs,HitModules,Name,v.ID,WithinRayPos,WithinRayNormal,WithinRayFraction,0.01)
					
					if not Tracks[Name] then
						for i = 1,ShrapnelTabHeader[12] do
							HitModule(tr.HitPos,ShrapnelTab[i] * ShrapnelTabHeader[3],pos,ang,v.Mins,v.Maxs,HitModules,Name,v.ID,WithinRayPos,WithinRayNormal,WithinRayFraction,1)
							debugoverlay.Line(tr.HitPos,tr.HitPos + ShrapnelTab[i] * ShrapnelTabHeader[3],5,COL_GREEN)
						end
						
						if ShrapnelTabHeader[14] then
							for i = ShrapnelTabHeader[12] + 1,ShrapnelTabHeader[12] + ShrapnelTabHeader[13] + 1 do
								HitModule(ShrapnelTabHeader[14],ShrapnelTab[i] * ShrapnelTabHeader[3],pos,ang,v.Mins,v.Maxs,HitModules,Name,v.ID,WithinRayPos,WithinRayNormal,WithinRayFraction,1)
								debugoverlay.Line(ShrapnelTabHeader[14],ShrapnelTabHeader[14] + ShrapnelTab[i] * ShrapnelTab[0][3],5,COL_RED)
							end
						end
					end
				else
					HitModule(tr.HitPos,tr.Normal * 10,pos,ang,v.Mins,v.Maxs,HitModules,Name,v.ID,WithinRayPos,WithinRayNormal,WithinRayFraction,0.01)
				end
			end
		end
	end
	
	-- if IsValid(self) then
		-- if table.Count(HitModules) < 1 then
			-- self:AddText("None")
		-- else
			-- for k,v in pairs(HitModules) do
				-- self:AddText(k.." : "..(
					-- (v.RayData and "RAY;" or "")..
					-- (v.SphereData and "SPHERE;" or "")..
					-- (v.BoxData and "BOX;" or "")
				-- ))
			-- end
		-- end
	-- end
	
	tr.ModulesHit = HitModules
	
	return tr
end

if CLIENT then
	local function DrawWorldTip(text,pos,tipcol,font,offset)
		pos = pos:ToScreen()
		local black = Color(0,0,0,tipcol.a)
		
		local x = 0
		local y = 0
		local padding = 10
		
		surface.SetFont(font)
		local w,h = surface.GetTextSize(text)
		
		x = pos.x - w*0.5
		y = pos.y - h*0.5 - offset
		
		draw.RoundedBox(8, x-padding-2, y-padding-2, w+padding*2+4, h+padding*2+4, black)
		draw.RoundedBox( 8, x-padding, y-padding, w+padding*2, h+padding*2, tipcol )
		draw.DrawText(text,font,x+w/2,y,black,TEXT_ALIGN_CENTER)
	end
	
	local VehicleVector = Vector()
	local GreyColor = Color(100,100,100,255)
	
	function SWEP:DrawHUD()
		-- local ScrW,ScrH = ScrW(),ScrH()
		local tr = self.Owner:GetEyeTrace()
		self.Text = "This is a dev debug tool, but you can use it to see the armor thickness of the vehicles.\n"
		-- self.Text = self.Text.."Everything is done client side so this tool doesn't affect server performance.\n"
		if IsValid(tr.Entity) and tr.Entity.CachedSpawnList and gred.simfphys[tr.Entity.CachedSpawnList] then
			self.Text = self.Text..tr.Entity.CachedSpawnList
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
				-- if gred.simfphys[tr.Entity.CachedSpawnList].Armour.Modules then
					-- self:AddText("MODULES HIT")
					-- gred.DoModuleStuff(tr,tr.Entity,self)
				-- end
			else
				self:AddText("No module!")
			end
			
			-- if gred.simfphys[tr.Entity.CachedSpawnList].Info then
				-- local Text = [[
-- Nation : ]]..gred.simfphys[tr.Entity.CachedSpawnList].Info.Nation..[[ 
-- Battle rating : ]]..gred.simfphys[tr.Entity.CachedSpawnList].Info.BattleRating..[[ 
-- Units produced : ]]..gred.simfphys[tr.Entity.CachedSpawnList].Info.NumberProduced..[[ 
-- Production date : ]]..gred.simfphys[tr.Entity.CachedSpawnList].Info.ProductionDate..[[ 
-- Description : ]]..gred.simfphys[tr.Entity.CachedSpawnList].Info.Description
				-- VehicleVector.z = tr.Entity.ModelBounds.maxs.z
				
				-- DrawWorldTip(Text,tr.Entity:LocalToWorld(VehicleVector),GreyColor,"GModWorldtip",100)
			-- end
		else
			self.Text = self.Text.."Not an armoured simfphys vehicle!"
		end
		
		draw.DrawText(self.Text,"Trebuchet24",8,0,color_white,TEXT_ALIGN_LEFT)
	end

	local tostring = tostring
	function SWEP:AddText(text)
		self.Text = self.Text.."\n"..tostring(text)
		return self.Text
	end
end