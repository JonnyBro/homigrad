AddCSLuaFile()

SWEP.Base 						= "gred_artisweps_base"

SWEP.Spawnable					= true
SWEP.AdminSpawnable				= true

SWEP.Category					= "Gredwitch's SWEPs"
SWEP.Author						= "Gredwitch"
SWEP.PrintName					= "[AS]WW2 Axis Binoculars"

function SWEP:InitChoices()
	self.Choices = {
		{
			name = "88mm Flak 37 Strike",
			sound = "VO_WW2_AXIS_ARTILLERY_HE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"ARTILLERY","ARTILLERY",math.random(14,16),88,"HE",600,3000)
				end)
			end
		},
		{
			name = "Smoke 88mm Flak 37 Strike",
			sound = "VO_WW2_AXIS_ARTILLERY_SMOKE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"ARTILLERY","ARTILLERY",math.random(14,16),88,"Smoke",600)
				end)
			end
		},
		{
			name = "Granatwerfer Strike",
			sound = "VO_WW2_AXIS_ARTILLERY_HE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"MORTAR","MORTAR",math.random(10,12),81,"HE",600,400)
				end)
			end
		},
		{
			name = "Smoke Granatwerfer Strike",
			sound = "VO_WW2_AXIS_ARTILLERY_SMOKE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"MORTAR","MORTAR",math.random(10,12),81,"Smoke",600)
				end)
			end
		},
		{
			name = "Nebelwerfer Strike",
			sound = "VO_WW2_AXIS_ARTILLERY_HE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"NEBELWERFER","NEBELWERFER",math.random(24,32),128,"HE",1200,6000)
				end)
			end
		},
		{
			name = "Nebelwerfer Smoke Strike",
			sound = "VO_WW2_AXIS_ARTILLERY_SMOKE",
			func = function(ply,tr)
				timer.Simple(10,function()
					gred.STRIKE.ARTILLERY(ply,tr,"NEBELWERFER","NEBELWERFER",math.random(18,24),128,"Smoke",1200)
				end)
			end
		},
		{
			name = "He 111 Bombing Run",
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
					sound = "VO_WW2_AXIS_BOMBER",
					func = function(ply,tr,EyeTrace)
						timer.Simple(10,function()
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,"artillery/flyby/bomber_carpetbomb_flyover.ogg","models/gredwitch/static/he111.mdl","gb_bomb_sc100",12,9,0)
						end)
					end
				},
				{
					name = "Formation",
					sound = "VO_WW2_AXIS_BOMBER",
					func = function(ply,tr,EyeTrace)
						timer.Simple(10,function()
							local ang = (EyeTrace.StartPos - EyeTrace.HitPos):Angle()
							ang.p = 0
							ang.r = 0
							local OldEyeTrace,OldTr = table.Copy(EyeTrace),table.Copy(tr)
							local snd = "artillery/flyby/bomber_carpetbomb_flyover.ogg"
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,snd,"models/gredwitch/static/he111.mdl","gb_bomb_sc100",12,9,0)
							
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
							
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,snd,"models/gredwitch/static/he111.mdl","gb_bomb_sc100",12,9,0)
							
							EyeTrace = table.Copy(OldEyeTrace)
							tr = table.Copy(OldTr)
							EyeTrace.HitPos = EyeTrace.HitPos + dir2
							EyeTrace.StartPos = EyeTrace.StartPos + dir2
							tr.HitPos = tr.HitPos + dir2
							
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,snd,"models/gredwitch/static/he111.mdl","gb_bomb_sc100",12,9,0)
							
							
							EyeTrace = table.Copy(OldEyeTrace)
							tr = table.Copy(OldTr)
							EyeTrace.HitPos = EyeTrace.HitPos + dir3
							EyeTrace.StartPos = EyeTrace.StartPos + dir3
							tr.HitPos = tr.HitPos + dir3
							
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,snd,"models/gredwitch/static/he111.mdl","gb_bomb_sc100",12,9,0)
						end)
					end
				},--[[
				{
					name = "Multiple Formations",
					sound = "VO_WW2_AXIS_BOMBER",
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
					sound = "VO_WW2_AXIS_ARTILLERY_HE",
					func = function(ply,tr)
						timer.Simple(10,function()
							gred.STRIKE.ARTILLERY(ply,tr,"ARTILLERY","ARTILLERY",math.random(10,12),105,"Gas",600)
						end)
					end
				},
				{
					name = "Stuka Dive Bomb",
					sound = "VO_WW2_AXIS_STUKA",
					func = function(ply,tr,EyeTrace)
						timer.Simple(2,function()
							gred.STRIKE.BOMBER(ply,tr,EyeTrace,"artillery/flyby/stuka_dive_bomb.ogg","models/gredwitch/static/stuka.mdl","gb_bomb_sc250",1,15,8,0.8,true)
						end)
					end
				},
			}
		}
	}
end