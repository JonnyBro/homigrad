local value = 1

if CLIENT then
	net.Receive("info_staminamul", function()
		value = net.ReadFloat()
	end)
end

local function gg(ply, mv, mul)
	local maxSpeed = mv:GetMaxSpeed() * mul

	mv:SetMaxSpeed(maxSpeed)
	mv:SetMaxClientSpeed(maxSpeed)

	local isSprinting = ply:IsSprinting() and mv:GetForwardSpeed() > 1
	local runSpeed = isSprinting and 450 or ply:GetWalkSpeed()

	ply:SetRunSpeed(Lerp(isSprinting and 0.05 or 1, ply:GetRunSpeed(), runSpeed))

	if ply.IsProne and ply:IsProne() then return end

	local armorSpeedFrac = ply.hgArmor and ply.hgArmor.speedfrac

	if armorSpeedFrac and armorSpeedFrac ~= 1 then
		local adjustedSpeed = maxSpeed * math.max(armorSpeedFrac, 0.75)

		mv:SetMaxSpeed(adjustedSpeed)
		mv:SetMaxClientSpeed(adjustedSpeed)
	end
end

hook.Add("Move", "homigrad", function(ply, mv)
	local mul = CLIENT and value or ply.staminamul or 1

	gg(ply, mv, mul)
end)