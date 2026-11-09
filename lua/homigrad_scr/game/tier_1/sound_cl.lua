local tr = {}

local function filter(ent)
	return not ent:IsPlayer() and not ent:IsNPC() and not ent:IsRagdoll()
end

local PointContents = util.PointContents
local bit_band = bit.band

local function InTheWall(pos, eyePos, count, mul)
	tr.start = pos
	tr.endpos = eyePos
	tr.filter = filter

	local dir = eyePos - pos
	dir:Normalize()
	dir:Mul(mul)

	local result = util.TraceLine(tr)
	if result.HitPos:Distance(eyePos) <= 32 then return count end
	if result.Hit then
		pos = result.HitPos

		for i = 1, count do
			pos:Add(dir)

			if bit_band(PointContents(pos), CONTENTS_EMPTY) then
				count = count - i
				if count <= 0 then return count end

				return InTheWall(pos, eyePos, count - i + 1, mul)
			end
		end

		return 0
	else
		return count
	end
end

local function getDSP(pos)
	local count = InTheWall(pos, EyePos(), 3, 16)

	if count == 3 then
		return 0
	elseif count == 2 then
		return 15
	elseif count == 1 then
		return 16
	end
end

net.Receive("sound", function()
	local packet = net.ReadTable()
	local dsp = getDSP(packet[2])
	if not dsp then return end

	EmitSound(packet[1], packet[2], packet[3], nil, packet[4], packet[5], nil, packet[6], dsp == 0 and packet[7] or dsp)
end)
