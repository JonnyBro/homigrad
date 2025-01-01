-- modified m9k effect,https://raw.githubusercontent.com/xxprobaker/M9K-Wepons/master/m9k%20specialties/lua/effects/m9k_cinematic_blood_cloud/init.lua

function EFFECT:Init(data)
	local Entity 				= data:GetEntity()
	local Pos 					= data:GetOrigin()
	local Scale 				= data:GetScale()
	local Radius 				= data:GetRadius() or 1
	local DirVec 				= data:GetNormal()
	local PenVec 				= data:GetStart()
	local Particles 			= data:GetMagnitude()
	local Angle 				= DirVec:Angle()
	local DebrizzlemyNizzle 	= 10 + data:GetScale()
	local Size 					= 5 * Scale
	
	local Emitter 				= ParticleEmitter(Pos)

	sound.Play("physics/flesh/flesh_squishy_impact_hard".. math.random(1,4)..".wav",Pos,180,100)

	Mat = math.ceil(Radius)
	for i = 0,30*Scale do
		local Smoke  =  Emitter:Add("particle/particle_composite",Pos)
		if (Smoke) then
			Smoke:SetVelocity(VectorRand():GetNormalized()*math.random(100,600)*Scale)
			Smoke:SetDieTime(math.Rand(1,2))
			Smoke:SetStartAlpha(80)
			Smoke:SetEndAlpha(0)
			Smoke:SetStartSize(30*Scale)
			Smoke:SetEndSize(100*Scale)
			Smoke:SetRoll(math.Rand(150,360))
			Smoke:SetRollDelta(math.Rand(-2,2))			
			Smoke:SetAirResistance(400) 			 
			Smoke:SetGravity(Vector(math.Rand(-50,50) * Scale,math.Rand(-50,50) * Scale,math.Rand(0,-200))) 			
			Smoke:SetColor(70,35,35)
		end
	end

	for i = 0,20*Scale do
		local Smoke  =  Emitter:Add("particle/smokesprites_000"..math.random(1,9),Pos)
		if (Smoke) then
			Smoke:SetVelocity(VectorRand():GetNormalized()*math.random(200,600)*Scale)
			Smoke:SetDieTime(math.Rand(1,4))
			Smoke:SetStartAlpha(120)
			Smoke:SetEndAlpha(0)
			Smoke:SetStartSize(30*Scale)
			Smoke:SetEndSize(100*Scale)
			Smoke:SetRoll(math.Rand(150,360))
			Smoke:SetRollDelta(math.Rand(-2,2))			
			Smoke:SetAirResistance(400) 			 
			Smoke:SetGravity(Vector(math.Rand(-50,50) * Scale,math.Rand(-50,50) * Scale,math.Rand(-50,-300))) 			
			Smoke:SetColor(70,35,35)
		end
	end

	for i = 1,5 do
		local Flash  =  Emitter:Add("effects/muzzleflash"..math.random(1,4),Pos)
		if (Flash) then
			Flash:SetVelocity(DirVec*100)
			Flash:SetAirResistance(200)
			Flash:SetDieTime(0.15)
			Flash:SetStartAlpha(255)
			Flash:SetEndAlpha(0)
			Flash:SetStartSize(Scale*300)
			Flash:SetEndSize(0)
			Flash:SetRoll(math.Rand(180,480))
			Flash:SetRollDelta(math.Rand(-1,1))
			Flash:SetColor(255,255,255)	
		end
	end

	for i = 1,20*Scale do
		local Debris  =  Emitter:Add("effects/fleck_cement"..math.random(1,2),Pos-(DirVec*5))
		if (Debris) then
			Debris:SetVelocity (VectorRand():GetNormalized() * 400*Scale)
			Debris:SetDieTime(math.random(0.3,0.6))
			Debris:SetStartAlpha(255)
			Debris:SetEndAlpha(0)
			Debris:SetStartSize(8)
			Debris:SetEndSize(9)
			Debris:SetRoll(math.Rand(0,360))
			Debris:SetRollDelta(math.Rand(-5,5))			
			Debris:SetAirResistance(30) 			 			
			Debris:SetColor(70,35,35)
			Debris:SetGravity(Vector(0,0,-600)) 
			Debris:SetCollide(true)
			Debris:SetBounce(0.2)			
		end
	end
end

function EFFECT:Think()
	return false
end


function EFFECT:Render()
	
end