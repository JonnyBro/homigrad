util.AddNetworkString( "DoPlayerFlinch" )

hook.Add( "ScalePlayerDamage", "FlinchPlayersOnHit", function(ply, grp)
	if ply:IsPlayer() then
		--could maybe return end, 
		--but would that override other Scale hooks?
		local group = nil
		local hitpos = {}
		if GetConVar("sv_st_uselookups"):GetBool() then
			hitpos = {
				[HITGROUP_HEAD] = ACT_FLINCH_HEAD, --1
				[HITGROUP_CHEST] = ACT_FLINCH_STOMACH, --2
				[HITGROUP_STOMACH] = ACT_FLINCH_STOMACH, --3
				[HITGROUP_LEFTARM] = ply:GetSequenceActivity(ply:LookupSequence("flinch_shoulder_l")), --4
				[HITGROUP_RIGHTARM] = ply:GetSequenceActivity(ply:LookupSequence("flinch_shoulder_r")), --5
				[HITGROUP_LEFTLEG] = ply:GetSequenceActivity(ply:LookupSequence("flinch_01")), --6
				[HITGROUP_RIGHTLEG] =  ply:GetSequenceActivity(ply:LookupSequence("flinch_02")) --7
			}
		else
			hitpos = {
				[HITGROUP_HEAD] = ACT_FLINCH_HEAD, --1
				[HITGROUP_CHEST] = ACT_FLINCH_STOMACH, --2
				[HITGROUP_STOMACH] = ACT_FLINCH_STOMACH, --3
				[HITGROUP_LEFTARM] = ACT_FLINCH_STOMACH, --4
				[HITGROUP_RIGHTARM] = ACT_FLINCH_STOMACH --5
				--[HITGROUP_LEFTLEG] = ply:GetSequenceActivity(ply:LookupSequence("flinch_01")), --6
				--[HITGROUP_RIGHTLEG] =  ply:GetSequenceActivity(ply:LookupSequence("flinch_02")) --7
			}
		end
		
		if hitpos[grp] == nil then
			group = ACT_FLINCH_PHYSICS
		else
			group = hitpos[grp]
		end
		
		net.Start( "DoPlayerFlinch" )
			net.WriteInt( group, 32 )
			net.WriteEntity( ply )
		net.Broadcast()
		
	end

end )