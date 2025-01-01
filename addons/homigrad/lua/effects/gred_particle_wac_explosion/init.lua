local ParticleEffect = ParticleEffect

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ang = data:GetAngles()
	local count = data:GetFlags()
	local water = data:GetSurfaceProp()
	
	if water == 2 then
		local particle = "ins_water_explosion"
		if count == 1 then
			ParticleEffect(particle,pos,ang,nil)
		elseif count == 2 then
			ParticleEffect(particle,pos+Vector(math.random(500,250),math.random(500,250)),ang,nil)
			ParticleEffect(particle,pos+Vector(math.random(500,250),math.random(-500,-250)),ang,nil)
			ParticleEffect(particle,pos+Vector(math.random(-500,-250),math.random(500,250)),ang,nil)
			ParticleEffect(particle,pos+Vector(math.random(-500,-250),math.random(-500,-250)),ang,nil)
		end
	else
		local particle = "doi_petrol_explosion"
		if count == 1 then
			ParticleEffect(particle,pos,ang,nil)
		elseif count == 5 then
			ParticleEffect(particle,pos,ang,nil)
			
			ParticleEffect(particle,pos,ang+Angle(0,45,45),nil)
			ParticleEffect(particle,pos,ang+Angle(0,-45,-45),nil)
			ParticleEffect(particle,pos,ang+Angle(45,0,0),nil)
			ParticleEffect(particle,pos,ang+Angle(-45,0,0),nil)
		elseif count == 9 then
			ParticleEffect(particle,pos,ang,nil)
			
			ParticleEffect(particle,pos,ang+Angle(0,45,45),nil)
			ParticleEffect(particle,pos,ang+Angle(0,-45,-45),nil)
			ParticleEffect(particle,pos,ang+Angle(45,0,0),nil)
			ParticleEffect(particle,pos,ang+Angle(-45,0,0),nil)
			
			ParticleEffect(particle,pos+Vector(math.random(-400,-250),math.random(-400,-250)),ang,nil)
			ParticleEffect(particle,pos+Vector(math.random(-400,250),math.random(-400,250)),ang+Angle(0,45,45),nil)
			ParticleEffect(particle,pos+Vector(math.random(400,-250),math.random(400,-250)),ang+Angle(0,-45,-45),nil)
			ParticleEffect(particle,pos+Vector(math.random(400,250),math.random(400,250)),ang+Angle(45,0,0),nil)
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end