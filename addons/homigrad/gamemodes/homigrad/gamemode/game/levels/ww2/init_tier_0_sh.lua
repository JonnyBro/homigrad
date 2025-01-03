table.insert(LevelList, "ww2")

ww2 = {}
ww2.Name = "Вторая Мировая"

ww2.red = {
	"Красная Армия", Color(255, 75, 60), weapons = {"megamedkit", "weapon_binokle", "weapon_hands", "med_band_big", "med_band_small", "medkit", "weapon_hg_f1", "weapon_hg_crowbar"},
	main_weapon = {"weapon_cmosin", "weapon_cppsh41"},
	models = {"models/player/sev2/russian_soldier.mdl"}
}

ww2.blue = {
	"Вермахт", Color(125, 125, 255), weapons = {"megamedkit", "weapon_binokle", "weapon_hands", "weapon_kabar", "med_band_small", "med_band_big", "weapon_hg_stielhandgranate24", "med_band_small", "medkit", "weapon_hg_crowbar"},
	main_weapon = {"weapon_ck98", "weapon_csmg40"},
	models = {"models/gerconscript7.mdl"}
}

ww2.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function ww2.StartRound()
	game.CleanUpMap(false)
	ww2.points = {}

	if not file.Read("homigrad/maps/controlpoint/" .. game.GetMap() .. ".txt", "DATA") and SERVER then
		PrintMessage(HUD_PRINTCENTER, "Скажите админу чтоб тот создал !point control_point или хуярьтесь без Точек Захвата.")
	end

	ww2.LastWave = CurTime()
	ww2.WinPoints = {}
	ww2.WinPoints[1] = 0
	ww2.WinPoints[2] = 0

	team.SetColor(1, ww2.red[2])
	team.SetColor(2, ww2.blue[2])

	for i, point in pairs(SpawnPointsList.controlpoint[3]) do
		SetGlobalInt(i .. "PointProgress", 0)
		SetGlobalInt(i .. "PointCapture", 0)

		ww2.points[i] = {}
	end

	SetGlobalInt("ww2_respawntime", CurTime())

	if CLIENT then return end

	timer.Create("ww2_ThinkAboutPoints", 1, 0, function()
		ww2.PointsThink()
	end)

	if CLIENT then
		ww2.StartRoundCL()

		return
	end

	ww2.StartRoundSV()
end

ww2.RoundRandomDefalut = 1
ww2.SupportCenter = true