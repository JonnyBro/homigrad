

local BloodSprite = Material( "effects/bloodstream" )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

		// Table to hold particles
		self.Particles = {}
		
		self.PlaybackSpeed 	= math.Rand( 3, 5 )
		self.Width 			= math.Rand( 8, 16 )
		self.ParCount		= 8
		
		local Ang = data:GetAngles()
		local Pos = data:GetOrigin()
		
		local Dir = Ang:Forward() * 0.3
		
		local Speed = math.Rand( 2500, 2800 )
		
		local SquirtDelay = math.Rand( 3, 5 )
		
		Dir.z = math.max( Dir.z, Dir.z * -1 )
		if (Dir.z > 0.5) then
			Dir.z = Dir.z - 0.3
		end
		
		for i=1, math.random( 4, 8 ) do
		
			local p = {}
			
				p.Pos = Pos + Vector(0,0,-1)
				p.Vel = Dir * (Speed * (i /16))
				p.Delay = (16 - i)  * SquirtDelay
				p.Rest = false
			
			table.insert( self.Particles, p )
		
		end

		self.NextThink = CurTime() +  math.Rand( 0, 1 )
	
end


local function VectorMin( v1, v2 )
	
	if ( v1 == nil ) then return v2 end
	if ( v2 == nil ) then return v1 end
	
	local vr = Vector( v2.x, v2.y, v2.z )
	
	if ( v1.x < v2.x ) then vr.x = v1.x end
	if ( v1.y < v2.y ) then vr.y = v1.y end
	if ( v1.z < v2.z ) then vr.z = v1.z end
	
	return vr

end

local function VectorMax( v1, v2 )
	
	if ( v1 == nil ) then return v2 end
	if ( v2 == nil ) then return v1 end
	
	local vr = Vector( v2.x, v2.y, v2.z )
	
	if ( v1.x > v2.x ) then vr.x = v1.x end
	if ( v1.y > v2.y ) then vr.y = v1.y end
	if ( v1.z > v2.z ) then vr.z = v1.z end
	
	return vr

end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	//if ( self.NextThink > CurTime() ) then return true end

	local FrameSpeed = self.PlaybackSpeed * FrameTime()
	
	local bMoved = false
	local min = self.Entity:GetPos()
	local max = min
	
	self.Width = self.Width - 0.7 * FrameSpeed
	if ( self.Width < 0 ) then
		return false
	end
	
	for k, p in pairs( self.Particles ) do
	
			if ( p.Rest ) then
									
			// Waiting to be spawned. Some particles have an initial delay 
			// to give a stream effect..
			elseif ( p.Delay > 0 ) then
			
				p.Delay = p.Delay - 100 * FrameSpeed
			
			// Normal movement code. Handling particles in Lua isn't great for 
			// performance but since this is clientside and only happening sometimes
			// for short periods - it should be fine.
			else
				
				// Gravity
				p.Vel:Sub( Vector( 0, 0, 60 * FrameSpeed ) )
				
				// Air resistance
				p.Vel.x = math.Approach( p.Vel.x, 0, 2 * FrameSpeed )
				p.Vel.y = math.Approach( p.Vel.y, 0, 2 * FrameSpeed )
				
				local trace = {}
				trace.start 	= p.Pos
				trace.endpos 	= p.Pos + p.Vel * FrameSpeed
				trace.mask 		= MASK_NPCWORLDSTATIC
				local tr = util.TraceLine( trace )

				if (tr.Hit) then
								
					tr.HitPos:Add( tr.HitNormal * 2 )
					
					// If we hit the ceiling just stunt the vertical velocity
					// else enter a rested state
					if ( tr.HitNormal.z < -0.75 ) then
					
						p.Vel.z = 0
					
					else
					
						p.Rest = true
					
					end
		
				end
				
				// Add velocity to position
				p.Pos = tr.HitPos
				bMoved = true
			
			end
			
	end
	
	self.ParCount = table.Count( self.Particles )
	
	
	// I really need to make a better/faster way to do this
	if (bMoved) then
	
		for k, p in pairs( self.Particles ) do
		
			min = VectorMin( min, p.Pos )
			max = VectorMax( max, p.Pos )
			
		end

		local Pos = min + ((max - min) * 0.5)
		self.Entity:SetPos( Pos )
		self.Entity:SetCollisionBounds( Pos - min, Pos - max )
	end
	
	
	// Returning false kills the effect
	return (self.ParCount > 0)
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	render.SetMaterial( BloodSprite )
	
	local LastPos = nil
	local pCount = 0
	
	local color = Color( 255, 255, 255, 255 )

	for k, p in pairs( self.Particles ) do
	
		local Sin = math.sin( (pCount / (self.ParCount-2)) * math.pi )
		
		if ( LastPos ) then
		
			render.DrawBeam( LastPos, 		
					 p.Pos,
					 self.Width * Sin,					
					 1,					
					 0,				
					 color )
		
		end
		
		pCount = pCount + 1
		LastPos = p.Pos
	
	end
	
	
	//render.DrawSprite( self.Entity:GetPos(), 32, 32, color_white )
	
end



