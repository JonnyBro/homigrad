local mats = {}

for i = 1, 8 do
	mats[i] = Material("decals/blood" .. i)
end

local vecZero = Vector(0, 0, 0)

local function addBloodPart(pos, vel, mat, w, h)
	pos = pos + vecZero
	vel = vel + vecZero

	local pos2 = Vector()
	pos2:Set(pos)

	bloodparticels1[#bloodparticels1 + 1] = {pos, pos2, vel, mat, w, h}
end

net.Receive("blood particle", function()
	addBloodPart(net.ReadVector(), net.ReadVector(), mats[math.random(1, #mats)], math.random(10, 15), math.random(10, 15))
end)

net.Receive("blood particle more", function()
	local pos, vel = net.ReadVector(), net.ReadVector()

	for i = 1, math.random(10, 15) do
		addBloodPart(pos, vel + Vector(math.Rand(-15, 15), math.Rand(-15, 15)), mats[math.random(1, #mats)], math.random(10, 15), math.random(10, 15))
	end
end)

local function addBloodPart2(pos, vel, mat, w, h, time)
	pos = pos + vecZero
	vel = vel + vecZero

	local pos2 = Vector()
	pos2:Set(pos)

	bloodparticels2[#bloodparticels2 + 1] = {pos, pos2, vel, mat, w, h, CurTime() + time, time}
end

local function explode(pos)
	local xx, yy = 12, 12
	local w, h = 360 / xx, 360 / yy

	for x = 1, xx do
		for y = 1, yy do
			local dir = Vector(0, 0, -1)
			dir:Rotate(Angle(h * y * math.Rand(0.9, 1.1), w * x * math.Rand(0.9, 1.1), 0))
			dir[3] = dir[3] + math.Rand(0.5, 1.5)
			dir:Mul(250)

			addBloodPart(pos, dir, mats[math.random(1, #mats)], math.random(7, 19), math.random(7, 10))
		end
	end
end

net.Receive("blood particle explode", function()
	explode(net.ReadVector())
end)

local vecR = Vector(10, 10, 10)

net.Receive("blood particle headshoot", function()
	local pos, vel = net.ReadVector(), net.ReadVector()

	local dir = Vector()
	dir:Set(vel)
	dir:Normalize()
	dir:Mul(25)

	local l1, l2 = pos - dir / 2, pos + dir / 2
	local r = math.random(10, 15)

	for i = 1, r do
		local vel = Vector(vel[1], vel[2], vel[3])
		vel:Rotate(Angle(math.Rand(-15, 15) * math.Rand(0.9, 1.1), math.Rand(-15, 15) * math.Rand(0.9, 1.1)))
		addBloodPart(Lerp(i / r * math.Rand(0.9, 1.1), l1, l2), vel, mats[math.random(1, #mats)], math.random(10, 15), math.random(10, 15))
	end

	for i = 1, 8 do
		addBloodPart2(pos, vecZero, mats[math.random(1, #mats)], math.random(30, 45), math.random(30, 45), math.Rand(1, 2))
	end
end)

concommand.Add("testpart", function()
	local pos = Vector(1200.543579, 699.216309, 300.834564)
	local vel = Vector(1024, 0, 0)

	local dir = Vector()
	dir:Set(vel)
	dir:Normalize()
	dir:Mul(25)

	for i = 1, 8 do
		addBloodPart2(pos + VectorRand(-vecR, vecR), VectorRand(-vecR, vecR), mats[math.random(1, #mats)], math.random(30, 45), math.random(30, 45), math.Rand(1, 2))
	end
end)

concommand.Add("freecamera", function(ply)
	if not ply:IsAdmin() then return end

	freecameraPos = ply:EyePos()
	freecameraAng = ply:EyeAngles()

	freecamera = not freecamera
end)

hook.Add("Move", "FreeCamera", function(mv)
	if not freecamera then return end
end)

local view = {}

hook.Add("PreCalcView", "!", function(ply, pos, ang)
	if not freecamera then return end

	view.origin = freecameraPos
	view.angles = freecameraAng
	view.fov = CameraLerpFOV
	view.drawviewer = true

	return view
end)