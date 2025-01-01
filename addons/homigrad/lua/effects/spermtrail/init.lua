

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	self.Pos = data:GetOrigin()
	local emitter = ParticleEmitter( self.Pos, false )
	
	for i=1,math.random(3,6) do
		
		local particle = emitter:Add("effects/blood_core", self.Pos + (VectorRand()*math.random(-3,3)))

		particle:SetVelocity(Vector(0,0,-1))
		particle:SetDieTime( math.Rand(.6,.8) )
		particle:SetStartAlpha( math.Rand( 120, 170 ) )
		particle:SetEndAlpha(1)
		particle:SetStartSize( math.Rand( 3, 6 ) )
		particle:SetEndSize( math.Rand( 1, 3 ) )
		particle:SetRoll( math.Rand( -95, 95 ) )
		particle:SetRollDelta( math.Rand( -0.12, 0.12 ) )
		local randy = math.random(230,250)
		particle:SetColor( randy,randy,randy )
	end
	
	emitter:Finish()
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	return false
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	// Do nothing - this effect is only used to spawn the particles in Init
	
end



