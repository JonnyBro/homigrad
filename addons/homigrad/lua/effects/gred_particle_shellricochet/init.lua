local ParticleEffect = ParticleEffect
local EffectData = EffectData
local ang_ = Angle(90)

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal()
	local ang = normal:Angle()
	local mat = gred.Mats[util.GetSurfacePropName(data:GetSurfaceProp())]
	if gred.MatsStr[mat] then
		ParticleEffect("ins_impact_"..gred.MatsStr[mat],pos,ang + ang_,nil)
	end
	
	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	effectdata:SetNormal(normal)
	util.Effect("ManhackSparks",effectdata)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()

end