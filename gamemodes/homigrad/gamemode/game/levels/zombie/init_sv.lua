function zombie.StartRoundSV(data)
    tdm.RemoveItems()

	tdm.DirectOtherTeam(2,1)

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 4,2))
	roundTimeLoot = 10

    local players = team.GetPlayers(1)

	local spawnsT = ReadDataMap("spawnpointshiders")
	local spawnsCT = ReadDataMap("spawnpointshiders")

	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)

	zombie.police = false

	return {roundTimeLoot = roundTimeLoot}
end

local zombies = {
	"npc_zombie",
	"npc_fastzombie",
	"npc_headcrab",
	"npc_zombie_torso",
	"npc_headcrab_fast",
	"npc_fastzombie_torso",
	--"npc_headcrab_black",--racism
}

function zombie.RoundEndCheck()
    if roundTimeStart + roundTime < CurTime() then
		if not zombie.police then
			zombie.police = true
			PrintMessage(3,"Survivors can now escape through select points on the map.")

			local aviable = ReadDataMap("spawnpointsct")

			for i,ply in pairs(tdm.GetListMul(player.GetAll(),1,function(ply) return not ply:Alive() and not ply.roleT and ply:Team() ~= 1002 end),1) do
				ply:Spawn()

                ply:SetPlayerClass("contr")

				ply:SetTeam(2)
			end
		end
	end

	local zombies_spawnpoints = hg.RandomSpawns()

	zombie.SpawnZombieTime = zombie.SpawnZombieTime or CurTime()

	if ((roundTimeStart + 10) < CurTime()) and (zombie.SpawnZombieTime < CurTime()) then
		zombie.SpawnZombieTime = CurTime() + 0.5

		local players = PlayersAlive()

		local pos = zombies_spawnpoints[math.random(#zombies_spawnpoints)]

		local zombie = ents.Create(zombies[math.random(#zombies)])

		local tr = {}
		tr.start = pos
		tr.endpos = pos
		tr.filter = zombie
		tr.mask = MASK_SOLID_BRUSHONLY

		if not util.TraceEntityHull(tr, zombie).Hit then
			zombie:SetPos(pos)
			zombie:Spawn()
			local ply = players[math.random(#players)]
			zombie:SetEnemy(ply)
			zombie:UpdateEnemyMemory(ply, ply:GetPos())
		end
	end

	local CTAlive,CTExit = 0,0

	local OAlive = 0

	CTAlive = tdm.GetCountAlive(team.GetPlayers(1),function(ply)
		if ply.exit then CTExit = CTExit + 1 return false end
	end)

	local list = ReadDataMap("spawnpoints_ss_exit")

	if zombie.police then
		for i,ply in pairs(team.GetPlayers(1)) do
			if not ply:Alive() or ply.exit then continue end

			for i,point in pairs(list) do
				if ply:GetPos():Distance(point[1]) < (point[3] or 250) then
					ply.exit = true
					ply:KillSilent()

					CTExit = CTExit + 1

					PrintMessage(3,ply:GetName().." has escaped! "..(CTAlive - 1) .. " survivors remain.")
				end
			end
		end
	end

	if CTExit > 0 and CTAlive == 0 then EndRound(1) return end
	if CTAlive == 0 then EndRound() return end
end

function zombie.EndRound(winner)
	if winner == 1 then
		PrintMessage(3,"Survivors managed to extract!")
	else
		PrintMessage(3,"No one survived.")
	end
end

function zombie.PlayerSpawn2(ply,teamID)
	local teamTbl = zombie[zombie.teamEncoder[teamID]]
	local color = teamTbl[2]

	-- Set the player's model to the custom model if available, otherwise use a random team model
    local customModel = GetPlayerModelBySteamID(ply:SteamID())

    if customModel then
        ply:SetModel(customModel)
    else
        EasyAppearance.SetAppearance( ply )
    end

    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	tdm.GiveSwep(ply,teamTbl.main_weapon,teamID == 1 and 16 or 4)
	tdm.GiveSwep(ply,teamTbl.secondary_weapon,teamID == 1 and 8 or 2)

	if math.random(1,8) == 8 then ply:Give("adrenaline") end
	if math.random(1,7) == 7 then ply:Give("painkiller") end
	if math.random(1,6) == 6 then ply:Give("medkit") end
	if math.random(1,5) == 5 then ply:Give("med_band_big") end
	if math.random(1,8) == 8 then ply:Give("morphine") end

	if ply:IsUserGroup("sponsor") or ply:IsUserGroup("supporterplus") or ply:IsAdmin() then
		if math.random(1, 5) == 5 then ply:Give("weapon_gear_bloxycola") end
		if math.random(1, 5) == 5 then ply:Give("weapon_gear_cheezburger") end

		ply:Give("weapon_vape")
	end

	if math.random(1,5) == 5 then ply:Give("weapon_bat") end

	ply:SetPlayerColor(Color(math.random(160),math.random(160),math.random(160)):ToVector())

	ply.allowFlashlights = false
end

function zombie.PlayerInitialSpawn(ply) ply:SetTeam(2) end

function zombie.PlayerCanJoinTeam(ply,teamID)
	if teamID == 2 then
		if ply:IsAdmin() then
			ply:Spawn()

			return true
		else
			ply:ChatPrint("Not now.")

			return false
		end
	end

    if teamID == 1 then
		if ply:IsAdmin() then
			return true
		else
			ply:ChatPrint("Please wait until next round to join!")

			return false
		end
	end
end

local common = {  "weapon_tomahawk", "weapon_hg_molotov", "*ammo*", "weapon_hg_sledgehammer", "weapon_hg_fireaxe", "ent_jack_gmod_ezarmor_gasmask", "ent_jack_gmod_ezarmor_mltorso" }
local uncommon = { "weapon_m4super", "weapon_ar15", "weapon_beretta", "ent_jack_gmod_ezarmor_mtorso", "ent_jack_gmod_ezarmor_mhead" }
local rare = { "weapon_xm1014", "weapon_m4a1", "weapon_xm8_lmg", "weapon_hk416", "weapon_civil_famas", "weapon_glock", "weapon_remington870", "weapon_akm", "weapon_rpk", "weapon_p90", "weapon_asval"}

function zombie.ShouldSpawnLoot()
   	if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end

	local chance = math.random(100)
	if chance < 25 then
		return true,rare[math.random(#rare)]
	elseif chance < 60 then
		return true,uncommon[math.random(#uncommon)]
	elseif chance < 100 then
		return true,common[math.random(#common)]
	else
		return false
	end
end

function zombie.PlayerDeath(ply,inf,att) return false end

function zombie.GuiltLogic(ply,att,dmgInfo)
	if att.isContr and ply:Team() == 1 then return dmgInfo:GetDamage() * 3 end
end

zombie.NoSelectRandom = true

hook.Add( "Think", "NPCAutoSeekPlayer", function()
	if roundActiveName ~= "zombie" then return end

	if (zombie.CooldownThink or 0) > CurTime() then return end
	zombie.CooldownThink = CurTime() + 5

	local npcs = ents.FindByClass("npc_*")
	local plys = player.GetAll()
	local plyCount = #plys

	if ( plyCount == 0 ) then
		return
	end

	for i = 1, #npcs do
		local npc = npcs[ i ]

		if ( npc:IsNPC() && !IsValid( npc:GetEnemy() ) ) then
			local curPly = nil
			local curPlyPos = nil
			local curDist = math.huge

			local npcPos = npc:GetPos()

			for i = 1, plyCount do
				local ply = plys[ i ]

				if ( npc:Disposition( ply ) == D_HT ) then
					local plyPos = ply:GetPos()

					local dist = npcPos:DistToSqr( plyPos )

					if ( dist < curDist ) then
						curPly = ply
						curPlyPos = plyPos
						curDist = dist
					end
				end
			end

			if curPly and curPlyPos then
				npc:SetEnemy( curPly )
				npc:UpdateEnemyMemory( curPly, curPlyPos )
			end
		end
	end
end )