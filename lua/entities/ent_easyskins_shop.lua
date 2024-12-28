AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true

ENT.Spawnable = false
ENT.AdminSpawnable	= false

ENT.Class = "ent_easyskins_shop"
ENT.SpawnName = "Skin Shop"
ENT.Category = "Easy Skins"
ENT.Model = "models/vortigaunt_slave.mdl"
ENT.Text = "Skin Shop"

/* for manual spawning
list.Set( "NPC", ENT.Class, {
	Name = ENT.SpawnName,
	Class = ENT.Class,
	Category = ENT.Category
} )
*/

if SERVER then 
	
	function ENT:Initialize()
	
		self:SetHullSizeNormal( )
		
		self:PhysicsInit(SOLID_BBOX)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_BBOX)
		
		self:CapabilitiesAdd( bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD, CAP_DUCK) )
		self:SetNPCState( NPC_STATE_IDLE )
		self:SetUseType( SIMPLE_USE )
		
		self:DropToFloor()
	
		self:SetMaxYawSpeed( 90 )
		
		self.nextThink = 10
		
		-- respawn shop if it gets removed by any means
		self:CallOnRemove( "RespawnEnt", function( ent )
		
			if !self.ForceRemove then
				
				local npc = {
					class = self:GetClass(),
					pos = self:GetPos(),
					angles = self:GetAngles(),
					model = self:GetModel()
				}
			
				timer.Simple(1, function()
				
					local shopNpc = ents.Create( npc.class )
					
					if IsValid(shopNpc) then
					
						shopNpc:SetPos(npc.pos)
						shopNpc:SetAngles(npc.angles)
						shopNpc:SetModel(npc.model)
						shopNpc:Spawn()
					
					end
				
				end)
				
			end
			
		end)
		
	end

	function ENT:Think()
		
		-- reset the angle every 10 sec interval
		if self.nextThink < CurTime() and self._angles ~= nil then
			self:SetAngles(self._angles)
			self.nextThink = CurTime() + 10
		end
		
	end
	
	function ENT:OnTakeDamage( dmgInfo )
		
		local attacker = dmgInfo:GetAttacker()
		if attacker:IsNPC() then
			attacker:TakeDamageInfo( dmgInfo ) -- let the npcs kill themselves :)
		end
		
		-- we don't want our model spammed with decals from people shooting it
		timer.Simple(0,function()
			if IsValid(self) then
				self:RemoveAllDecals()
				self:Extinguish()
			end
		end)
		
		return 0
		
	end
	
	function ENT:Use( activator, caller )
		activator:SendLua( "CL_EASYSKINS.ToggleMenu(false,true)" )
	end
	
end

if CLIENT then

	local font = CL_EASYSKINS.GetFont()

	surface.CreateFont( "easy_skins_font_shop", {
		font = font,
		size = 100,
		blursize = 1
	} )
	
	function ENT:Draw()
	
		self:DrawModel()
		
		-- calc first time to save performance
		if self.targetPos == nil then
		
			-- we only want the height
			local obbMaxsHeight = Vector(0,0,self:OBBMaxs().z)
			self.targetPos = self:GetPos() + obbMaxsHeight + (self:GetForward() * 1.2) + (self:GetUp() * 10)
			
			self.targetAngle = self:GetAngles()
			local targetAngleRotation = Vector(90, 90, 180)
			
			self.targetAngle:RotateAroundAxis(self.targetAngle:Right(), targetAngleRotation.x)
			self.targetAngle:RotateAroundAxis(self.targetAngle:Up(), targetAngleRotation.y)
			self.targetAngle:RotateAroundAxis(self.targetAngle:Forward(), targetAngleRotation.z)
			
		end
	
		cam.Start3D2D(self.targetPos, self.targetAngle, 0.07 )
		
			local calcW = ( self.textW || 0 ) + 40
		
			-- background
			surface.SetDrawColor(0,0,0,220)
			surface.DrawRect(-(calcW/2),-60, calcW, 120 )
			
			-- text
			self.textW = draw.SimpleText(self.Text, "easy_skins_font_shop", 0,0, color_white, 1, 1)
			
		cam.End3D2D()
	
	end
end