
local ang1 = Angle(90)
local ParticleEffect = ParticleEffect

local DECALS = {
	[MAT_ANTLION] = "Impact.Antlion",
	[MAT_BLOODYFLESH] = "Impact.BloodyFlesh",
	[MAT_FLESH] = "Impact.Blood",
	[MAT_CONCRETE] = "Impact.Concrete",
	[MAT_GLASS] = "Impact.Glass",
	[MAT_METAL] = "Impact.Metal",
	[MAT_COMPUTER] = "Impact.Metal",
	[MAT_WARPSHIELD] = "Impact.Metal",
	[MAT_VENT] = "Impact.Metal",
	[MAT_GRATE] = "Impact.Metal",
	[MAT_SAND] = "Impact.Sand",
	[MAT_WOOD] = "Impact.Wood",
}

local FLESH_MATS = {
	Material("decals/flesh/Blood1_subrect"),
	Material("decals/flesh/Blood2_subrect"),
	Material("decals/flesh/Blood3_subrect"),
	Material("decals/flesh/Blood4_subrect"),
	Material("decals/flesh/Blood5_subrect"),
}

local r_drawmodeldecals = GetConVar("r_drawmodeldecals")
local IsValidModel = util.IsValidModel
local DECAL_MATS = {}

for k,v in pairs(DECALS) do
	DECAL_MATS[v] = DECAL_MATS[v] or Material(util.DecalMaterial(v) or util.DecalMaterial("Impact.Concrete"))
end

-- local

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ang = data:GetAngles()
	local cal = gred.Calibre[data:GetFlags()]
	local isGroundImpact = data:GetMaterialIndex() == 1
	
	if isGroundImpact then
		local tr = util.QuickTrace(pos,pos)
		
		if tr.MatType == MAT_FLESH then
			local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			util.Effect("BloodImpact",effectdata)
		elseif tr.MatType == MAT_ANTLION then
			
		end
		
		if cal == "wac_base_7mm" then
			if tr.Hit and (!r_drawmodeldecals:GetBool() and (IsValid(tr.Entity) and !IsValidModel(tr.Entity:GetModel()) or !IsValid(tr.Entity)) or r_drawmodeldecals:GetBool()) then
				local mat = (tr.MatType and DECALS[tr.MatType]) or "Impact.Concrete"
				
				util.DecalEx(tr.MatType == MAT_FLESH and FLESH_MATS[math.random(1,5)] or DECAL_MATS[mat],tr.Entity,pos,tr.HitNormal,color_white,1,1)
			end
			
			if gred.CVars.gred_cl_noparticles_7mm:GetBool() then return end
			-- local pcfD = gred.CVars.gred_cl_insparticles:GetBool() and "ins_" or "doi_"
			local pcfD = "doi_"
			local mat = data:GetSurfaceProp()
			if gred.MatsStr[mat] then
				ParticleEffect(""..pcfD.."impact_"..gred.MatsStr[mat],pos,ang,nil)
			end
		elseif cal == "wac_base_12mm" then
			if tr.Hit and (!r_drawmodeldecals:GetBool() and (IsValid(tr.Entity) and !IsValidModel(tr.Entity:GetModel()) or !IsValid(tr.Entity)) or r_drawmodeldecals:GetBool()) then
				local mat = (tr.MatType and DECALS[tr.MatType]) or "Impact.Concrete"
				
				util.DecalEx(tr.MatType == MAT_FLESH and FLESH_MATS[math.random(1,5)] or DECAL_MATS[mat],tr.Entity,pos,tr.HitNormal,color_white,1.5,1.5)
			end
			
			if gred.CVars.gred_cl_noparticles_12mm:GetBool() then return end
			-- ParticleEffect("doi_gunrun_impact",pos,ang,nil)
			
			local pcfD = "ins_"
			local mat = data:GetSurfaceProp()
			if gred.MatsStr[mat] then
				ParticleEffect(""..pcfD.."impact_"..gred.MatsStr[mat],pos,ang,nil)
			end
			
		elseif cal == "wac_base_20mm" then
			if tr.Hit and (!r_drawmodeldecals:GetBool() and (IsValid(tr.Entity) and !IsValidModel(tr.Entity:GetModel()) or !IsValid(tr.Entity)) or r_drawmodeldecals:GetBool()) then
				local mat = (tr.MatType and DECALS[tr.MatType]) or "Impact.Concrete"
				
				util.DecalEx(DECAL_MATS[mat],tr.Entity,pos,tr.HitNormal,color_white,3,3)
			end
			
			if gred.CVars.gred_cl_noparticles_20mm:GetBool() then return end
			
			if data:GetSurfaceProp() == 0 then
				ParticleEffect("gred_20mm",pos,ang,nil)
			else
				ParticleEffect("gred_20mm_airburst",pos,ang1,nil)
			end
		elseif cal == "wac_base_30mm" then
			if gred.CVars.gred_cl_noparticles_30mm:GetBool() then return end
			ParticleEffect("30cal_impact",pos,ang,nil)
		elseif cal == "wac_base_40mm" then
			if gred.CVars.gred_cl_noparticles_40mm:GetBool() then return end
			if data:GetSurfaceProp() == 0 then
				ParticleEffect("gred_40mm",pos,ang,nil)
			else
				ParticleEffect("gred_40mm_airburst",pos,ang-ang1,nil)
			end
		end
	else
		if gred.CVars.gred_cl_nowaterimpacts:GetBool() then return end
		if cal == "wac_base_7mm" then
			ParticleEffect("doi_impact_water",pos,-ang1,nil)
		elseif cal == "wac_base_12mm" then
			ParticleEffect("ins_impact_water",pos,-ang1,nil)
		elseif cal == "wac_base_20mm" then
			ParticleEffect("water_small",pos,ang,nil)
		elseif cal == "wac_base_30mm" or cal == "wac_base_40mm" then
			ParticleEffect("water_medium",pos,ang,nil)
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end