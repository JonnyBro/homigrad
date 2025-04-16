table.insert(LevelList, "juggernaut")

juggernaut = juggernaut or {}
juggernaut.Name = "Juggernaut"

juggernaut.red = {"Mercenary", Color(125, 125, 125), models = tdm.models}

juggernaut.teamEncoder = {
	[1] = "red"
}

juggernaut.RoundRandomDefalut = 1
juggernaut.CanRandomNext = false

local playsound = false

if SERVER then
	util.AddNetworkString("roundType2")
else
	net.Receive("roundType2", function(len) playsound = true end)
end

function juggernaut.StartRound(data)
	team.SetColor(1, juggernaut.red[2])

	game.CleanUpMap(false)

	if SERVER then
		net.Start("roundType2")
		net.Broadcast()
	end

	if CLIENT then return end

	return juggernaut.StartRoundSV()
end

if SERVER then return end

local red = Color(200, 0, 10)

function juggernaut.GetTeamName(ply)
	if ply.roleT then return "The Juggernaut", red end

	local teamID = ply:Team()

	if teamID == 1 then return "Mercenary", ScoreboardSpec end
end

net.Receive("homicide_roleget2", function()
	for _, ply in player.Iterator() do
		ply.roleT = nil
	end

	local role = net.ReadTable()

	for _, ply in pairs(role[1]) do
		ply.roleT = true
	end
end)

function juggernaut.HUDPaint_Spectate(spec)
	local name, color = juggernaut.GetTeamName(spec)
	draw.SimpleText(name, "HomigradFontBig", ScrW() / 2, ScrH() - 150, color, TEXT_ALIGN_CENTER)
end

function juggernaut.Scoreboard_Status(ply)
	return true
end

local red = Color(200, 0, 10)

function juggernaut.HUDPaint_RoundLeft(white2)
	local lply = LocalPlayer()
	local name, color = juggernaut.GetTeamName(lply)
	local startRound = roundTimeStart + 5 - CurTime()

	if startRound > 0 and lply:Alive() then
		if playsound then
			playsound = false

			surface.PlaySound("snd_jack_hmcd_wildwest.mp3")

			lply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 220), 0.5, 4)
		end

		draw.DrawText("You are " .. name, "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText("Juggernaut", "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)

		if lply.roleT then
			draw.DrawText("You're surrounded by mercenaries. Take them out and remain the only one standing!", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		else
			draw.DrawText("Work together with your friends, and eliminate the Juggernaut.", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		end

		return
	end

	local lply_pos = lply:GetPos()

	for _, ply in player.Iterator() do
		local color = ply.roleT and red
		if not color or ply == lply or not ply:Alive() then continue end

		local pos = ply:GetPos() + ply:OBBCenter()
		local dis = lply_pos:Distance(pos)
		if dis > 750 then continue end

		local pos = pos:ToScreen()
		if not pos.visible then continue end

		color.a = 255 * (1 - dis / 750)

		draw.SimpleText(ply.roleT and "Juggernaut" or "", "HomigradFont", pos.x, pos.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end