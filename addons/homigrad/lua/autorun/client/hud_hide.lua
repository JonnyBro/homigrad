-- Dont draw the HL2 HUD
hook.Add("HUDShouldDraw", "disable", function(name)
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() then
		local wep = ply:GetActiveWeapon()

		if IsValid(wep) then
			if wep.hideammo then
				if name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudDamageIndicator" then return false end
			end
		end
	end
end)