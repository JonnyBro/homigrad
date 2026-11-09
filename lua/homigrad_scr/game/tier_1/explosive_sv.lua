local doorClasses = {
	prop_door = true,
	prop_door_rotating = true,
	func_door = true,
	func_door_rotating = true
}

local wreckBlacklist = {
	gmod_lamp = true,
	gmod_cameraprop = true,
	gmod_light = true,
	prop_ragdoll = true
}

function hg.Sploom(attacker, pos, mag, radius)
	local boom = ents.Create("env_explosion")
	boom:SetPos(pos)
	boom:SetOwner(attacker or game.GetWorld())
	boom:SetKeyValue("iMagnitude", mag or "1")

	if radius then boom:SetKeyValue("iRadiusOverride", radius) end

	boom:Spawn()
	boom:Activate()
	boom:Fire("explode", "", 0)
end

local fragSpread = Vector(0, 0, 0.125)
local FRAG_MAX_BULLETS = 600
local FRAG_DURATION = 1
local FRAG_BATCHES = 20
local fragTimerID = 0

function hg.FragSplosion(shooter, origin, fragNum, fragDmg, fragMaxDist, attacker)
	local eff = EffectData()
	eff:SetOrigin(origin)
	eff:SetScale(fragNum)
	eff:SetNormal(vector_origin)
	eff:SetMagnitude(0)
	util.Effect("hg_fragsplosion", eff, true, true)

	local fired = 0
	local perBatch = math.ceil(fragNum / FRAG_BATCHES)

	fragTimerID = fragTimerID + 1

	-- Fragments are spread over a second so a single grenade doesn't trace thousands of times in one tick
	timer.Create("hg_frag" .. fragTimerID, FRAG_DURATION / FRAG_BATCHES, FRAG_BATCHES, function()
		local firer = IsValid(shooter) and shooter or game.GetWorld()

		for _ = 1, perBatch do
			local dir = VectorRand()
			dir.z = dir.z / 2
			dir:Normalize()

			local tr = util.QuickTrace(origin, dir * fragMaxDist, shooter)
			if not tr.Hit or tr.HitSky or tr.HitWorld or fired >= FRAG_MAX_BULLETS then continue end

			local impact = EffectData()
			impact:SetEntity(tr.Entity)
			impact:SetOrigin(tr.HitPos)
			impact:SetStart(tr.StartPos)
			impact:SetSurfaceProp(tr.SurfaceProps)
			impact:SetDamageType(DMG_BULLET)
			impact:SetHitBox(tr.HitBox)
			util.Effect("Impact", impact)

			local ent = tr.Entity
			local lowFrag = ent:IsVehicle() or ent.LFS
			if lowFrag and math.random(1, 4) ~= 2 then continue end

			local dmgMul = fired > 500 and 5 or 1

			firer:FireBullets({
				Attacker = attacker,
				Damage = fragDmg * dmgMul,
				Force = fragDmg / 8 * (dmgMul / 4),
				Num = 1,
				Src = origin,
				Tracer = 0,
				Dir = dir,
				Spread = fragSpread,
				AmmoType = "Buckshot",
			})

			fired = fired + 1
		end
	end)
end

local function visibleFrom(pos, ent, blaster)
	local tr = util.QuickTrace(pos, ent:LocalToWorld(ent:OBBCenter()) - pos, blaster)

	return tr.Entity == ent
end

function hg.WreckBuildings(blaster, pos, power)
	local maxRange = 250 * power
	local maxMassToDestroy = 10 * power ^ .8
	local maxMassToLoosen = 30 * power

	for _, prop in ipairs(ents.FindInSphere(pos, maxRange)) do
		if prop == blaster or wreckBlacklist[prop:GetClass()] or prop.ExplProof then continue end

		local phys = prop:GetPhysicsObject()
		if not IsValid(phys) or not visibleFrom(pos, prop, blaster) then continue end

		local propPos = prop:LocalToWorld(prop:OBBCenter())
		local distFrac = 1 - propPos:Distance(pos) / maxRange
		local destroyThreshold, loosenThreshold = distFrac * maxMassToDestroy, distFrac * maxMassToLoosen

		if distFrac >= .85 then
			destroyThreshold = destroyThreshold * 7
			loosenThreshold = loosenThreshold * 7
		end

		local mass = phys:GetMass()
		local dir = (propPos - pos):GetNormalized()

		if mass <= destroyThreshold then
			prop:Remove()
		elseif mass <= loosenThreshold then
			phys:EnableMotion(true)
			constraint.RemoveAll(prop)
			phys:ApplyForceOffset(dir * 1000 * distFrac * power * mass, propPos + VectorRand() * 10)
		else
			phys:ApplyForceOffset(dir * 200 * distFrac * power * mass, propPos + VectorRand() * 10)
		end
	end
end

local DOOR_RESET_TIME = 30

local function blastDoor(door, vel)
	local model, pos, ang, mat, skin = door:GetModel(), door:GetPos(), door:GetAngles(), door:GetMaterial(), door:GetSkin()

	sound.Play("Wood_Crate.Break", pos, 60, 100)
	sound.Play("Wood_Furniture.Break", pos, 60, 100)

	door:Fire("unlock", "", 0)
	door:Fire("open", "", 0)
	door:SetNoDraw(true)
	door:SetNotSolid(true)

	if not model then return end

	local replacement = ents.Create("prop_physics")
	replacement:SetModel(model)
	replacement:SetPos(pos + Vector(0, 0, 1))
	replacement:SetAngles(ang)
	replacement:SetMaterial(mat)
	replacement:SetSkin(skin)
	replacement:SetModelScale(.9, 0)
	replacement:Spawn()
	replacement:Activate()
	replacement:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	local phys = replacement:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetVelocity(vel)

		timer.Simple(0, function()
			if IsValid(phys) then phys:ApplyForceCenter(vel * 100) end
		end)
	end

	timer.Simple(DOOR_RESET_TIME, function()
		if IsValid(door) then
			door:SetNotSolid(false)
			door:SetNoDraw(false)
		end

		if IsValid(replacement) then replacement:Remove() end
	end)
end

function hg.BlastDoors(blaster, pos, power)
	for _, door in ipairs(ents.FindInSphere(pos, 40 * power)) do
		if not doorClasses[door:GetClass()] or not visibleFrom(pos, door, blaster) then continue end

		blastDoor(door, (door:LocalToWorld(door:OBBCenter()) - pos):GetNormalized() * 1000)
	end
end

function hg.SpawnFlames(pos, count, speedMul)
	local world = game.GetWorld()

	for _ = 1, count do
		local dir = (VectorRand() * .3 + Vector(0, 0, .3)):GetNormalized()
		dir.z = dir.z / 2

		local flame = ents.Create("ent_hg_napalm")
		flame:SetPos(pos)
		flame:SetAngles(dir:Angle())
		flame:SetOwner(world)
		flame.Owner = world
		flame.SpeedMul = speedMul
		flame.Creator = world
		flame.HighVisuals = true
		flame:Spawn()
		flame:Activate()
	end
end

function hg.ExplodeProp(ent, big)
	local pos, power = ent:LocalToWorld(ent:OBBCenter()), big and 4 or 2

	timer.Simple(math.Rand(0, .1), function()
		ParticleEffect(big and "pcf_jack_groundsplode_medium" or "pcf_jack_groundsplode_small", pos, vector_up:Angle())

		util.ScreenShake(pos, 99999, 99999, 1, 3000)

		local pitchMin, pitchMax = big and 80 or 140, big and 110 or 160

		sound.Play("BaseExplosionEffect.Sound", pos, 120, big and math.random(90, 110) or math.random(130, 160))

		for _ = 1, 4 do
			sound.Play("explosions/doi_ty_01_close.wav", pos, 140, math.random(pitchMin, pitchMax))
		end

		timer.Simple(.1, function()
			for _ = 1, 5 do
				local tr = util.QuickTrace(pos, VectorRand() * 20)
				if tr.Hit then util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal) end
			end
		end)

		hg.SpawnFlames(pos + Vector(0, 0, big and 80 or 50), big and 10 or 3, big and 0.2 or 0.25)
		hg.WreckBuildings(ent, pos, power / 2)
		hg.BlastDoors(ent, pos, power)

		timer.Simple(0, function()
			local world = game.GetWorld()
			local infl = IsValid(ent) and ent or world
			local att = IsValid(ent) and IsValid(ent.Owner) and ent.Owner or infl

			util.BlastDamage(infl, att, pos, 120 * power, 120 * power)
			util.BlastDamage(infl, att, pos, 20 * power, 1000 * power)
		end)
	end)
end

local breakBig = {
	["models/props_c17/oildrum001_explosive.mdl"] = true
}

local breakSmall = {
	["models/props_junk/gascan001a.mdl"] = true,
	["models/props_junk/propane_tank001a.mdl"] = true,
	["models/props_junk/PropaneCanister001a.mdl"] = true,
}

hook.Add("PropBreak", "PropVengeance", function(_, prop)
	local model = prop:GetModel()

	if breakBig[model] then
		hg.ExplodeProp(prop, true)
	elseif breakSmall[model] then
		hg.ExplodeProp(prop)
	end
end)
