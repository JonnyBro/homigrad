AddCSLuaFile()
SmartInteraction = {}

if CLIENT then
	function SmartInteraction:GetCrosshairTrace()
		local ply = LocalPlayer()
		local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
		if not eye then return nil end

		local trace = {}
			trace.start = eye.Pos
			trace.start[3] = trace.start[3] - 2
			trace.endpos = trace.start + ply:GetAngles():Forward() * 60
			trace.filter = ply
		local tr = util.TraceLine(trace)

		return tr
	end

	-- Функция для обновления состояния подсказки
	function SmartInteraction:UpdateHint()
		local tr = self:GetCrosshairTrace()

		if tr and tr.Hit then
			local entity = tr.Entity
			local class = entity:GetClass()
			local keyUse = string.upper(input.LookupBinding("+use"))
			local hintText = string.upper(language.GetPhrase("smart_interaction.hint.press"))

			if entity:IsWeapon() or string.StartWith(class, "item") or entity:IsVehicle() or SmartInteraction.HintExtraEntities[class] then
				if entity:IsWeapon() or string.StartWith(class, "item") then
					self.HintString = hintText .. " " .. keyUse .. " " .. string.upper(language.GetPhrase("smart_interaction.hint.pick"))
				elseif entity:IsVehicle() then
					self.HintString = hintText .. " " .. keyUse .. " " .. string.upper(language.GetPhrase("smart_interaction.hint.enter"))
				elseif SmartInteraction.HintExtraEntities[class] then
					self.HintString = hintText .. " " .. keyUse .. " " .. SmartInteraction.HintExtraEntities[class]
				end

				self.HintVisiblity = true
			else
				self.HintVisiblity = false
			end
		else
			self.HintVisiblity = false
		end
	end

	CreateClientConVar("cl_use_hint_background_color", "20 20 20 100", true, true, "color of hint background in RGBA format.")
	CreateClientConVar("cl_use_hint_color", "255 255 255", true, true, "color of hint text && halo in RGB format.")

	SmartInteraction.HintDistance = 120
	SmartInteraction.HintVisiblity = false
	SmartInteraction.HintString = ""
	SmartInteraction.HintAnimationSpeed = 15
	SmartInteraction.HintAlpha = 0
	SmartInteraction.HintBackgroundAlpha = 0
	SmartInteraction.HintWidth = 0

	SmartInteraction.HintExtraEntities = {
		["prop_door_rotating"] = string.upper(language.GetPhrase("smart_interaction.hint.open")),
		["func_door_rotating"] = string.upper(language.GetPhrase("smart_interaction.hint.open")),
		["func_door"] = string.upper(language.GetPhrase("smart_interaction.hint.open")),
		["gmod_button"] = string.upper(language.GetPhrase("smart_interaction.hint.push"))
	}

	hook.Add("PreDrawHalos", "SmartInteraction_PreDrawHalos", function()
		local ply = LocalPlayer()
		local trace = ply:GetEyeTrace()

		if trace.Entity and IsValid(trace.Entity) and not ply:InVehicle() and ply:GetPos():DistToSqr(trace.Entity:GetPos()) <= SmartInteraction.HintDistance * SmartInteraction.HintDistance then
			local entity = trace.Entity
			local class = entity:GetClass()
			local useKey = string.upper(input.LookupBinding("+use"))
			local hintPrefix = string.upper(language.GetPhrase("smart_interaction.hint.press"))

			if entity:IsWeapon() or string.StartWith(class, "item") or entity:IsVehicle() or SmartInteraction.HintExtraEntities[class] then
				if entity:IsWeapon() or string.StartWith(class, "item") then
					SmartInteraction.HintString = hintPrefix .. " " .. useKey .. " " .. string.upper(language.GetPhrase("smart_interaction.hint.pick"))
				elseif entity:IsVehicle() then
					SmartInteraction.HintString = hintPrefix .. " " .. useKey .. " " .. string.upper(language.GetPhrase("smart_interaction.hint.enter"))
				elseif SmartInteraction.HintExtraEntities[class] then
					SmartInteraction.HintString = hintPrefix .. " " .. useKey .. " " .. SmartInteraction.HintExtraEntities[class]
				end

				halo.Add({entity}, SmartInteraction:ParseRGBConVar("cl_use_hint_color", 255), 5, 5, 3)

				SmartInteraction.HintVisiblity = true
			else
				SmartInteraction.HintVisiblity = false
			end
		else
			SmartInteraction.HintVisiblity = false
		end
	end)

	function SmartInteraction:ParseRGBConVar(convarName, defaultAlpha)
		local values = string.Split(GetConVar(convarName):GetString() or "0 0 0 0", " ")

		return Color(tonumber(values[1]) or 0, tonumber(values[2]) or 0, tonumber(values[3]) or 0, defaultAlpha or tonumber(values[4]) or 0)
	end

	hook.Add("HUDPaint", "SmartInteraction_HUDPaint", function()
		SmartInteraction:UpdateHint()

		if SmartInteraction.HintWidth > 1 then
			local j, k = ScrW() / 2, ScrH() / 2

			draw.RoundedBox(6, j - SmartInteraction.HintWidth / 2, k + 225, SmartInteraction.HintWidth, 45, SmartInteraction:ParseRGBConVar("cl_use_hint_background_color", SmartInteraction.HintBackgroundAlpha))
			draw.SimpleText(SmartInteraction.HintString, "GModNotify", j, k + 237, SmartInteraction:ParseRGBConVar("cl_use_hint_color", SmartInteraction.HintAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		if SmartInteraction.HintVisiblity then
			SmartInteraction.HintWidth = Lerp(math.min(FrameTime() * SmartInteraction.HintAnimationSpeed, 1), SmartInteraction.HintWidth, 325)

			if SmartInteraction.HintWidth > 300 then
				SmartInteraction.HintAlpha = Lerp(math.min(FrameTime() * SmartInteraction.HintAnimationSpeed, 1), SmartInteraction.HintAlpha, 255)
			end

			SmartInteraction.HintBackgroundAlpha = Lerp(math.min(FrameTime() * SmartInteraction.HintAnimationSpeed, 1), SmartInteraction.HintBackgroundAlpha, SmartInteraction:ParseRGBConVar("cl_use_hint_background_color").a)
		else
			SmartInteraction.HintWidth = Lerp(math.min(FrameTime() * SmartInteraction.HintAnimationSpeed, 1), SmartInteraction.HintWidth, 0)
			SmartInteraction.HintAlpha = Lerp(math.min(FrameTime() * SmartInteraction.HintAnimationSpeed * 5, 1), SmartInteraction.HintAlpha, 0)
			SmartInteraction.HintBackgroundAlpha = Lerp(math.min(FrameTime() * SmartInteraction.HintAnimationSpeed, 1), SmartInteraction.HintBackgroundAlpha, 0)
		end
	end)
end