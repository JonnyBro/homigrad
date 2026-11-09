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
