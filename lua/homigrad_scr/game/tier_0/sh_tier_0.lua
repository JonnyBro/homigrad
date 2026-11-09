ftlerped = 1 / 66

hook.Add("Think", "Mul lerp", function()
	ftlerped = math.Clamp(FrameTime(), 0.001, 0.1)
end)

function hg.FrameTimeClamped(ft)
	return math.Clamp(1 - math.exp(-0.5 * (ft or ftlerped)), 0.001, 0.01)
end

local FrameTimeClamped_ = hg.FrameTimeClamped

local function lerpFrameTime2(lerp, frameTime)
	return math.Clamp(lerp * FrameTimeClamped_(frameTime) * 150, 0, 1)
end

function LerpFT(lerp, source, set)
	return Lerp(lerpFrameTime2(lerp), source, set)
end

function LerpAngleFT(lerp, source, set)
	return LerpAngle(lerpFrameTime2(lerp), source, set)
end

local file_Find = file.Find
local d, f, split, path2
local string_sub, string_split = string.sub, string.Split

function file.Exists(path, gamePath)
	split = string_split(path, "/")
	path2 = split[#split]

	if path2 == "" then
		path2 = split[#split - 1]
		path = string_sub(path, 1, #path - #path2 - 1)
	else
		path = string_sub(path, 1, #path - #path2)
	end

	f, d = file_Find(path .. "*", gamePath)

	for i = 1, #d do
		if d[i] == path2 then return true end
	end

	for i = 1, #f do
		if f[i] == path2 then return true end
	end

	return false
end
