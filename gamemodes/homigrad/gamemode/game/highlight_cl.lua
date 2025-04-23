-- Idea from https://github.com/chominapisaLi/HomiFork <3

local highlightDistance = 100
local haloColor = Color(255, 255, 255)
local baseHaloSize = 10
local pulseSpeed = 1
local pulseSize = 2
local maxDistance = 100
local minDistance = 10

-- format: multiline
local targetPrefixes = {
	"hg_box",
	"weapon",
	"food",
	"med",
}

local function GetDistanceAlpha(dist)
	return 1 - math.Clamp((dist - minDistance) / (maxDistance - minDistance), 0, 1)
end

local function ShouldHighlight(class)
	for _, prefix in ipairs(targetPrefixes) do
		if string.StartsWith(class, prefix) then return true end
	end

	return false
end

hook.Add("PreDrawHalos", "hg_HighlightTarget", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end

	local pulseOffset = math.sin(CurTime() * pulseSpeed) * pulseSize
	local trace = ply:GetEyeTrace()

	local ent = trace.Entity
	if not IsValid(ent) then return end

	local distance = ply:GetPos():Distance(ent:GetPos())
	if distance > highlightDistance then return end

	local class = ent:GetClass()

	if ShouldHighlight(class) then
		local alpha = GetDistanceAlpha(distance)
		local drawColor = Color(haloColor.r, haloColor.g, haloColor.b, alpha * 255)
		local sizeMultiplier = math.Clamp(1 - distance / highlightDistance, 0.5, 1)
		local finalSize = (baseHaloSize + pulseOffset) * sizeMultiplier

		halo.Add({ent}, drawColor, finalSize, finalSize, 1, true, true)
	end
end)