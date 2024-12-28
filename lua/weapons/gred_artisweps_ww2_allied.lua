AddCSLuaFile()

SWEP.Base 						= "gred_artisweps_base"

SWEP.Spawnable					= true
SWEP.AdminSpawnable				= true

SWEP.Category					= "Gredwitch's SWEPs"
SWEP.Author						= "Gredwitch"
SWEP.PrintName					= "[AS]WW2 Allied Binoculars"

function SWEP:InitChoices()
	self.Choices = {
		{
			name = "Artillery Strike",
			sound = "VO_WW2_ALLIED_ARTILLERY_HE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"ARTILLERY","ARTILLERY",math.random(14,16),105,"HE",600,3700)
				end)
			end
		},
		{
			name = "Smoke Artillery Strike",
			sound = "VO_WW2_ALLIED_ARTILLERY_SMOKE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"ARTILLERY","ARTILLERY",math.random(14,16),105,"Smoke",600)
				end)
			end
		},
		{
			name = "Mortar Strike",
			sound = "VO_WW2_ALLIED_ARTILLERY_HE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"MORTAR","MORTAR",math.random(10,12),81,"HE",600,400)
				end)
			end
		},
		{
			name = "Smoke Mortar Strike",
			sound = "VO_WW2_ALLIED_ARTILLERY_SMOKE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"MORTAR","MORTAR",math.random(10,12),81,"Smoke",600)
				end)
			end
		},
		{
			name = "White Phosphorus Artillery Strike",
			sound = "VO_WW2_ALLIED_ARTILLERY_WP",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"ARTILLERY","ARTILLERY",math.random(14,16),105,"WP",600)
				end)
			end
		},
		{
			name = "White Phosphorus Mortar Strike",
			sound = "VO_WW2_ALLIED_ARTILLERY_WP",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"MORTAR","MORTAR",math.random(10,12),81,"WP",600)
				end)
			end
		},
		{
			name = "B-17 Bombing Run",
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
						timer.Simple(10,function()
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,"artillery/flyby/bomber_carpetbomb_flyover.ogg","models/gredwitch/static/b17.mdl","gb_bomb_250gp",12,9,0)
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
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,snd,"models/gredwitch/static/b17.mdl","gb_bomb_250gp",12,9,0)
							
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
							
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,snd,"models/gredwitch/static/b17.mdl","gb_bomb_250gp",12,9,0)
							
							EyeTrace = table.Copy(OldEyeTrace)
							tr = table.Copy(OldTr)
							EyeTrace.HitPos = EyeTrace.HitPos + dir2
							EyeTrace.StartPos = EyeTrace.StartPos + dir2
							tr.HitPos = tr.HitPos + dir2
							
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,snd,"models/gredwitch/static/b17.mdl","gb_bomb_250gp",12,9,0)
							
							
							EyeTrace = table.Copy(OldEyeTrace)
							tr = table.Copy(OldTr)
							EyeTrace.HitPos = EyeTrace.HitPos + dir3
							EyeTrace.StartPos = EyeTrace.StartPos + dir3
							tr.HitPos = tr.HitPos + dir3
							
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,snd,"models/gredwitch/static/b17.mdl","gb_bomb_250gp",12,9,0)
						end)
					end
				},--[[
				{
					name = "Multiple Formations",
					sound = "VO_WW2_ALLIED_BOMBER",
					func = function(ply,tr,EyeTrace)
						timer.Simple(0,function()
							local ang = (EyeTrace.StartPos - EyeTrace.HitPos):Angle()
							ang.p = 0
							ang.r = 0
							local OldEyeTrace,OldTr = table.Copy(EyeTrace),table.Copy(tr)
							
							-- gred.STRIKE.BOMBER(ply,tr,EyeTrace,"artillery/flyby/bomber_carpetbomb_flyover.ogg","models/gredwitch/static/b17.mdl","gb_bomb_250gp",12,9,0)
							
							local function CopyVector(vec)
								return Vector(vec.x,vec.y,vec.z)
							end
							DIRECTIONS = {}
							
							local fwd = ang:Forward()
							local rgt = ang:Right()*500
							local dir = {Vector(0,0,0),CopyVector(fwd),CopyVector(fwd),CopyVector(fwd)}
							local MUL = 400
							dir[1]:Mul(1)
							dir[2]:Mul(-MUL)
							dir[3]:Mul(MUL)
							dir[4]:Mul(MUL*2)
							dir[1]:Add(rgt*1)
							dir[2]:Add(rgt*2)
							dir[3]:Add(rgt*2)
							dir[4]:Add(rgt*3)
							
							table.insert(DIRECTIONS,dir)
							
							local fwd = ang:Forward()
							local rgt = ang:Right()*500
							local dir = {Vector(0,0,0),CopyVector(fwd),CopyVector(fwd),CopyVector(fwd)}
							local MUL = 1300
							local MUL1 = 4
							dir[1]:Mul(MUL)
							dir[2]:Mul(-MUL)
							dir[3]:Mul(MUL)
							dir[4]:Mul(MUL*(2*MUL1))
							dir[1]:Add(rgt*(1*MUL1))
							dir[2]:Add(rgt*(2*MUL1))
							dir[3]:Add(rgt*(2*MUL1))
							dir[4]:Add(rgt*(3*MUL1))
							
							table.insert(DIRECTIONS,dir)
							
							for K,V in pairs(DIRECTIONS) do
								for k,v in pairs(V) do
									EyeTrace = table.Copy(OldEyeTrace)
									tr = table.Copy(OldTr)
									EyeTrace.HitPos = EyeTrace.HitPos + v
									EyeTrace.StartPos = EyeTrace.StartPos + v
									tr.HitPos = tr.HitPos + v
									
									gred.STRIKE.BOMBER(ply,tr,EyeTrace,k == 1 and "artillery/flyby/bomber_carpetbomb_flyover.ogg" or nil,"models/gredwitch/static/b17.mdl","gb_bomb_250gp",12,9,0)
								end
							end
						end)
					end
				},]]
			},
		},
		{
			name = "More...",
			choices = {
				{
					name = "Previous Menu",
					less = true
				},
				{
					name = "Gas Artillery Strike",
					sound = "VO_WW2_ALLIED_ARTILLERY_GAS",
					func = function(ply,tr)
						timer.Simple(10,function()
							gred.STRIKE.ARTILLERY(ply,tr,"ARTILLERY","ARTILLERY",math.random(10,12),105,"Gas",600)
						end)
					end
				},
				{
					name = "P-47D Strafing Run",
					sound = "VO_WW2_ALLIED_GUNRUN",
					func = function(ply,tr,EyeTrace)
						timer.Simple(5,function()
							gred.STRIKE.GUNRUN(ply,tr,EyeTrace,"wac_base_12mm",0.01,1.3,"red",8,0.7,60,120,"artillery/flyby/p47d_flyby.ogg","models/gredwitch/static/p47.mdl",0,2,true,"artillery/flyby/p47d_guns.wav")
							if math.random(1,10) <= 8 then
								timer.Simple(1.4,function()
									gred.STRIKE.GUNRUN(ply,tr,EyeTrace,"wac_base_12mm",0.01,1.3,"red",8,0.7,60,120,"artillery/flyby/p47d_flyby.ogg","models/gredwitch/static/p47.mdl",0,2,true,"artillery/flyby/p47d_guns.wav")
								end)
							end
						end)
					end
				},
				{
					name = "Typhoon Rocket Run",
					sound = "VO_WW2_ALLIED_TYPHOON",
					func = function(ply,tr,EyeTrace)
						timer.Simple(5,function()
							gred.STRIKE.TYPHOON(ply,tr,EyeTrace,"gb_rocket_rp3",0.7,8,60,"artillery/flyby/typhoon_flyby.ogg","models/gredwitch/static/typhoon.mdl",0,2,true)
						end)
					end
				},
			},
		},
	}
end