if engine.ActiveGamemode() != "homigrad" then return end

function SpawnWeapon(ply)
	local weapon = ply.ActiveWeapon

	DespawnWeapon(ply)

	if IsValid(weapon) and ishgweapon(weapon) then
		local rag = ply:GetNWEntity("Ragdoll")

		if IsValid(rag) then
			local lh = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand")))
			local rh = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand")))

			if not IsValid(rh) then return end

			local wep = ents.Create("wep")
			ply.wep = wep
			rag.wep = wep

			rag:CallOnRemove("removeRagWeapon",function(ent)
				if wep == ply.wep and IsValid(ply.wep) then
					ply.wep:Remove()
				end
			end)

			wep:SetModel(weapon.WorldModel)

			wep:SetOwner(rag)
			wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)

			local pos, ang = weapon:GetTransform(wep, true)
			wep:SetPos(pos)
			wep:SetAngles(ang)

			wep:Spawn()

			ply:SetNWEntity("ragdollWeapon", wep)

			local phys = wep:GetPhysicsObject()

			if IsValid(phys) then
				phys:SetMass(weapon:IsPistolHoldType() and 1 or 1)
			end

			if IsValid(ply.WepCons) then ply.WepCons:Remove() ply.WepCons = nil end

			local cons = constraint.Weld(wep,rag,0,rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )),0,true)
			--rh:EnableMotion(false)

			if IsValid(cons) then
				ply.WepCons=cons
			end

			if not (weapon.IsPistolHoldType and weapon:IsPistolHoldType()) then
				if IsValid(lh) then
					local rhang = rh:GetAngles()
					lh:SetPos(rh:GetPos() + rhang:Forward() * 4 + rhang:Up() * -3 + rhang:Right() * 2)
					rhang:RotateAroundAxis(rhang:Forward(),180)
					lh:SetAngles(rhang)

					if IsValid(ply.WepCons2) then ply.WepCons2:Remove() ply.WepCons2 = nil end

					local cons2 = constraint.Weld(wep,rag,0,rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )),0,true)
					if IsValid(cons2) then
						ply.WepCons2 = cons2
					end
				end
			end

		end
	end
end

function DespawnWeapon(ply)
	ply:SetNWEntity("ragdollWeapon", NULL)
	if IsValid(ply.wep) then
		ply.wep:Remove()
		ply.wep = nil
	end
end

hook.Add("Player Think","shooting",function(ply)
	if not ply:Alive() or ply.unconscious then return end
	if not IsValid(ply.FakeRagdoll) or not IsValid(ply.wep) then return end

	local wep = ply.ActiveWeapon
	if not IsValid(wep) then return end

	if wep.Primary.Automatic and ply:KeyDown(IN_ATTACK) or ply:KeyPressed(IN_ATTACK) then
		wep:PrimaryAttack()
	end

	if ply:KeyPressed(IN_RELOAD) then
		wep:Reload()
	end
end)