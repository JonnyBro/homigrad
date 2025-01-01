function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ang = data:GetAngles()
	local ent = data:GetEntity()
	if gred.CVars["gred_cl_altmuzzleeffect"]:GetBool() then
		ParticleEffect("muzzleflash_sparks_variant_6",pos,ang,nil)
		ParticleEffect("muzzleflash_1p_glow",pos,ang,nil)
		ParticleEffect("muzzleflash_m590_1p_core",pos,ang,nil)
		ParticleEffect("muzzleflash_smoke_small_variant_1",pos,ang,nil)
	else
		local effectdata=EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetAngles(ang)
		effectdata:SetEntity(ent)
		effectdata:SetScale(1)
		util.Effect("MuzzleEffect", effectdata)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end