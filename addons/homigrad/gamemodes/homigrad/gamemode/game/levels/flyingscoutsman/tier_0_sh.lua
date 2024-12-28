table.insert(LevelList,"scout")
scout = {}
scout.Name = "Перелётные Снайперы"

local models = {}

for i = 1,9 do table.insert(models,"models/player/group01/male_0" .. i .. ".mdl") end

for i = 1,6 do table.insert(models,"models/player/group01/female_0" .. i .. ".mdl") end

--table.insert(models,"models/player/group02/male_02.mdl")
--table.insert(models,"models/player/group02/male_06.mdl")
--table.insert(models,"models/player/group02/male_08.mdl")

--for i = 1,9 do table.insert(models,"models/player/group01/male_0" .. i .. ".mdl") end

scout.models = models
scout.red = {
	"Голуби",Color(255,75,75),
	weapons = {"weapon_binokle","weapon_radio","weapon_gurkha","weapon_hands","med_band_big","med_band_small","medkit","painkiller","shina"},
	main_weapon = {"weapon_slb_scout"},
	models = models
}


scout.blue = {
	"Воробьи",Color(75,75,255),
	weapons = {"weapon_binokle","weapon_radio","weapon_hands","weapon_kabar","med_band_big","med_band_small","medkit","painkiller","weapon_handcuffs","shina"},
	main_weapon = {"weapon_slb_scout"},
	models = models
}

scout.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function scout.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,red)
	team.SetColor(2,blue)

	if CLIENT then return end

	scout.StartRoundSV()
end

if SERVER then return end

local colorRed = Color(255,0,0)

function scout.GetTeamName(ply)
	local game = TableRound()
	local team = game.teamEncoder[ply:Team()]

	if team then
		team = game[team]

		return team[1],team[2]
	end
end

function scout.ChangeValue(oldName,value)
	local oldValue = scout[oldName]

	if oldValue ~= value then
		oldValue = value

		return true
	end
end

function scout.AccurceTime(time)
	return string.FormattedTime(time,"%02i:%02i")
end