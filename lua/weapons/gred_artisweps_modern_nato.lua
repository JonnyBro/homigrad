AddCSLuaFile()

SWEP.Base 						= "gred_artisweps_base"

SWEP.Spawnable					= true
SWEP.AdminSpawnable				= true

SWEP.Category					= "Gredwitch's SWEPs"
SWEP.Author						= "Gredwitch"
SWEP.PrintName					= "[AS]NATO Binoculars"

function SWEP:InitChoices()
	self.Choices = {
		{
			name = "Single 155mm shot",
			sound = "VO_WW2_ALLIED_ARTILLERY_HE",
			func = function(ply,tr)
				timer.Simple(5,function()
					gred.STRIKE.ARTILLERY(ply,tr,"ARTILLERY","BIGARTILLERY",1,155,"HE",10,15000)
				end)
			end
		},
		{
			name = "155mm Artillery Barage",
			sound = "VO_WW2_ALLIED_ARTILLERY_HE",
			func = function(ply,tr)
				timer.Simple(5,function()
					gred.STRIKE.ARTILLERY(ply,tr,"ARTILLERY","BIGARTILLERY",math.random(24,30),155,"HE",1200,15000)
				end)
			end
		},
		{
			name = "120mm Mortar Strike",
			sound = "VO_WW2_ALLIED_ARTILLERY_HE",
			func = function(ply,tr)
				timer.Simple(5,function()
					gred.STRIKE.ARTILLERY(ply,tr,"MORTAR","MORTAR",math.random(18,24),120,"HE",900,1400)
				end)
			end
		},
		{
			name = "120mm Smoke Mortar Strike",
			sound = "VO_WW2_ALLIED_ARTILLERY_SMOKE",
			func = function(ply,tr)
				timer.Simple(5,function()
					gred.STRIKE.ARTILLERY(ply,tr,"MORTAR","MORTAR",math.random(12,16),120,"Smoke",900)
				end)
			end
		},
		{
			name = "F-4E Phantom Napalm Bombing Run",
			choices = {
				{
					name = "Plane count",
					Decor = true,
				},
				{
					name = "Previous Menu",
					less = true
				},
				{
					name = "Single plane",
					sound = "VO_WW2_ALLIED_BOMBER",
					func = function(ply,tr,EyeTrace)
						timer.Simple(5,function()
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,"artillery/flyby/f4_napalm.ogg","models/gredwitch/static/f4.mdl","gb_bomb_mk77",2,13,11,1,true)
						end)
					end
				},
				{
					name = "Formation",
					sound = "VO_WW2_ALLIED_BOMBER",
					func = function(ply,tr,EyeTrace)
						timer.Simple(10,function()
							local ang = (EyeTrace.StartPos - EyeTrace.HitPos):Angle()
							ang.p = 0
							ang.r = 0
							local OldEyeTrace,OldTr = table.Copy(EyeTrace),table.Copy(tr)
							local snd = "artillery/flyby/bomber_carpetbomb_flyover.ogg"
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,"artillery/flyby/f4_napalm.ogg","models/gredwitch/static/f4.mdl","gb_bomb_mk77",2,13,11,1,true)
							
							local function CopyVector(vec)
								return Vector(vec.x,vec.y,vec.z)
							end
							local fwd = ang:Forward()
							local rgt = ang:Right()*500
							local dir1,dir2,dir3 = CopyVector(fwd),CopyVector(fwd),CopyVector(fwd)
							dir1:Mul(-400)
							dir2:Mul(400)
							dir3:Mul(800)
							dir1:Add(rgt)
							dir2:Add(rgt)
							dir3:Add(rgt*2)
							
							EyeTrace = table.Copy(OldEyeTrace)
							tr = table.Copy(OldTr)
							EyeTrace.HitPos = EyeTrace.HitPos + dir1
							EyeTrace.StartPos = EyeTrace.StartPos + dir1
							tr.HitPos = tr.HitPos + dir1
							
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,"artillery/flyby/f4_napalm.ogg","models/gredwitch/static/f4.mdl","gb_bomb_mk77",2,13,11,1,true)
							
							EyeTrace = table.Copy(OldEyeTrace)
							tr = table.Copy(OldTr)
							EyeTrace.HitPos = EyeTrace.HitPos + dir2
							EyeTrace.StartPos = EyeTrace.StartPos + dir2
							tr.HitPos = tr.HitPos + dir2
							
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,"artillery/flyby/f4_napalm.ogg","models/gredwitch/static/f4.mdl","gb_bomb_mk77",2,13,11,1,true)
							
							
							EyeTrace = table.Copy(OldEyeTrace)
							tr = table.Copy(OldTr)
							EyeTrace.HitPos = EyeTrace.HitPos + dir3
							EyeTrace.StartPos = EyeTrace.StartPos + dir3
							tr.HitPos = tr.HitPos + dir3
							
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,"artillery/flyby/f4_napalm.ogg","models/gredwitch/static/f4.mdl","gb_bomb_mk77",2,13,11,1,true)
						end)
					end
				},
			}
		},
		{
			name = "A-10 Strafing Run",
			sound = "VO_WW2_ALLIED_GUNRUN",
			func = function(ply,tr,EyeTrace)
				timer.Simple(5,function()
					tr.HitPos.z = tr.HitPos.z + 400
					gred.STRIKE.GUNRUN(ply,tr,EyeTrace,"wac_base_30mm",0.0154,1,"red",1,40,80,nil,"artillery/flyby/a10_strafingrun_0"..math.random(1,6	)..".ogg","models/gredwitch/static/a10.mdl",0,4,true,nil)
				end)
			end
		},
		{
			name = "Littlebird AH-6 Strafing Run",
			sound = "VO_WW2_ALLIED_GUNRUN",
			func = function(ply,tr,EyeTrace)
				timer.Simple(5,function()
					gred.STRIKE.GUNRUN(ply,tr,EyeTrace,"wac_base_7mm",0.005,1.5,"red",2,0.3,30,nil,"artillery/flyby/ah6_flyby.wav","models/gredwitch/static/littlebird.mdl",0,5,true,"artillery/flyby/ah6_guns.wav")
				end)
			end
		},
		{	name = "More...",
			choices = {
				{
					name = "Previous Menu",
					less = true
				},
				{
					name = "OH-58 Kiowa Strafing Run",
					sound = "VO_WW2_ALLIED_GUNRUN",
					func = function(ply,tr,EyeTrace)
						timer.Simple(5,function()
							gred.STRIKE.GUNRUN(ply,tr,EyeTrace,"wac_base_7mm",0.01,1.5,"red",1,0.3,30,nil,"artillery/flyby/ah6_flyby.wav","models/gredwitch/static/kiowa.mdl",0,5,true,"artillery/flyby/ah6_guns.wav")
							gred.STRIKE.TYPHOON(ply,tr,EyeTrace,"gb_rocket_hydra",0.7,14,30,nil,nil,0,5,true)
						end)
					end
				},
			}
		},
	}
end