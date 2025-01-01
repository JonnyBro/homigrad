function EFFECT:Init(data)
	local ent = data:GetEntity()
	if !IsValid(ent) then return end
	
	canExtractShell = ent.EmplacementType == "MG" and GetConVar("gred_cl_shelleject"):GetInt() == 1 and table.Count(ent.TurretEjects) > 0
	
	if ent.Sequential then
		local v = ent:GetMuzzle()
		
		attPos = ent.CustomShootPos and ent:LocalToWorld(ent.CustomShootPos[v]) or ent:LocalToWorld(ent.TurretMuzzles[v].Pos)
		attAng = ent.CustomShootAng and ent:LocalToWorldAngles(ent.CustomShootAng[v]) or ent:LocalToWorldAngles(ent.TurretMuzzles[v].Ang)
		
		if GetConVar("gred_cl_altmuzzleeffect"):GetInt() == 1 or 
		(ent.EmplacementType != "MG" and ent.EmplacementType != "Mortar") then
			ParticleEffect(ent.MuzzleEffect,attPos,attAng,nil)
		else
			local effectdata=EffectData()
			effectdata:SetOrigin(attPos)
			effectdata:SetAngles(attAng)
			effectdata:SetEntity(ent)
			effectdata:SetScale(1)
			util.Effect("MuzzleEffect", effectdata)
		end
		if canExtractShell then
			ent:CheckExtractor()
			local effectdata = EffectData()
			local curExtractor = ent:GetCurrentExtractor()
			
			local eject = ent.TurretEjects[ent:GetCurrentExtractor(curExtractor)]
			
			effectdata:SetOrigin(ent:LocalToWorld(eject.Pos))
			effectdata:SetAngles(ent:LocalToWorldAngles(eject.Ang + ent.ExtractAngle))
			
			if ent.AmmunitionType == "wac_base_7mm" then
				util.Effect("ShellEject",effectdata)
			else
				util.Effect("RifleShellEject",effectdata)
			end
			
			ent:SetCurrentExtractor(curExtractor + 1)
		end
	else
		for k,v in pairs(ent.TurretMuzzles) do
			attPos = ent.CustomShootPos and ent:LocalToWorld(ent.CustomShootPos[k]) or ent:LocalToWorld(v.Pos)
			attAng = ent.CustomShootAng and ent:LocalToWorldAngles(ent.CustomShootAng[k]) or ent:LocalToWorldAngles(v.Ang)
			
			if GetConVar("gred_cl_altmuzzleeffect"):GetInt() == 1 or 
			(ent.EmplacementType != "MG" and ent.EmplacementType != "Mortar") then
				ParticleEffect(ent.MuzzleEffect,attPos,attAng,nil)
			else
				local effectdata=EffectData()
				effectdata:SetOrigin(attPos)
				effectdata:SetAngles(attAng)
				effectdata:SetEntity(ent)
				effectdata:SetScale(1)
				util.Effect("MuzzleEffect", effectdata)
			end
		end
		if canExtractShell then
			if ent.EFFECT_CUR_MUZZLE and ent.EFFECT_CUR_MUZZLE >= #ent.TurretEjects or !ent.EFFECT_CUR_MUZZLE then
				for a,b in pairs(ent.TurretEjects) do
					local effectdata = EffectData()
					
					effectdata:SetOrigin(ent:LocalToWorld(b.Pos))
					effectdata:SetAngles(ent:LocalToWorldAngles(b.Ang + ent.ExtractAngle))
					
					if ent.AmmunitionType == "wac_base_7mm" then
						util.Effect("ShellEject",effectdata)
					else
						util.Effect("RifleShellEject",effectdata)
					end
				end
				ent.EFFECT_CUR_MUZZLE = 1
			else
				ent.EFFECT_CUR_MUZZLE = ent.EFFECT_CUR_MUZZLE and ent.EFFECT_CUR_MUZZLE + 1 or 2
			end
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()

end