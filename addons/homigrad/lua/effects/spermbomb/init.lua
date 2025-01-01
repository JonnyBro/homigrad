

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local pos = data:GetOrigin()
	
	local emitter = ParticleEmitter( pos, false )
	
	for i=1,math.random(20,25) do
		
		local particle = emitter:Add( "effects/blood_core", pos )

		particle:SetVelocity( VectorRand() * 300 )
		particle:SetDieTime( math.Rand(.7,1.4) )
		particle:SetStartAlpha( math.Rand( 125, 130 ) )
		particle:SetEndAlpha( math.Rand( 1, 2 ) )
		particle:SetStartSize( math.Rand( 105, 115 ) )
		particle:SetEndSize( 1 )
		particle:SetRoll( math.Rand( -95, 95 ) )
		particle:SetRollDelta( math.Rand( -0.12, 0.12 ) )
		particle:SetColor( 255,255,255 )

	end
	
	for i=0,math.random(8,12) do
	
		local emitter = ParticleEmitter(pos)
		local particle = emitter:Add("effects/blooddrop", pos )
		particle:SetVelocity( Vector(math.random(-230,230),math.random(-230,230),math.random(100,300)) )
		particle:SetDieTime(math.random(35,45)/10)
		particle:SetStartAlpha(math.random(140,220))
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.random(2,3))
		particle:SetEndSize(0)
		particle:SetRoll(math.random(-200,200))
		particle:SetRollDelta( math.random( -1, 1 ) )
		particle:SetColor( 255,255,255 )
		particle:SetGravity(Vector(0,0,-520)) //-600 is normal
		particle:SetCollide(true)
		particle:SetBounce(0.55) 
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



