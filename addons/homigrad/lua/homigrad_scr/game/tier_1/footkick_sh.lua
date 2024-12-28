HMCD = HMCD or {}

HMCD.CanBrake = {
	["models/props_wasteland/controlroom_storagecloset001a.mdl"] = true,
	["models/props_c17/oildrum001_explosive.mdl"] = true,
	["models/props_c17/oildrum001.mdl"] = true,
	["models/props_junk/trashbin01a.mdl"] = true,
	["models/props_c17/lockers001a.mdl"] = true,
	["models/props_c17/barrel09a.mdl"] = true,
	["models/props_c17/barrel04a.mdl"] = true,
	["models/props_c17/barrel10a.mdl"] = true,
	["models/fire_equipment/w_weldtank2.mdl"] = true,
	["models/fire_equipment/w_weldtank1.mdl"] = true,
	['models/props_c17/canister02a.mdl'] = true,
	["models/props_interiors/furniture_cabinetdrawer02a.mdl"] = true,
	["models/props/cs_office/file_cabinet1.mdl"] = true,
	["models/props_junk/metalbucket02a.mdl"] = true,
}

/*---------------------------------------------------

Credit to LeErOy NeWmAn and WHORSHIPPER for the original code that this is based on.

----------------------------------------------------*/
if SERVER then
	include("kick_animapi/boneanimlib.lua")
end
if CLIENT then	
	include("kick_animapi/cl_boneanimlib.lua") 
    hook.Add("Think", "CheckInZoomButton", function()
        local ply = LocalPlayer()
        if ply:Alive() and ply:KeyPressed(IN_ZOOM) then
            -- Call the kick function on the server
            RunConsoleCommand("kick_nig")
        end
    end)
end

RegisterLuaAnimation('bsmod_kickanim', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Calf'] = {
					RU = -64.555652469149
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -70.441395011994
				}
			},
			FrameRate = 8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Calf'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
				}
			},
			FrameRate = 4
		}
	},
	Type = TYPE_GESTURE
})

local kicktime = 0.7

function CalcPlayerModelsAngle( ply )
    local defans = Angle(-90,0,0)
	if ply:Health() <= 0 then return defans end
	local StartAngle = ply:EyeAngles()
	if !StartAngle then return defans end
	local CalcAngle = Angle( (StartAngle.p) / 1.1 - 20 , StartAngle.y, 0)
	if !CalcAngle then return StartAngle end
	return CalcAngle
end

if CLIENT then
    

	local function Kicking( )
		local ply = LocalPlayer()
		
		if !IsValid(ply) then return end
		
		if !ply:Alive() then return false end
		if !ply.StopKick then
			ply.StopKick = CurTime() + 0.7
		elseif ply.StopKick then
			ply:SetNWBool("Kicking", net.ReadBool())
			ply.KickTime = CurTime()
			ply.StopKick = ply.KickTime + 0.7
			
			if ply.CreateLegs != nil then
				
				local rand = math.random(1, 3)
				
				if rand == 1 then
					ply.CreateLegs:SetSequence(ply.CreateLegs:LookupSequence( "leg_attack" ))
				elseif rand == 2 then
					ply.CreateLegs:SetSequence(ply.CreateLegs:LookupSequence( "leg_attack3" ))
				elseif rand == 3 then
					ply.CreateLegs:SetSequence(ply.CreateLegs:LookupSequence( "leg_attack4" ))
				end
				
				ply.CreateLegs:SetCycle(0)
			end
		end
	end
	net.Receive( "Kicking", Kicking )

	local kickvmoffset = Vector(-10, 0, -12.5)

	local function KickThink()
		for k, v in pairs(player.GetAll()) do

			local Kicking = v:GetNWBool("Kicking", false)
			if GetViewEntity() == v and (!v.ShouldDrawLocalPlayer or !v:ShouldDrawLocalPlayer() ) and Kicking and v.StopKick and v.StopKick > CurTime() then
				local off = Vector(kickvmoffset.x, kickvmoffset.y, kickvmoffset.z)
				off:Rotate(CalcPlayerModelsAngle(v))
				if !IsValid(v.CreateLegs) then
					--print("Creating Main Leg")
					v.CreateLegs = ClientsideModel("models/weapons/c_limbs.mdl", RENDERGROUP_TRANSLUCENT)
					v.CreateLegs:Spawn()
					v.CreateLegs:SetPos(v:GetShootPos() + off)
					v.CreateLegs:SetAngles(CalcPlayerModelsAngle(v))
					v.CreateLegs:SetParent(v)
					v.CreateLegs:SetNoDraw(true)
					v.CreateLegs:DrawModel()
					v.CreateLegs:SetCycle(0)
					
					local rand = math.random(1, 3)
					
					if rand == 1 then
						v.CreateLegs:SetSequence(v.CreateLegs:LookupSequence( "leg_attack" ))
					elseif rand == 2 then
						v.CreateLegs:SetSequence(v.CreateLegs:LookupSequence( "leg_attack3" ))
					elseif rand == 3 then
						v.CreateLegs:SetSequence(v.CreateLegs:LookupSequence( "leg_attack4" ))
					end
					
					v.CreateLegs:SetPlaybackRate( 1 ) 
					v.CreateLegs.LastTick = CurTime()
				else
					--print("Updating Main Leg")
					v.CreateLegs:SetPos(v:GetShootPos() + off)
					v.CreateLegs:SetAngles(CalcPlayerModelsAngle(v))
					v.CreateLegs:FrameAdvance( CurTime() - v.CreateLegs.LastTick )		
					v.CreateLegs.LastTick = CurTime()
				end
				if !IsValid(v.CreatePMLegs)  then
					--print("Creating PM Leg")
					v.CreatePMLegs = ClientsideModel(v:GetModel(), RENDERGROUP_TRANSLUCENT)
					v.CreatePMLegs:Spawn()
					v.CreatePMLegs:SetParent(v.CreateLegs)
					v.CreatePMLegs:SetPos(v:GetShootPos() + off)
					v.CreatePMLegs:SetAngles(CalcPlayerModelsAngle(v))
					v.CreatePMLegs:SetSkin(LocalPlayer():GetSkin())
					v.CreatePMLegs:SetColor(LocalPlayer():GetColor())
					v.CreatePMLegs:SetMaterial(LocalPlayer():GetMaterial())
					v.CreatePMLegs:SetRenderMode(LocalPlayer():GetRenderMode())
					for _, bodygroup in pairs(LocalPlayer():GetBodyGroups()) do
						v.CreatePMLegs:SetBodygroup(bodygroup.id, LocalPlayer():GetBodygroup(bodygroup.id))
					end
					v.CreatePMLegs:DrawShadow(false)
					v.CreatePMLegs.GetPlayerColor = function() return Vector( LocalPlayer():GetPlayerColor().r, LocalPlayer():GetPlayerColor().g, LocalPlayer():GetPlayerColor().b ) end
					v.CreatePMLegs:SetNoDraw(false)
					v.CreatePMLegs:AddEffects(EF_BONEMERGE)
					v.CreatePMLegs:DrawModel()
					v.CreatePMLegs:SetPlaybackRate( 1 ) 
					v.CreatePMLegs.LastTick = CurTime()
				else
					--print("Updating PM Leg")
					v.CreatePMLegs:SetPos(v:GetShootPos() + off)
					v.CreatePMLegs:SetAngles(CalcPlayerModelsAngle(v))
					v.CreatePMLegs:FrameAdvance( CurTime() - v.CreateLegs.LastTick )
					v.CreatePMLegs:DrawModel()			
					v.CreatePMLegs.LastTick = CurTime()
				end
			else	
				if v.CreateLegs then
					if IsValid(v.CreateLegs) then
						v.CreateLegs.SetNoDraw(v.CreateLegs, true)
						v.CreateLegs.SetPos(v.CreateLegs, Vector(0, 0, 0))
						v.CreateLegs.SetAngles(v.CreateLegs, Angle(0,0,0))
						v.CreateLegs.SetRenderOrigin(v.CreateLegs, Vector(0, 0, 0))
						v.CreateLegs.SetRenderAngles(v.CreateLegs, Angle(0,0,0))
					end
					
					local tmpcreatelegs = v.CreateLegs
					timer.Simple(0.1,function()
						if tmpcreatelegs then
							SafeRemoveEntity(tmpcreatelegs)
						end
					end)
					
					v.CreateLegs = nil
					
				end
				
				if v.CreatePMLegs then
					--print("Removing Created PM Leg")
					if IsValid(v.CreatePMLegs) then
						v.CreatePMLegs.SetNoDraw(v.CreatePMLegs,true)
						v.CreatePMLegs.SetPos(v.CreatePMLegs,Vector(0, 0, 0))
						v.CreatePMLegs.SetAngles(v.CreatePMLegs,Angle(0, 0, 0))
						v.CreatePMLegs.SetRenderOrigin(v.CreatePMLegs,Vector(0, 0, 0))
						v.CreatePMLegs.SetRenderAngles(v.CreatePMLegs,Angle(0, 0, 0))
					end
					
					local tmpcreatelegs = v.CreatePMLegs
					timer.Simple(0.1,function()
						if tmpcreatelegs then
							SafeRemoveEntity(tmpcreatelegs)
						end
					end)
					
					v.CreatePMLegs = nil
				end
				
				v.Kicking = false
			end
		end
	end
	hook.Remove("Think", "KickThink", KickThink)

end

function GGetSound(mdl)
	return 'vo/npc/male01/pain0'..math.random(1,6)..'.wav'
end

function KickHit(ply)
	local Vec = ply:GetAimVector()
    local trace = util.QuickTrace(ply:GetAttachment(ply:LookupAttachment("eyes")).Pos, Vec * 100, {ply})
	if trace == nil then return end
    local phys = trace.Entity ~= NULL and trace.Entity:GetPhysicsObject() or nil
	if phys == nil then return end
	
    local damage = math.random(5,15)
	
	if true then
	    damage = damage + math.Clamp(ply:GetVelocity():Length() / 2, 0, ply:GetVelocity():Length())
	end
	
	if ply:GetNWBool("Extention_Strength") then
	    damage = damage * 1.2
	end

    if SERVER then
    if true then -- If we're in range
	    if true then
		    local shake = ents.Create( "env_shake" )
		    shake:SetOwner(ply)
		    shake:SetPos( trace.HitPos )
		    shake:SetKeyValue( "amplitude", "2500" )
		    shake:SetKeyValue( "radius", "100" )
		    shake:SetKeyValue( "duration", "0.5" )
		    shake:SetKeyValue( "frequency", "255" )
		    shake:SetKeyValue( "spawnflags", "4" )	
		    shake:Spawn()
		    shake:Activate()
		    shake:Fire( "StartShake", "", 0 )
		end	
        if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then	
	        if string.find(trace.Entity:GetClass(),"npc") and trace.Entity:Health() <= damage then
	            phys:ApplyForceOffset(ply:GetAimVector():GetNormalized() * (damage * 2), trace.HitPos)
	            trace.Entity:SetVelocity(ply:GetAimVector():GetNormalized() * (damage * 2))
			elseif string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			    phys:ApplyForceOffset(ply:GetAimVector():GetNormalized() * ((damage * 120 * 2) * 2), trace.HitPos)
	        end
			
			trace.Entity:EmitSound("physics/body/body_medium_impact_hard6.wav", 100, math.random(90, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	        trace.Entity:TakeDamage(damage, ply, ply)
		elseif HMCD and HMCD.CanBrake and HMCD.CanBrake[trace.Entity:GetModel()] ~= nil then
			if math.random(3, 11) == 10 then
				trace.Entity:Fire("break", "", 0)
			end
	    elseif trace.Entity:IsWorld() then
			ply:EmitSound("physics/body/body_medium_impact_hard1.wav", 100, math.random(90, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );	
		elseif trace.Entity:GetClass() == "func_door_rotating" or trace.Entity:GetClass() == "prop_door_rotating" then
		    if trace.Entity:GetClass() == "prop_door_rotating" then
			    -- FakeDoor(trace.Entity, ply, damage)
				if true then
					ply:EmitSound(GGetSound(ply:GetModel()), 50)
				end
				trace.Entity:EmitSound("physics/wood/wood_panel_impact_hard1.wav", 100, math.random(90, 110))
	            ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
			else	
				ply.oldname = ply:GetName()
				ply:SetName( "bashingpl" .. ply:EntIndex() )
				trace.Entity:SetKeyValue( "Speed", "500" )
	            trace.Entity:Fire( "open", "bashingpl" .. ply:EntIndex() , .02 )
				timer.Simple(0.3, function()
				    trace.Entity:SetKeyValue( "Speed", "100" )
				end, trace.Entity)
				if true then
					if true then
						ply:EmitSound(GGetSound(ply:GetModel()), 50)
					end
				trace.Entity:EmitSound("physics/wood/wood_panel_impact_hard1.wav", 100, math.random(90, 110))
			else
			if true then
			ply:EmitSound(GGetSound(ply:GetModel()), 50)
			end
			trace.Entity:EmitSound("physics/wood/wood_plank_break1.wav", 100, math.random(90, 110))
			trace.Entity:Fire( "unlock", "", .01 )
		end
	            ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
			end
            if true then		
			    local fx 	= EffectData()
	            fx:SetStart(trace.HitPos)
	            fx:SetOrigin(trace.HitPos)
	            fx:SetNormal(trace.HitNormal)
	            util.Effect("kick_groundhit",fx)
	        end			
		elseif trace.Entity:GetClass() == "prop_dynamic" then	
			if true then
			ply:EmitSound(GGetSound(ply:GetModel()), 50)
			end
			trace.Entity:EmitSound("player/smod_kick/foot_kickwall.wav", 100, math.random(80, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	        trace.Entity:TakeDamage(damage, ply, ply)	
		            if true then		
			    local fx = EffectData()
	            fx:SetStart(trace.HitPos)
	            fx:SetOrigin(trace.HitPos)
	            fx:SetNormal(trace.HitNormal)
	            util.Effect("kick_groundhit",fx)
	        end	
		elseif trace.Entity:IsValid() then	
	        phys:ApplyForceOffset(ply:GetAimVector():GetNormalized() * (damage * 300 * 2), trace.HitPos)
	        trace.Entity:SetVelocity(ply:GetAimVector():GetNormalized() * (damage * 300 * 2))
			if true then
			ply:EmitSound(GGetSound(ply:GetModel()), 50)
			end
			trace.Entity:EmitSound("player/smod_kick/foot_kickwall.wav", 100, math.random(80, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	        trace.Entity:TakeDamage(damage, ply, ply)	
	    end 
	
	else
		if true then
		ply:EmitSound(GGetSound(ply:GetModel()), 50, 100)
		end
	    ply:EmitSound("player/smod_kick/foot_fire.wav", 50, math.random(70, 110))
		ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	end
    end
end
-- thanks worshipper 8D
function FakeDoor(Door, attacker, amount)
	Door:Fire("SetSpeed", 500)
	-- Door:Fire("Open", attacker, 0, attacker)
	Door:EmitSound("physics/wood/wood_furniture_break"..math.random(1,2)..".wav", 100)
	timer.Simple(0.4, function()
		Door:Fire("SetSpeed", 100)
	end)
	
end

if (SERVER) then 
	util.AddNetworkString( "Kicking" )
	
	function BSModKick(ply)
		if !ply:Alive() or ply.fake then return false end
		if ply.StopKick and ply.StopKick < CurTime() then
			ply:SetNWBool("Kicking",true)
			ply.KickTime = CurTime()
			ply.StopKick = ply.KickTime + 1
		    ply:ResetLuaAnimation("bsmod_kickanim")
			net.Start("Kicking")
			net.WriteBool(true)
			net.Send(ply)
			
			ply:ViewPunch(Angle(2.5, 0, 0))
			ply:EmitSound("player/kick/foot_fire.wav", 100)
			
			timer.Remove(ply:SteamID())
			
			timer.Create(ply:SteamID(), 0.01, 1, function()
				KickHit(ply)
			end, ply)
		end
	end

    
	concommand.Add("kick_nig", BSModKick)

    

	local function KickPlayerStart(ply)
		ply.Kicking = false
		ply.KickTime = -1
		ply.StopKick = ply.KickTime + kicktime
	end
	hook.Add("PlayerSpawn","KickPlayerStart",KickPlayerStart)

	local function KickPlayerDeath(ply)
		ply.Kicking = false
		ply.KickTime = -1
		ply.StopKick = ply.KickTime + kicktime
	end
	hook.Add("PlayerDeath","KickPlayerDeath",KickPlayerDeath)
end
