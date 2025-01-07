util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("ply_take_ammo")

local function send(ply,lootEnt,remove)
	if ply then
		net.Start("inventory")
		net.WriteEntity(not remove and lootEnt or nil)
		net.WriteTable(lootEnt.Info.Weapons)
		net.WriteTable(lootEnt.Info.Ammo)
		net.Send(ply)
	else
		if lootEnt.UsersInventory and istable(lootEnt.UsersInventory) then
			for ply in pairs(lootEnt.UsersInventory) do
				if not IsValid(ply) or not ply:Alive() or remove then lootEnt.UsersInventory[ply] = nil end

				send(ply,lootEnt,remove)
			end
		end
	end
end

hg.send = send

hook.Add("PlayerSpawn","hg_syncinventories",function(lootEnt)
	if lootEnt.UsersInventory ~= nil then
		for plys,bool in pairs(lootEnt.UsersInventory) do
			lootEnt.UsersInventory[plys] = nil
			send(plys,lootEnt,true)
		end
	end
end)

hook.Add("Player Think","Looting",function(ply)
	local key = ply:KeyDown(IN_USE)

	if not IsValid(ply.FakeRagdoll) and ply:Alive() and ply:KeyDown(IN_ATTACK2) then
		if ply.okeloot ~= key and key then
			local tr = {}
			tr.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
			tr.endpos = tr.start + ply:EyeAngles():Forward() * 64
			tr.filter = ply
			local tracea = util.TraceLine(tr)
			local hitEnt = tracea.Entity

			if not IsValid(hitEnt) then return end

			if IsValid(RagdollOwner(hitEnt)) then
				hitEnt = RagdollOwner(hitEnt)
				ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 7) .. ".wav", 50, math.random(95, 105))
			end

			if IsValid(hitEnt) and hitEnt.IsJModArmor then hitEnt = hitEnt.Owner end
			if not IsValid(hitEnt) then return end
			if hitEnt:IsPlayer() and hitEnt:Alive() and not IsValid(hitEnt.FakeRagdoll) then return end
			SavePlyInfo(hitEnt)
			if not hitEnt.Info then return end

			hitEnt.UsersInventory = hitEnt.UsersInventory or {}
			hitEnt.UsersInventory[ply] = true

			send(ply,hitEnt)
			hitEnt:CallOnRemove("fuckoff",function() send(nil,hitEnt,true) end)
		end
	end

	ply.okeloot = key
end)

local prekol = {
	weapon_physgun = true,
	gmod_tool = true
}

hook.Add("DoPlayerDeath","huyhuy",function(ply)
	local info = SavePlyInfo(ply)

	ply.weps = {}

	local actwep = ply:GetActiveWeapon()

	actwep = IsValid(actwep) and actwep:GetClass() or IsValid(ply.ActiveWeapon) and ply.ActiveWeapon:GetClass()
	for class, wep in pairs(info.Weapons) do
		local tbl = wep:GetTable()

		local ent = ents.Create(class)
		ent:SetPos(ply:GetPos() + vector_up * 10)

		local clip1 = wep:Clip1()
		timer.Simple(0,function()
			local rag = ply:GetNWEntity("Ragdoll",ply.FakeRagdoll)
			rag = IsValid(rag) and rag or ply.FakeRagdoll
			if not IsValid(rag) then return end
			if not IsValid(ent) then return end
			ent:SetClip1(clip1)
			ent:SetTable(tbl)
			--ent:SetOwner(rag)
			ent:SetParent(rag, 0)
			--ent:SetSubMaterial(-1,"null")
			ent:SetMaterial("null")
			ent.Spawned = true
			--timer.Simple(0,function() ent:SetRenderMode(RENDERMODE_NONE) end)
		end)

		ent:Spawn()
		ent:SetMaterial("null")
		ent.Spawned = true
		--ent:SetRenderMode(RENDERMODE_NONE)
		--ent:SetMaterial("")
		--ent:SetNoDraw(true)
		ent:DrawShadow(false)
		ent:AddSolidFlags(FSOLID_NOT_SOLID)

		if IsValid(wep) then wep:Remove() end
		ply.weps[class] = ent
	end

	timer.Simple(0.1,function()
		local rag = ply:GetNWEntity("Ragdoll",ply.FakeRagdoll)
		rag = IsValid(rag) and rag or ply.FakeRagdoll
		if IsValid(rag) then
			rag.Info = rag.Info or {}
			if ply.weps then
				rag.Info.Weapons = ply.weps
				rag.ActiveWeapon = ply.weps[actwep]
			end
			ply.weps = nil
		end
	end)
end)

local trollmsgs = {
	"You have been kicked. Error Code: AT6001",
	"You have been banned for exploits.",
	"Shouldn't of taken that...",
	"Off you go!",
}

net.Receive("ply_take_item",function(len,ply)
	local lootEnt = net.ReadEntity()
	if not ply:Alive() or ply.unconscious then return end
	if not IsValid(lootEnt) then return end
	if lootEnt:IsPlayer() and not IsValid(lootEnt.FakeRagdoll) then return end
	if ply:GetAttachment(ply:LookupAttachment("eyes")).Pos:Distance(lootEnt:GetPos()) > 100 then return end

	local lootInfo = lootEnt.Info

	local wep = net.ReadString()
	local weapon = lootInfo.Weapons[wep]

	if not IsValid(weapon) then return end

	if prekol[wep] and not ply:IsAdmin() then ply:Kick(trollmsgs[math.random(#trollmsgs)]) return end

	if ply:HasWeapon(wep) then
		if lootEnt:IsPlayer() and (lootEnt.ActiveWeapon == weapon and not lootEnt.unconscious) then return end
		if weapon:Clip1() > 0 then
			ply:GiveAmmo(weapon:Clip1(),weapon:GetPrimaryAmmoType())
			weapon:SetClip1(0)
		else
			ply:ChatPrint("You already have this weapon.")
		end
	else
		if lootEnt:IsPlayer() and (lootEnt.ActiveWeapon == weapon and not lootEnt.unconscious) then return end

		if lootEnt:IsPlayer() then lootEnt:DropWeapon(weapon) end
		ply:PickupWeapon(weapon)

		weapon:SetRenderMode(RENDERMODE_NORMAL)
		weapon:DrawShadow(true)
		--weapon:RemoveSolidFlags(FSOLID_NOT_SOLID)
		weapon:SetMaterial("")

		lootInfo.Weapons[wep] = nil

		if lootEnt.ActiveWeapon == weapon then
			DespawnWeapon(lootEnt)
		end
	end

	send(nil,lootEnt)
end)

net.Receive("ply_take_ammo",function(len,ply)
	--if ply:Team() ~= 1002 then return end

	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end
	if lootEnt:IsPlayer() and not IsValid(lootEnt.FakeRagdoll) then return end
	local ammo = net.ReadFloat()
	local lootInfo = lootEnt.Info
	if not lootInfo.Ammo[ammo] then return end

	ply:GiveAmmo(lootInfo.Ammo[ammo],ammo)

	if lootEnt:IsPlayer() then
		lootEnt:SetAmmo(0,ammo)
	end

	lootInfo.Ammo[ammo] = nil

	send(nil,lootEnt)
end)