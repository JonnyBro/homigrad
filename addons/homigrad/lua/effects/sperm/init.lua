

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local pos = data:GetOrigin()
	local ang = data:GetAngle()
	
	local emitter = ParticleEmitter( pos, false )
	
	for i=1,math.random(6,8) do
		
		local particle = emitter:Add( "effects/blood_core", pos )

		particle:SetVelocity( (ang:Forward() * math.random(200,240)) + (VectorRand() * 12) + Vector(0,0,5) )
		particle:SetDieTime( math.Rand(1,2) )
		particle:SetStartAlpha( math.Rand( 125, 130 ) )
		particle:SetEndAlpha( 1 )
		particle:SetStartSize( math.Rand( 5, 15 ) )
		particle:SetEndSize( math.Rand( 30, 34 ) )
		particle:SetRoll( math.Rand( -95, 95 ) )
		particle:SetRollDelta( math.Rand( -0.12, 0.12 ) )
		particle:SetColor( 255,255,255 )
		
	end

	emitter:Finish()
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	// Die instantly
	return false
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	// Do nothing - this effect is only used to spawn the particles in Init
	
end



