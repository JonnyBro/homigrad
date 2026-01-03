gameevent.Listen("player_spawn")

function RandomFromTable(tbl)
	local key = math.random(#tbl)
	local value = tbl[key]

	return value, key
end

hook.Add("player_spawn", "player_activatehg", function(data)
	local ply = Player(data.userid)

	if not IsValid(ply) then return end
	hook.Run("Player Activate", ply)

	ply.RenderOverride = function(self)
		if vrmod and vrmod.IsPlayerInVR(ply) then self:DrawModel() return end

		local ply = self:IsPlayer() and self or IsValid(self:GetNWEntity("RagdollOwner", NULL)) and self:GetNWEntity("RagdollOwner", NULL)
		local ent = ply and IsValid(ply:GetNWEntity("Ragdoll", NULL)) and ply:GetNWEntity("Ragdoll", NULL) or ply or self

		if ent then
			hook.Run("HG_PostPlayerDraw", ent, ply)

			ent:DrawModel()
		end
	end

	if not PLYSPAWN_OVERRIDE then hook.Run("Player Spawn", ply) end
end)

hook.Add("OnEntityCreated", "RagdollRender", function(ent)
	if ent:GetClass() == "prop_ragdoll" then
		ent.RenderOverride = function(self)
			local ply = self:IsPlayer() and self or IsValid(self:GetNWEntity("RagdollOwner", NULL)) and self:GetNWEntity("RagdollOwner", NULL)
			local ent = ply and IsValid(ply:GetNWEntity("Ragdoll", NULL)) and ply:GetNWEntity("Ragdoll", NULL) or ply or self

			if ent then
				hook.Run("HG_PostPlayerDraw", ent, ply)

				ent:DrawModel()
			end
		end
	end
end)

hook.Add("HomigradRun", "RunShit", function()
	local entitis = player.GetAll()

	table.Add(entitis, ents.FindByClass("prop_ragdoll"))

	for _, ply in ipairs(entitis) do
		ply.RenderOverride = function(self)
			local ply = self:IsPlayer() and self or IsValid(self:GetNWEntity("RagdollOwner", NULL)) and self:GetNWEntity("RagdollOwner", NULL)
			local ent = ply and IsValid(ply:GetNWEntity("Ragdoll", NULL)) and ply:GetNWEntity("Ragdoll", NULL) or ply or self

			if ent then
				hook.Run("HG_PostPlayerDraw", ent, ply)

				ent:DrawModel()
			end
		end
	end
end)

gameevent.Listen("entity_killed")

hook.Add("entity_killed", "player_deathhg", function(data)
	local ply = Entity(data.entindex_killed)
	local attacker = Entity(data.entindex_attacker)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	hook.Run("Player Death", ply, attacker)
end)

local override = {}

net.Receive("hgOverrideSpawn", function() override[net.ReadEntity()] = true end)

hook.Add("Player Spawn", "!Override", function(ply)
	if override[ply] then
		override[ply] = nil

		return false
	end
end)

hook.Add("Player Spawn", "zOverride", function(ply)
	if override[ply] then
		override[ply] = nil

		return false
	end
end)

local hull = 10
local HullMin = -Vector(hull, hull, 0)
local Hull = Vector(hull, hull, 72)
local HullDuck = Vector(hull, hull, 36)

hook.Add("Player Activate", "SetHull", function(ply)
	ply:SetHull(ply:GetNWVector("HullMin", HullMin) or HullMin, ply:GetNWVector("Hull", Hull) or Hull)
	ply:SetHullDuck(ply:GetNWVector("HullMin", HullMin) or HullMin, ply:GetNWVector("HullDuck", HullDuck) or HullDuck)
	ply:SetViewOffset(Vector(0, 0, 64))
	ply:SetViewOffsetDucked(Vector(0, 0, 38))
	ply:SetMoveType(MOVETYPE_WALK)
	ply:DrawShadow(true)
	ply:SetRenderMode(RENDERMODE_NORMAL)

	if SERVER then
		ply:SetSolidFlags(bit.band(ply:GetSolidFlags(), bit.bnot(FSOLID_NOT_SOLID)))

		ply:SetNWEntity("ragdollWeapon", NULL)
		ply:SetNWEntity("ActiveWeapon", NULL)
	end

	timer.Simple(0, function()
		local ang = ply:EyeAngles()
		if ang[3] == 180 then ang[2] = ang[2] + 180 end

		ang[3] = 0

		ply:SetEyeAngles(ang)
	end)

	if SERVER then hg.send(nil, ply, true) end
end)

hook.Add("Player Death", "SetHull", function(ply, attacker)
	timer.Simple(0, function()
		local ang = ply:EyeAngles()

		if ang[3] == 180 then ang[2] = ang[2] + 180 end
		ang[3] = 0

		ply:SetEyeAngles(ang)
	end)
end)

--[[
if CLIENT then
	hook.Add("EntityNetworkedVarChanged", "newfakeentity", function(ply, name, oldval, rag)
		-- print(ply,name,oldval,rag)
		if name == "Ragdoll" then
			ply.FakeRagdoll = rag
			if IsValid(rag) then hook.Run("Fake", "faked", ply, rag) end
		end
	end)
end --]]

if CLIENT then
	hook.Add("NetworkEntityCreated", "hgSyncRagdollsIDK", function(ent)
		if not ent:IsRagdoll() then return end

		timer.Simple(LocalPlayer():Ping() / 100 + 0.1, function()
			if not IsValid(ent) then return end
			if IsValid(ent:GetNWEntity("RagdollOwner")) then hook.Run("Fake", ent:GetNWEntity("RagdollOwner"), ent) end
		end)
	end)
end

hook.Add("Fake", "faked", function(ply, rag)
	ply:SetHull(-Vector(1, 1, 1), Vector(1, 1, 1))
	ply:SetHullDuck(-Vector(1, 1, 1), Vector(1, 1, 1))
	ply:SetViewOffset(Vector(0, 0, 0))
	ply:SetViewOffsetDucked(Vector(0, 0, 0))
	ply:SetMoveType(MOVETYPE_NONE)
end)

function hg.GetCurrentCharacter(ply)
	if not IsValid(ply) then return end

	local rag = ply:GetNWEntity("Ragdoll", NULL)
	ply.FakeRagdoll = rag
	rag = IsValid(rag) and rag

	return IsValid(rag) and rag or ply
end

local lend = 2
local vec = Vector(lend, lend, lend)
local traceBuilder = {
	mins = -vec,
	maxs = vec,
	mask = MASK_SOLID,
	collisiongroup = COLLISION_GROUP_DEBRIS
}

function hg.hullCheck(startpos, endpos, ply)
	if ply:InVehicle() then
		return {HitPos = endpos}
	end

	traceBuilder.start = IsValid(ply.FakeRagdoll) and endpos or startpos
	traceBuilder.endpos = endpos
	traceBuilder.filter = {ply, hg.GetCurrentCharacter(ply)}
	local trace = util.TraceHull(traceBuilder)

	return trace
end

function hg.eyeTrace(ply, dist, ent, aim_vector)
	local fakeCam = IsValid(ply.FakeRagdoll)
	local ent = hg.GetCurrentCharacter(ply)
	local bon = ent:LookupBone("ValveBiped.Bip01_Head1")

	if not bon then return end
	if not IsValid(ply) then return end
	if not ply.GetAimVector then return end

	local aim_vector = aim_vector or ply:GetAimVector()

	if not bon or not ent:GetBoneMatrix(bon) then
		local tr = {
			start = ply:EyePos(),
			endpos = ply:EyePos() + aim_vector * (dist or 60),
			filter = ply
		}

		return util.TraceLine(tr)
	end

	if ply.InVehicle and ply:InVehicle() and IsValid(ply:GetVehicle()) then
		local veh = ply:GetVehicle()
		local vehang = veh:GetAngles()
		local tr = {
			start = ply:EyePos() + vehang:Right() * -6 + vehang:Up() * 4,
			endpos = ply:EyePos() + aim_vector * (dist or 60),
			filter = ply
		}

		return util.TraceLine(tr), nil, headm
	end

	local headm = ent:GetBoneMatrix(bon)
	if CLIENT and ply.headmat then headm = ply.headmat end

	-- local att_ang = ply:GetAttachment(ply:LookupAttachment("eyes")).Ang
	-- ply.lerp_angle = LerpFT(0.1, ply.lerp_angle or Angle(0, 0, 0), ply:GetNWBool("TauntStopMoving", false) and att_ang or aim_vector:Angle())
	-- aim_vector = ply.lerp_angle:Forward()

	local eyeAng = aim_vector:Angle()
	eyeAng:Normalize()

	local eyeang2 = aim_vector:Angle()
	eyeang2.p = 0

	local trace = hg.hullCheck(ply:EyePos() + select(2, ply:GetHull())[2] * eyeAng:Forward(), headm:GetTranslation() + (fakeCam and headm:GetAngles():Forward() * 2 + headm:GetAngles():Up() * -2 + headm:GetAngles():Right() * 3 or eyeAng:Up() * 1 + eyeang2:Forward() * (math.max(eyeAng[1], 0) / 90 + 0.5) * 4 + eyeang2:Right() * 0.5), ply)

	--[[
	if CLIENT then
		cam.Start3D()
			render.DrawWireframeBox(trace.HitPos, angle_zero, traceBuilder.mins, traceBuilder.maxs, color_white)
		cam.End3D()
	end --]]

	local tr = {}
	if not ply:IsPlayer() then return false end

	tr.start = trace.HitPos
	tr.endpos = tr.start + aim_vector * (dist or 60)
	tr.filter = {ply, ent}

	return util.TraceLine(tr), trace, headm
end

if SERVER then
	util.AddNetworkString("keyDownply2")

	hook.Add("KeyPress", "hgKeyDown", function(ply, key)
		net.Start("keyDownply2")
			net.WriteInt(key, 26)
			net.WriteBool(true)
			net.WriteEntity(ply)
		net.Broadcast()
	end)

	hook.Add("KeyRelease", "hgKeyDown2", function(ply, key)
		net.Start("keyDownply2")
			net.WriteInt(key, 26)
			net.WriteBool(false)
			net.WriteEntity(ply)
		net.Broadcast()
	end)
else
	net.Receive("keyDownply2", function(len)
		local key = net.ReadInt(26)
		local down = net.ReadBool()
		local ply = net.ReadEntity()
		if not IsValid(ply) then return end

		ply.keydown = ply.keydown or {}
		ply.keydown[key] = down

		if ply.keydown[key] == false then ply.keydown[key] = nil end
	end)
end

hook.Add("Player Think", "FUCKING FUCK YOU", function(ply, time) -- sure
	if (ply.FUCKYOU_TIMER or 0) < time then
		ply.FUCKYOU_TIMER = time + 1

		ply:SetRenderMode(IsValid(ply:GetNWEntity("Ragdoll")) and RENDERMODE_NONE or RENDERMODE_NORMAL)
	end
end)

function hg.KeyDown(owner, key)
	if not IsValid(owner) then return false end

	owner.keydown = owner.keydown or {}

	local localKey

	if CLIENT then
		if owner == LocalPlayer() then
			localKey = owner:KeyDown(key)
		else
			localKey = owner.keydown[key]
		end
	end

	return SERVER and owner:IsPlayer() and owner:KeyDown(key) or CLIENT and localKey
end

-- guns
game.AddParticles("particles/muzzleflashes_test.pcf")
game.AddParticles("particles/muzzleflashes_test_b.pcf")
game.AddParticles("particles/pcfs_jack_muzzleflashes.pcf")
game.AddParticles("particles/ar2_muzzle.pcf")

local precahche = {"muzzleflash_SR25", "pcf_jack_mf_tpistol", "pcf_jack_mf_mshotgun", "pcf_jack_mf_msmg", "pcf_jack_mf_spistol", "pcf_jack_mf_mrifle2", "pcf_jack_mf_mrifle1", "pcf_jack_mf_mpistol", "pcf_jack_mf_suppressed", "muzzleflash_pistol_rbull", "muzzleflash_m24", "muzzleflash_m79", "muzzleflash_M3", "muzzleflash_m14", "muzzleflash_g3", "muzzleflash_FAMAS", "muzzleflash_ak74", "muzzleflash_ak47", "muzzleflash_mp5", "muzzleflash_suppressed", "muzzleflash_MINIMI", "muzzleflash_svd", "new_ar2_muzzle"}

for _, v in ipairs(precahche) do
	PrecacheParticleSystem(v)
end

-- explosions
game.AddParticles("particles/pcfs_jack_explosions_large.pcf")
game.AddParticles("particles/pcfs_jack_explosions_medium.pcf")
game.AddParticles("particles/pcfs_jack_explosions_small.pcf")
game.AddParticles("particles/pcfs_jack_nuclear_explosions.pcf")
game.AddParticles("particles/pcfs_jack_moab.pcf")
game.AddParticles("particles/gb5_large_explosion.pcf")
game.AddParticles("particles/gb5_500lb.pcf")
game.AddParticles("particles/gb5_100lb.pcf")
game.AddParticles("particles/gb5_50lb.pcf")
game.AddParticles("particles/pcfs_jack_muzzleflashes.pcf")
game.AddParticles("particles/pcfs_jack_explosions_incendiary2.pcf")
game.AddParticles("particles/lighter.pcf")

PrecacheParticleSystem("Lighter_flame")
PrecacheParticleSystem("pcf_jack_nuke_ground")
PrecacheParticleSystem("pcf_jack_nuke_air")
PrecacheParticleSystem("pcf_jack_moab")
PrecacheParticleSystem("pcf_jack_moab_air")
PrecacheParticleSystem("cloudmaker_air")
PrecacheParticleSystem("cloudmaker_ground")
PrecacheParticleSystem("500lb_air")
PrecacheParticleSystem("500lb_ground")
PrecacheParticleSystem("100lb_air")
PrecacheParticleSystem("100lb_ground")
PrecacheParticleSystem("50lb_air")
PrecacheParticleSystem("pcf_jack_incendiary_ground_sm2")
PrecacheParticleSystem("pcf_jack_groundsplode_small3")
PrecacheParticleSystem("pcf_jack_smokebomb3")
PrecacheParticleSystem("pcf_jack_groundsplode_medium")
PrecacheParticleSystem("pcf_jack_groundsplode_large")
PrecacheParticleSystem("pcf_jack_airsplode_medium")