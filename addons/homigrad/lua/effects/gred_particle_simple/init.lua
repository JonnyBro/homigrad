function EFFECT:Init(data)

	local particle = gred.Particles[data:GetFlags()]
	local pos = data:GetOrigin()
	local ang = data:GetAngles()
	local ShouldSpawnSmoke = data:GetSurfaceProp() == 1
	ParticleEffect(particle,pos,ang,nil)
	if ShouldSpawnSmoke then
		ParticleEffect("doi_ceilingDust_large",pos-Vector(0,0,100),Angle(0,0,0),nil)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()

end