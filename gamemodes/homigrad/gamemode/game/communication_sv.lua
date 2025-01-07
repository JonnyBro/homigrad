local function logic(output, input, isChat, teamonly)
	if roundActive then
		-- Restrict voice to nearby players at round start
		local timeSinceRoundStart = CurTime() - roundTimeStart

		if timeSinceRoundStart < 7 then
			-- Allow only nearby players to hear each other within the specified distance
			if input:GetPos():DistToSqr(output:GetPos()) < 800000 then -- Distance squared for performance
				return true, true -- Allow 3D voice
			else
				return false, false -- Block communication if not nearby
			end
		end

		local result, is3D = hook.Run("Player Can Lisen", output, input, isChat, teamonly)
		if result ~= nil then return result, is3D end

		if output:Alive() and input:Alive() and not output.unconscious and not input.unconscious then
			if input:GetPos():DistToSqr(output:GetPos()) < 800000 and not teamonly then
				return true, true
			else
				-- Uncomment and adjust if additional logic is needed for team-only communication
				-- if teamonly then
				-- 	if roundActiveName == "homicide" then
				-- 		return false
				-- 	else
				-- 		return true
				-- 	end
				-- else
				-- 	return false
				-- end
			end
		elseif not output:Alive() and not input:Alive() then
			return true
		else
			if not input:Alive() and output:Alive() then return true, true end
			if not output:Alive() and input:Team() == 1002 and input:Alive() then return true end

			return false
		end
	else
		return true, false
	end
end

function GM:PlayerCanSeePlayersChat(text, teamonly, input, output)
	if not IsValid(output) then return end

	return logic(output, input, true, teamonly)
end

function GM:PlayerCanHearPlayersVoice(input, output)
	local result, is3D = logic(output, input, false, false)
	local speak = output:IsSpeaking()
	output.IsSpeak = speak

	if output.IsOldSpeak ~= speak then
		output.IsOldSpeak = speak

		if speak then
			hook.Run("Player Start Voice", output)
		else
			hook.Run("Player End Voice", output)
		end
	end

	return result, is3D
end