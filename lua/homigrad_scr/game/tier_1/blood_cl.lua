blood = 5000
adrenaline = 0

net.Receive("info_blood", function() blood = net.ReadFloat() end)
net.Receive("info_adrenaline", function() adrenaline = net.ReadFloat() end)

hook.Add("RenderScreenspaceEffects", "hgToyTownEffect", function()
	if not LocalPlayer():Alive() then return end

	local fraction = math.Clamp(1 - (blood - 3200) / ((5000 - 1400) - 2000), 0, 1)
	DrawToyTown(fraction * 8, ScrH() * fraction * 1.5)
	DrawSharpen(5, adrenaline / 5)
	if fraction <= 0.7 then return end
	DrawMotionBlur(0.2, 0.9, 0.03)

	-- tab["$pp_colour_contrast"] = math.Clamp(adrenaline, 0.25, 1)
end)

hook.Add("ScalePlayerDamage", "no_effects", function(ent, dmginfo) return true end)