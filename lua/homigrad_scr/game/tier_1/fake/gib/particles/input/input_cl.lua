local mats = {}

for i = 1, 8 do
	mats[i] = Material("decals/blood" .. i)
end

local cloudmat = Material("effects/smoke_b")

local random = math.random
local Rand = math.Rand

local bloodparticels1 = bloodparticels1
local bloodparticels2 = bloodparticels2

local vecZero = Vector(0, 0, 0)

local function addBloodPart(pos, vel, mat, w, h)
	pos = pos + vecZero
	vel = vel + vecZero

	local pos2 = Vector()
	pos2:Set(pos)

	bloodparticels1[#bloodparticels1 + 1] = {pos, pos2, vel, mat, w, h}
end

local function addBloodPart2(pos, vel, mat, w, h, time)
	pos = pos + vecZero
	vel = vel + vecZero

	local pos2 = Vector()
	pos2:Set(pos)

	bloodparticels2[#bloodparticels2 + 1] = {pos, pos2, vel, mat, w, h, CurTime() + time, time}
end

net.Receive("blood particle", function()
	addBloodPart(net.ReadVector(), net.ReadVector(), mats[random(1, #mats)], random(10, 15), random(10, 15))
end)

local Rand = math.Rand
net.Receive("blood particle more", function()
	local pos, vel = net.ReadVector(), net.ReadVector()

	for _ = 1, random(10, 15) do
		addBloodPart2(pos, VectorRand(-50, 50), cloudmat, 50, 50, math.Rand(2, 4))
		addBloodPart(pos, vel + Vector(Rand(-15, 15), Rand(-15, 15)), mats[random(1, #mats)], random(10, 15), random(10, 15))
	end
end)

local function explode(pos, vel)
	local xx, yy = 12, 12
	local w, h = 360 / xx, 360 / yy

	for x = 1, xx do
		addBloodPart2(pos + VectorRand(-20, 20), VectorRand(-50, 50), cloudmat, 100, 100, math.Rand(2, 4))
		for y = 1, yy do
			local dir = Vector(0, 0, -1)
			dir:Rotate(Angle(h * y * Rand(0.9, 1.1), w * x * Rand(0.9, 1.1), 0))

			dir[3] = dir[3] + Rand(0.5, 1.5)

			dir:Mul(250)
			dir = dir + vel

			addBloodPart(pos, dir, mats[random(1, #mats)], random(7, 19), random(7, 10))
		end
	end
end

net.Receive("blood particle explode", function()
	explode(net.ReadVector(), net.ReadVector())
end)

net.Receive("blood particle headshoot", function()
	local pos, vel = net.ReadVector(), net.ReadVector()

	local dir = Vector()
	dir:Set(vel)
	dir:Normalize()
	dir:Mul(25)

	local l1, l2 = pos - dir / 2, pos + dir / 2
	local r = random(10, 15)

	for i = 1, r do
		local vel = Vector(vel[1], vel[2], vel[3])
		vel:Rotate(Angle(Rand(-15, 15) * Rand(0.9, 1.1), Rand(-15, 15) * Rand(0.9, 1.1)))
		addBloodPart2(pos, VectorRand(-50, 50), cloudmat, 50, 50, math.Rand(2, 4))
		addBloodPart(Lerp(i / r * Rand(0.9, 1.1), l1, l2), vel, mats[random(1, #mats)], random(10, 15), random(10, 15))
	end
end)

