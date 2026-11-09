if SERVER and GetConVar("hg_ConstructOnly"):GetBool() then table.insert(LevelList, "construct") end -- Disabled in normal gameplay

construct = {}
construct.Name = "Construct"
construct.LoadScreenTime = 0
construct.NoSelectRandom = true

local red = Color(155, 155, 255)

function construct.GetTeamName(ply)
	local teamID = ply:Team()

	if teamID == 1 then return "Builder", red end
end

function construct.StartRound(data)
	team.SetColor(1, red)

	game.CleanUpMap(false)

	if CLIENT then
		roundTimeStart = data[1]
		roundTime = data[2]

		construct.StartRoundCL()

		return
	end

	return construct.StartRoundSV()
end

if SERVER then return end

local playsound = false

function construct.StartRoundCL()
	playsound = true
end

function construct.HUDPaint_RoundLeft(white)
	local lply = LocalPlayer()
	local startRound = roundTimeStart + 5 - CurTime()

	if startRound > 0 and lply:Alive() then
		if playsound then playsound = false end

		lply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 220), 0.5, 4)

		return
	end
end

-- For construct, this is probably fine because I assume that it will just force respawn the player.
net.Receive("construct_die", function() timeStartAnyDeath = CurTime() end)

function construct.CanUseSpectateHUD()
	return false
end

construct.RoundRandomDefalut = 3