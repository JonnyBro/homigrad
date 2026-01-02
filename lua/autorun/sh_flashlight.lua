if engine.ActiveGamemode() ~= "homigrad" then return end

if CLIENT then
	local hg_flashlight_enable = CreateClientConVar("hg_flashlight_enable", "1", true, false)
	local hg_flashlight_distance = CreateClientConVar("hg_flashlight_distance", "4000", true, false)
	local tbl, ply, lply_pos, dis
	local player_GetAll = player.GetAll

	local function create(ply)
		ply.DynamicFlashlight = ProjectedTexture()
		ply.DynamicFlashlight:SetTexture("effects/flashlight001")
		ply.DynamicFlashlight:SetFarZ(900)
		ply.DynamicFlashlight:SetFOV(70)
		ply.DynamicFlashlight:SetEnableShadows(true)
	end

	local function remove(ply)
		if IsValid(ply.DynamicFlashlight) then
			ply.DynamicFlashlight:Remove()
			ply.DynamicFlashlight = nil
		end
	end

	local material = Material("sprites/gmdm_pickups/light")
	local curtime = CurTime()

	hook.Add("Think", "DynamicFlashlight.Rendering", function()
		if curtime > CurTime() then return end

		curtime = curtime + 0.02

		lply_pos = LocalPlayer():GetPos()
		dis = hg_flashlight_distance:GetFloat()
		tbl = player_GetAll()

		for i = 1, #tbl do
			ply = tbl[i]

			if hg_flashlight_enable:GetBool() and ply:GetNWBool("DynamicFlashlight") and ply:GetPos():Distance(lply_pos) <= dis then
				local fake = ply:GetNWEntity("Ragdoll")

				if ply:Alive() then
					local ent = ply:GetNWBool("fake") and IsValid(fake) and fake or ply

					if ply.DynamicFlashlight then
						local bone = ent:LookupBone("ValveBiped.Bip01_L_Hand")
						local pos

						if bone then
							pos = ent:GetBonePosition(bone)
						else
							pos = ply:EyePos()
						end

						ply.DynamicFlashlight:SetPos(pos + ply:EyeAngles():Forward() * 15)
						ply.DynamicFlashlight:SetAngles(ply:EyeAngles())
						ply.DynamicFlashlight:Update()
					else
						create(ply)
					end
				else
					ply:SetNWBool("DynamicFlashlight", false)

					if ply.DynamicFlashlight then
						remove(ply)
					end
				end
			else
				ply:SetNWBool("DynamicFlashlight", false)

				if ply.DynamicFlashlight then
					remove(ply)
				end
			end
		end
	end)

	local vecZero = Vector(0, 0, 0)
	local addPosa = Vector(3, -2, 0)

	hook.Add("PostDrawOpaqueRenderables", "DynamicParticle", function()
		tbl = player_GetAll()

		for i = 1, #tbl do
			ply = tbl[i]
			ply.flashlightMdl = ply.flashlightMdl or ClientsideModel("models/maxofs2d/lamp_flashlight.mdl")

			if IsValid(ply.flashlightMdl) then
				ply.flashlightMdl:SetNoDraw(true)
			end

			if hg_flashlight_enable:GetBool() and ply:GetNWBool("DynamicFlashlight") then
				local fake = ply:GetNWEntity("Ragdoll")

				if ply:Alive() then
					if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "weapon_hands" then continue end
					local plya = IsValid(fake) and fake or ply
					local bone = plya:LookupBone("ValveBiped.Bip01_L_Hand")

					if bone then
						local pos, ang = plya:GetBonePosition(bone)
						local angla = ply:EyeAngles()
						local addpos = vecZero
						addpos:Set(addPosa)
						addpos:Rotate(ang)

						pos:Add(addpos)

						ply.flashlightMdl:SetPos(pos)
						ply.flashlightMdl:SetAngles(angla)
						ply.flashlightMdl:SetNoDraw(false)
						ply.flashlightMdl:SetModelScale(0.3)

						cam.Start3D()
							render.SetMaterial(material)
							render.DrawSprite(pos + angla:Forward() * 5, 32, 32, color_white)
						cam.End3D()
					end
				end
			end
		end
	end)
else
	hook.Add("PlayerSwitchFlashlight", "DynamicFlashlight.Switch", function(ply, state)
		if not ply.allowFlashlight then
			ply:SetNWBool("DynamicFlashlight", false)

			return false
		end

		local bool = ply:GetNWBool("DynamicFlashlight")

		ply:SetNWBool("DynamicFlashlight", not bool)
		ply:EmitSound("items/flashlight1.wav", 60, 100)

		return false
	end)
end