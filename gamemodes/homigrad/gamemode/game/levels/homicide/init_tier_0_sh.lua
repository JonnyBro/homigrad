table.insert(LevelList, "homicide")

homicide = homicide or {}
homicide.Name = "#hg.homicide.name"

homicide.red = {
	"#hg.homicide.team1", Color(255, 255, 255), models = tdm.models
}

homicide.blue = {
	"#hg.homicide.team2", Color(255, 0, 0), models = tdm.models
}

homicide.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

homicide.RoundRandomDefalut = 6

local playsound = false

if SERVER then
	util.AddNetworkString("roundType")
	util.AddNetworkString("homicide_support_arrival")
else
	net.Receive("roundType", function(len)
		homicide.roundType = net.ReadInt(5)
		playsound = true
	end)

	local supportArrivalTime = 0

	net.Receive("homicide_support_arrival", function()
		supportArrivalTime = net.ReadFloat()
	end)

	hook.Add("HUDPaint", "DrawSupportArrivalTime", function()
		local lply = LocalPlayer()

		if supportArrivalTime > 0 and not lply:Alive() then
			local timeLeft = math.max(0, supportArrivalTime - CurTime())

			draw.DrawText(language.GetPhrase("hg.modes.respawnassupport"):format(tostring(timeLeft)), "HomigradFontBig", 10, ScrH() - 50, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
		end
	end)
end

--[[
local turnTable = {
	["standard"] = 2,
	["soe"] = 1,
	["wild-west"] = 4,
	["gun-free-zone"] = 3
}--]]

CreateConVar("homicide_setmode", "", FCVAR_LUA_SERVER, "")
CreateClientConVar("homicide_get", 0, true, true, "Show traitors and stuff while you're spectating", 0, 1)

function homicide.IsMapBig()
	local mins, maxs = game.GetWorld():GetModelBounds()
	local skybox = 0

	--[[ huh?
	for _, ent in pairs(ents.FindByClass("sky_camera")) do
		skybox = 0
	end --]]

	return (mins:Distance(maxs) - skybox) > 5000
end

function homicide.StartRound(data)
	game.CleanUpMap(false)

	team.SetColor(1, homicide.red[2])

	if SERVER then
		homicide.roundType = math.random(1, 5)

		net.Start("roundType")
			net.WriteInt(homicide.roundType, 5)
		net.Broadcast()
	end

	if CLIENT then
		for _, ply in player.Iterator() do
			ply.roleT = false
			ply.roleCT = false
			ply.countKick = 0
		end

		roundTimeLoot = data.roundTimeLoot

		return
	end

	return homicide.StartRoundSV()
end

if SERVER then return end

local red, blue = Color(200, 0, 10), Color(75, 75, 255)
local white = Color(255, 255, 255, 255)

function homicide.GetTeamName(ply)
	if ply.roleT then return "#hg.homicide.team2", red end
	if ply.roleCT then return "#hg.homicide.team1", blue end

	local teamID = ply:Team()

	if teamID == 1 then return "#hg.homicide.team1", white end
	if teamID == 3 then return "#hg.modes.team.police", blue end
end

net.Receive("homicide_roleget", function()
	for _, ply in pairs(player.GetAll()) do
		ply.roleT = nil
		ply.roleCT = nil
	end

	local role = net.ReadTable()

	for _, ply in pairs(role[1]) do
		ply.roleT = true
	end

	for _, ply in pairs(role[2]) do
		ply.roleCT = true
	end
end)

function homicide.HUDPaint_Spectate(spec)
	-- local name, color = homicide.GetTeamName(spec)
	-- draw.SimpleText(name, "HomigradFontBig", ScrW() / 2, ScrH() - 150, color, TEXT_ALIGN_CENTER)
end

function homicide.Scoreboard_Status(ply)
	local lply = LocalPlayer()
	if not lply:Alive() or lply:Team() == 1002 then return true end

	return "#hg.modes.team.unknown", ScoreboardSpec
end

local red, blue = Color(200, 0, 10), Color(75, 75, 255)
local roundSound = {"snd_jack_hmcd_disaster.mp3", "snd_jack_hmcd_shining.mp3", "snd_jack_hmcd_panic.mp3", "snd_jack_hmcd_wildwest.mp3", "snd_jack_hmcd_disaster.mp3"}

function homicide.HUDPaint_RoundLeft(white2)
	local roundType = homicide.roundType or 2
	local lply = LocalPlayer()
	local name, color = homicide.GetTeamName(lply)
	local startRound = roundTimeStart + 5 - CurTime()

	if startRound > 0 and lply:Alive() then
		if playsound then
			playsound = false

			surface.PlaySound(roundSound[roundType])
			lply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 220), 0.5, 4)
		end

		draw.DrawText(language.GetPhrase("hg.modes.yourteam"):format(language.GetPhrase(name)), "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(language.GetPhrase("hg.homicide.name"), "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(language.GetPhrase("hg.homicide.mode" .. tostring(roundType)), "HomigradRoundFont", ScrW() / 2, ScrH() / 5, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)

		if lply.roleT then -- Traitor
			draw.DrawText(language.GetPhrase("hg.homicide.desc.t" .. tostring(roundType)), "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		elseif lply.roleCT then -- Innocent w/ a gun
			draw.DrawText(language.GetPhrase("hg.homicide.desc.ct" .. tostring(roundType)), "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		else -- Innocent
			draw.DrawText(language.GetPhrase("hg.homicide.desc.ct0"), "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		end

		return
	end

	local lply_pos = lply:GetPos()

	for _, ply in player.Iterator() do
		local color = ply.roleT and red or ply.roleCT and blue
		if not color or ply == lply or not ply:Alive() then continue end

		local pos = ply:GetPos() + ply:OBBCenter()
		local dis = lply_pos:Distance(pos)
		if dis > 1024 then continue end

		local pos = pos:ToScreen()
		if not pos.visible then continue end

		color.a = 255 * (1 - dis / 1024)

		draw.SimpleText(((ply.roleT and language.GetPhrase("hg.homicide.team2") .. ": ") or language.GetPhrase("hg.homicide.team1") .. ": ") .. ply:Name(), "HomigradFontBig", pos.x, pos.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function homicide.VBWHide(ply, wep)
	if not ply:IsRagdoll() and ply:Team() == 1002 then return end

	return wep.IsPistolHoldType and wep:IsPistolHoldType()
end

function homicide.Scoreboard_DrawLast(ply)
	if LocalPlayer():Team() ~= 1002 and LocalPlayer():Alive() then return false end
end

homicide.SupportCenter = true