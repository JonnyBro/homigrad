if engine.ActiveGamemode() ~= "homigrad" then return end

local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function SavePlyInfo(ply)
	if not ply:IsPlayer() and not ply:IsRagdoll() then return end
    ply.Info = ply.Info or {}

    local info = ply.Info
	local wep = ply.GetActiveWeapon and ply:GetActiveWeapon()

    info.Ammo = ply.GetAmmo and ply:GetAmmo() or info.Ammo or {}
    ply.ActiveWeapon = IsValid(wep) and wep:GetClass() or ply.ActiveWeapon or false
	info.Weapons = info.Weapons or {}

	if ply.GetWeapons then
		info.Weapons = {}

		for i,wep in pairs(ply:GetWeapons())do
			info.Weapons[wep:GetClass()] = wep
		end
	end

	return info
end

util.AddNetworkString("Override Spawn")
function hg.OverrideSpawn(ply)
	net.Start("Override Spawn")
	net.WriteEntity(ply)
	net.Broadcast()
end

function Faking(ply,force)
	if not ply:Alive() then return end

	if not IsValid(ply.FakeRagdoll) then
		if hook.Run("Fake",ply) ~= nil then return end

		ply:SetNWBool("fake",IsValid(ply.FakeRagdoll))

		ply:DrawViewModel(false)
		ply:DrawWorldModel(false)

		local veh
		if ply:InVehicle() then
			veh = ply:GetVehicle()
			ply:ExitVehicle()
		end

		local dmgInfo = nil
		local attacker = nil
		if ply.LastDMGInfo and ply.LastTimeAttacked and (ply.LastTimeAttacked + 1) > CurTime() then
			dmgInfo = ply.LastDMGInfo
			attacker = dmgInfo:GetAttacker()
		end

		local rag = ply:CreateRagdoll(attacker,dmgInfo,force)

		if IsValid(veh) then
			rag:GetPhysicsObject():SetVelocity(veh:GetPhysicsObject():GetVelocity() * 5)
		end

		if IsValid(rag) then
			ply.FakeRagdoll = rag--ply:GetNWEntity("Ragdoll")

			local wep = ply:GetActiveWeapon()

			if IsValid(wep) and ishgweapon(wep) then
				ply.ActiveWeapon = wep
				SpawnWeapon(ply)
				--[[timer.Simple(0.1,function()
					SpawnWeapon(ply)
				end)
				timer.Simple(0.5,function()
					SpawnWeapon(ply)
				end)--]]
			end

			rag.bull = ents.Create("npc_bullseye")
			rag:SetNWEntity("RagdollController", ply)

			local bull = rag.bull

			local eyeatt = rag:GetAttachment(rag:LookupAttachment("eyes"))
			local bodyphy = rag:GetPhysicsObjectNum(10)
			bull:SetPos(eyeatt.Pos)
			--bull:SetPos( eyeatt.Pos + eyeatt.Ang:Up() * 3.5 )
			bull:SetAngles( rag:GetAngles() )
			bull:SetMoveType(MOVETYPE_OBSERVER)
			bull:SetKeyValue( "targetname", "Bullseye" )
			--bull:SetParent(rag, rag:LookupAttachment("eyes"))
			bull:SetKeyValue( "health","9999" )
			bull:SetKeyValue( "spawnflags","256" )
			bull:Spawn()
			bull:Activate()
			bull:SetNotSolid(true)

			for i, ent in ipairs(ents.FindByClass("npc_*")) do
				if not IsValid(ent) or not ent.AddEntityRelationship then continue end
				ent:AddEntityRelationship(bull, ent:Disposition(ply))
			end
			rag:AddFlags(FL_NOTARGET)
			bull.rag = rag
			bull.ply = ply

			hook.Run("Fake", ply, rag)

			FakeBullseyeTrigger(rag, ply)

			if ply.LastDMGInfo then
				local phys = rag:GetPhysicsObject()
				if IsValid(phys) then
					phys:ApplyForceCenter(ply.LastDMGInfo:GetDamageForce())
				end
			end

			ply:SetMoveType(MOVETYPE_NONE)
			ply:DrawShadow(false)
			local hull = Vector(0,0,0)
			ply:SetHull(-hull,hull)
			ply:SetHullDuck(-hull,hull)
			ply:SetViewOffset(Vector(0,0,0))
			ply:SetViewOffsetDucked(Vector(0,0,0))
			ply:SetRenderMode(RENDERMODE_NONE)

			ply:SetSolidFlags(bit.bor(ply:GetSolidFlags(),FSOLID_NOT_SOLID))

			ply:SetActiveWeapon(nil)
			ply:DropObject()

			timer.Create("faketimer"..ply:EntIndex(), 2, 1, function() end)
		end
	else
		local rag = ply:GetNWEntity("Ragdoll")
		DespawnWeapon(ply)
		if IsValid(rag) then
			if IsValid(rag.bull) then
				rag.bull:Remove()
			end

			ply.GotUp = CurTime()

			if hook.Run("Fake Up",ply,rag) ~= nil then return end

			ply:SetNWBool("fake",IsValid(ply.FakeRagdoll))

			ply.FakeRagdoll = nil

			local pos=rag:GetPos()
			local vel=rag:GetVelocity()

			PLYSPAWN_OVERRIDE = true

			hg.OverrideSpawn(ply)

			local eyepos = ply:EyeAngles()
			local health = ply:Health()

			JMod.Иди_Нахуй = true
			ply:Spawn()
			JMod.Иди_Нахуй = nil

			ply:DrawShadow(true)
			ply:SetRenderMode(RENDERMODE_NORMAL)

			ply:SetHealth(health)
			ply:SetVelocity(vel)
			ply:SetEyeAngles(eyepos)
			if IsValid(ply.ActiveWeapon) then
				ply:SetActiveWeapon(ply.ActiveWeapon)
			else
				ply:SetActiveWeapon(ply:GetWeapon("weapon_hands"))
			end

			PLYSPAWN_OVERRIDE = nil

			local trace = {start = pos,endpos = pos - Vector(0,0,64),filter = {ply,rag}}
			local tracea = util.TraceLine(trace)
			if tracea.Hit then
				--ply:ChatPrint(tostring(tracea.Fraction).." 1")
				pos:Add(Vector(0,0,64) * (tracea.Fraction))
			end

			local trace = {start = pos,endpos = pos + Vector(0,0,64),filter = {ply,rag}}
			local tracea = util.TraceLine(trace)

			if tracea.Hit then
				pos:Add(-Vector(0,0,64) * (1 - tracea.Fraction))
			end

			ply:SetPos(pos)

			ply:DrawViewModel(true)
			ply:DrawWorldModel(true)

			ply:SetModel(rag:GetModel())
			rag.unfaked = true
			rag:Remove()
			ply:SetNWEntity("Ragdoll",NULL)
		end
	end
end

hook.Add("CanExitVehicle","fakefastcar",function(veh,ply)
    --if veh:GetPhysicsObject():GetVelocity():Length() > 100 then Faking(ply) return false end
end)

function FakeBullseyeTrigger(rag,owner)
	if not IsValid(rag.bull) then return end
	--[[for i,ent in pairs(ents.GetAll())do
		if(ent:IsNPC() and ent:Disposition(owner)==D_HT)then
			ent:AddEntityRelationship(rag.bull,D_HT,0)
		end
	end--]]
end

hook.Add("OnEntityCreated","hg-bullseye",function(ent)
	ent:SetShouldPlayPickupSound(false)
	if ent:IsNPC() then
		for i,rag in pairs(ents.FindByClass("prop_ragdoll"))do
			if IsValid(rag.bull) then
				ent:AddEntityRelationship(rag.bull,D_HT,0)
			end
		end
	end
	timer.Simple(0,function()
		if not IsValid(ent) then return end

		local pos,ang = ent:GetPos(),ent:GetAngles()
		local exchangeEnt = changeClass[ent:GetClass()]
		if exchangeEnt then
			local entr = type(exchangeEnt) == "table" and table.Random(exchangeEnt) or exchangeEnt
			local ent2 = ents.Create(entr)

			if not IsValid(ent2) then return end

			ent2:SetPos(pos)
			ent2:SetAngles(ang)
			ent2:Spawn()

			ent:Remove()
		end
	end)
end)

hook.Add("Think","FakedShoot",function() --функция стрельбы лежа

end)

hook.Add("PlayerSay","huyasds",function(ply,text)
	if ply:IsAdmin() and string.lower(text)=="1" then
		local ent = ply:GetEyeTrace().Entity
		if ent:IsPlayer() then
			ply:ChatPrint(ent:Nick(),ent:EntIndex())
			--[[PrintMessage(HUD_PRINTTALK,tostring(ply:Name()).." связал "..tostring(ent:Name()))
			ent:StripWeapons()
			ent:Give("weapon_hands")
			Faking(ent)
			timer.Simple(0,function()
				local enta = ent:GetNWEntity("Ragdoll")
				enta:GetPhysicsObjectNum(5):SetPos(enta:GetPhysicsObjectNum(7):GetPos())
				for i=1,3 do
					constraint.Rope(enta,enta,5,7,Vector(0,0,0),Vector(0,0,0),-2,2,0,4,"cable/rope.vmt",false,Color(255,255,255))
				end
			end)
			--ent.Hostage = true--]]
		elseif ent:IsRagdoll() then
			ply:ChatPrint(IsValid(RagdollOwner(ent)) and RagdollOwner(ent):Name())
			--[[--ent:StripWeapons()
			--ent:Give("weapon_hands")
			--Faking(ent)
			timer.Simple(0,function()
				local enta = ent
				enta:GetPhysicsObjectNum(5):SetPos(enta:GetPhysicsObjectNum(7):GetPos())
				for i=1,3 do
					constraint.Rope(enta,enta,5,7,Vector(0,0,0),Vector(0,0,0),-2,2,0,4,"cable/rope.vmt",false,Color(255,255,255))
				end
			end)--]]
		end
		return ""
	end
end)

function RagdollOwner(rag)
	if not IsValid(rag) then return end

	local ent = rag:GetNWEntity("RagdollController")
	return IsValid(ent) and ent
end

function PlayerMeta:DropWeapon1(wep)
    local ply = self
	wep = wep or ply:GetActiveWeapon()
	wep = IsValid(wep) and wep or ply.ActiveWeapon
    if !IsValid(wep) then return end

	if wep:GetClass() == "weapon_hands" then return end

	if ply.SlotBig == wep then ply.SlotBig = nil end
	if ply.SlotSmall == wep then ply.SlotSmall = nil end

	ply:DropWeapon(wep)
	--wep:SetPos(ply:EyePos())
	--wep:SetAngles(ply:GetAngles())
	wep.Spawned = true
	if ply.ActiveWeapon == wep and IsValid(ply.wep) then
		wep:SetPos(ply.wep:GetPos())
		wep:SetAngles(ply.wep:GetAngles())
		DespawnWeapon(ply.wep)
	end
	ply:SelectWeapon("weapon_hands")
end

function PlayerMeta:PickupEnt()
	local ply = self
	local rag = ply:GetNWEntity("Ragdoll")
	local phys = rag:GetPhysicsObjectNum(7)
	local offset = phys:GetAngles():Right()*5
	local traceinfo={
	start=phys:GetPos(),
	endpos=phys:GetPos()+offset,
	filter=rag,
	output=trace,
	}
	local trace = util.TraceLine(traceinfo)
	if trace.Entity == Entity(0) or trace.Entity == NULL or !trace.Entity.canpickup then return end
end

util.AddNetworkString("send_deadbodies")
hook.Add("DoPlayerDeath","blad",function(ply,att,dmginfo)
	local rag = ply:GetNWEntity("Ragdoll")

	if not IsValid(rag) then
		rag = ply:CreateRagdoll(att,dmginfo)
		ply:SetNWEntity("Ragdoll",rag)
	end

	rag:SetEyeTarget(Vector(0,0,0))

	local phys = rag:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass(30)
	end

	if IsValid(rag.bull) then rag.bull:Remove() end

	rag:SetNWEntity("RagdollController",Entity(-1))

	rag.Info = ply.Info

	if(IsValid(rag.ZacConsLH))then
		rag.ZacConsLH:Remove()
		rag.ZacConsLH=nil
	end

	if(IsValid(rag.ZacConsRH))then
		rag.ZacConsRH:Remove()
		rag.ZacConsRH=nil
	end

	local ent = ply:GetNWEntity("Ragdoll")
	if IsValid(ent) then ent:SetNWEntity("RagdollOwner",nil) end

	ply:SetDSP(0)
	ply.FakeRagdoll = nil
end)

hook.Add("PostPlayerDeath","fuckyou",function(ply)

end)

hook.Add("PhysgunDrop", "DropPlayer", function(ply,ent)
	ent.isheld=false
end)

hook.Add("PlayerDisconnected","saveplyinfo",function(ply)
	if ply:Alive() then
		ply:Kill()
	end
end)

hook.Add("PhysgunPickup", "DropPlayer2", function(ply,ent)
		--if ply:GetUserGroup()=="servermanager" or ply:GetUserGroup()=="superadmin" or ply:GetUserGroup()=="owner" or ply:GetUserGroup()=="admin" or ply:GetUserGroup()=="operator" then
	if GetConVar("sv_construct"):GetBool() == true then
		if ent:IsPlayer() and !IsValid(ent.FakeRagdoll) or ent:IsRagdoll() then return false else return true end
	else
		if ent:IsPlayer() and !IsValid(ent.FakeRagdoll) then
			if hook.Run("Should Fake Physgun",ply,ent) ~= nil then return false end

			ent.isheld=true

			Faking(ent)
			return false
		end
	end
end)

hook.Add("PlayerSpawn","!!!!!!!!!!!!",function(ply)
	if PLYSPAWN_OVERRIDE then return true end
end)

hook.Add("PlayerSpawn","zzzzzzzzzzzz",function(ply)
	if PLYSPAWN_OVERRIDE then return true end
end)

hook.Add("PlayerSpawn","!",function(ply)
	if PLYSPAWN_OVERRIDE then return true end
end)

hook.Add("PlayerSpawn","z",function(ply)
	if PLYSPAWN_OVERRIDE then return true end
end)

hook.Add("PlayerSpawn","resetfakebody",function(ply) --обнуление регдолла после вставания
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)

	ply:SetDuckSpeed(0.3)
	ply:SetUnDuckSpeed(0.3)

	ply.slots = {}
	if ply.UsersInventory ~= nil then
		for plys,bool in pairs(ply.UsersInventory) do
			ply.UsersInventory[plys] = nil
			send(plys,lootEnt,true)
		end
	end

	ply:SetNWEntity("Ragdoll",NULL)
end)

util.AddNetworkString("Unload")
net.Receive("Unload",function(len,ply)
	local wep = net.ReadEntity()
	if not IsValid(wep) then return end
	if wep:GetOwner() ~= ply then return end
	local oldclip = wep:Clip1()
	local ammo = wep:GetPrimaryAmmoType()
	wep:EmitSound("snd_jack_hmcd_ammotake.wav")
	wep:SetClip1(0)
	ply:GiveAmmo(oldclip,ammo)
end)

function Stun(Entity)
	if Entity:IsPlayer() then
		if not IsValid(Entity.FakeRagdoll) then Faking(Entity) end
		timer.Create("StunTime"..Entity:EntIndex(), 8, 1, function() end)
		local fake = Entity:GetNWEntity("Ragdoll")
		timer.Create( "StunEffect"..Entity:EntIndex(), 0.1, 80, function()
			local rand = math.random(1,50)
			if rand == 50 then
			RagdollOwner(fake):Say("*drop")
			end
			RagdollOwner(fake).pain = RagdollOwner(fake).pain + 3
			fake:GetPhysicsObjectNum(1):SetVelocity(fake:GetPhysicsObjectNum(1):GetVelocity()+Vector(math.random(-55,55),math.random(-55,55),0))
			fake:EmitSound("ambient/energy/spark2.wav")
		end)
	elseif Entity:IsRagdoll() then
		if RagdollOwner(Entity) then
			RagdollOwner(Entity):Say("*drop")
			timer.Create("StunTime"..RagdollOwner(Entity):EntIndex(), 8, 1, function() end)
			local fake = Entity
			timer.Create( "StunEffect"..RagdollOwner(Entity):EntIndex(), 0.1, 80, function()
				if rand == 50 then
					RagdollOwner(fake):Say("*drop")
				end
				RagdollOwner(fake).pain = RagdollOwner(fake).pain + 3
				fake:GetPhysicsObjectNum(1):SetVelocity(fake:GetPhysicsObjectNum(1):GetVelocity()+Vector(math.random(-55,55),math.random(-55,55),0))
				fake:EmitSound("ambient/energy/spark2.wav")
			end)
		else
			local fake = Entity
			timer.Create( "StunEffect"..Entity:EntIndex(), 0.1, 80, function()
				fake:GetPhysicsObjectNum(1):SetVelocity(fake:GetPhysicsObjectNum(1):GetVelocity()+Vector(math.random(-55,55),math.random(-55,55),0))
				fake:EmitSound("ambient/energy/spark2.wav")
			end)
		end
	end
end


concommand.Add("fake",function(ply)
	if timer.Exists("faketimer"..ply:EntIndex()) then return nil end
	if timer.Exists("StunTime"..ply:EntIndex()) then return nil end
	if ply:GetNWEntity("Ragdoll").isheld==true then return nil end
	if ply.Seizure then return end

	if ply.brokenspine then return nil end
	if IsValid(ply:GetNWEntity("Ragdoll")) and ply:GetNWEntity("Ragdoll"):GetVelocity():Length()>300 then return nil end
	if IsValid(ply:GetNWEntity("Ragdoll")) and table.Count(constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Rope' ))>0 then return nil end

	--if IsValid(ply:GetNWEntity("Ragdoll")) and table.Count(constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Weld' ))>0 then return nil end

	if ply.pain>(250*(ply.Blood/5000))+(ply:GetNWInt("SharpenAMT")*5) or ply.Blood<3000 then return end

	timer.Create("faketimer"..ply:EntIndex(), 2, 1, function() end)

	if ply:Alive() then
		Faking(ply)
		ply.FakeRagdoll=ply:GetNWEntity("Ragdoll")
	end
end)

hook.Add("PreCleanupMap","cleannoobs",function() --все игроки встают после очистки карты
	for i, v in player.Iterator() do
		if IsValid(v.FakeRagdoll) then Faking(v) end
	end

	BleedingEntities = {}
end)

util.AddNetworkString("nodraw_helmet")

local function CreateArmor(ragdoll,info)
	local item = JMod.ArmorTable[info.name]
	if not item then return end

	local Index = ragdoll:LookupBone(item.bon)
	if not Index then return end

	local Pos,Ang = (ply or ragdoll):GetBonePosition(Index)
	if not Pos then return end

	local ent = ents.Create(item.ent)

	local Right,Forward,Up = Ang:Right(),Ang:Forward(),Ang:Up()
	Pos = Pos + Right * item.pos.x + Forward * item.pos.y + Up * item.pos.z

	Ang:RotateAroundAxis(Right,item.ang.p)
	Ang:RotateAroundAxis(Up,item.ang.y)
	Ang:RotateAroundAxis(Forward,item.ang.r)

	ent.IsArmor = true
	ent:SetPos(Pos)
	ent:SetAngles(Ang)

	local color = info.col

	ent:SetColor(Color(color.r,color.g,color.b,color.a))

	ent:Spawn()
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	if IsValid(ent:GetPhysicsObject()) then
		ent:GetPhysicsObject():SetMaterial("plastic")
	end

	timer.Simple(0.1,function()
		local ply = RagdollOwner(ragdoll)
		if item.bon == "ValveBiped.Bip01_Head1" and ply and IsValid(ply) and  ply:IsPlayer() then
			net.Start("nodraw_helmet")
			net.WriteEntity(ent)
			net.Send(ply)
		end
	end)
	ragdoll.constraints = ragdoll.constraints or {}

	ragdoll.constraints[item.bon] = constraint.Weld(ent,ragdoll,0,ragdoll:TranslateBoneToPhysBone(Index),0,true,false)

	ragdoll:DeleteOnRemove(ent)

	return ent
end

local function Remove(self,ply)
	if self.override then return end

	self.ragdoll.armors[self.armorID] = nil
	JMod.RemoveArmorByID(ply,self.armorID,true)
end

local function RemoveRag(self)
	for id,ent in pairs(self.armors) do
		if not IsValid(ent) then continue end

		ent.override = true
		ent:Remove()
	end
end

local CustomWeight = {
	["models/player/police_fem.mdl"] = 65,
	["models/player/police.mdl"] = 65,
	["models/player/Rusty/NatGuard/male_01.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_02.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_03.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_04.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_05.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_06.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_07.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_08.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_09.mdl"] = 90,
	["models/LeymiRBA/Gyokami/Gyokami.mdl"] = 50,
	["models/player/smoky/Smoky.mdl"] = 65,
	["models/player/smoky/Smokycl.mdl"] = 65,
	["models/knyaje pack/dibil/sso_politepeople.mdl"] = 20,
	["models/xinus22/doot_skelly.mdl"] = 1,
	["models/ats/mgs2snake/mgs2snake.mdl"] = 20
}

for i = 1,6 do
	CustomWeight["models/monolithservers/mpd/female_0"..i..".mdl"] = 20
end

for i = 1,6 do
	CustomWeight["models/monolithservers/mpd/female_0"..i.."_2.mdl"] = 20
end

for i = 1,6 do
	CustomWeight["models/monolithservers/mpd/male_0"..i..".mdl"] = 20
end

for i = 1,6 do
	CustomWeight["models/monolithservers/mpd/male_0"..i.."_2.mdl"] = 20
end


util.AddNetworkString("custom name")

net.Receive("custom name",function(len,ply)
	if not ply:IsAdmin() then return end

	local name = net.ReadString()
	if name == "" then return end

	ply:SetNWString("CustomName",name)
end)

IdealMassPlayer = {
	["ValveBiped.Bip01_Pelvis"] = 12.775918006897,
	["ValveBiped.Bip01_Spine2"] = 24.36336517334,
	["ValveBiped.Bip01_R_UpperArm"] = 3.4941370487213,
	["ValveBiped.Bip01_L_UpperArm"] = 3.441034078598,
	["ValveBiped.Bip01_L_Forearm"] = 1.7655730247498,
	["ValveBiped.Bip01_L_Hand"] = 1.0779889822006,
	["ValveBiped.Bip01_R_Forearm"] = 1.7567429542542,
	["ValveBiped.Bip01_R_Hand"] = 1.0214320421219,
	["ValveBiped.Bip01_R_Thigh"] = 10.212161064148,
	["ValveBiped.Bip01_R_Calf"] = 4.9580898284912,
	["ValveBiped.Bip01_Head1"] = 5.169750213623,
	["ValveBiped.Bip01_L_Thigh"] = 10.213202476501,
	["ValveBiped.Bip01_L_Calf"] = 4.9809679985046,
	["ValveBiped.Bip01_L_Foot"] = 2.3848159313202,
	["ValveBiped.Bip01_R_Foot"] = 2.3848159313202
}

function PlayerMeta:CreateRagdoll(attacker, dmginfo, force)
	local rag = self:GetNWEntity("Ragdoll")
	rag.ExplProof = true

	if IsValid(rag) then
		if(IsValid(rag.ZacConsLH))then
			rag.ZacConsLH:Remove()
			rag.ZacConsLH=nil
		end
		if(IsValid(rag.ZacConsRH))then
			rag.ZacConsRH:Remove()
			rag.ZacConsRH=nil
		end

		rag:Remove()
		rag = nil
		return
	end

	local Data = duplicator.CopyEntTable( self )
	local rag = ents.Create( "prop_ragdoll" )

	duplicator.DoGeneric( rag, Data )

	rag:SetModel(self:GetModel())
	rag:SetNWVector("plycolor",self:GetPlayerColor())
	rag:SetSkin(self:GetSkin())
	rag:Spawn()

	-- rag:CallOnRemove("huyhjuy",function() self.firstrag = false end)
	rag:CallOnRemove("huy2ss",function()
		if not rag.unfaked and RagdollOwner(rag) then
			rag.unfaked = false
			RagdollOwner(rag):KillSilent()
		end
	end)

	rag:AddEFlags(EFL_NO_DAMAGE_FORCES)

	rag:Activate()
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	rag:SetNWEntity("RagdollOwner", self)
	rag:SetNWString("EA_Attachments", self:GetNWString("EA_Attachments", nil))

	local vel = self:GetVelocity() --+ (force or vector_origin) * 10

	local phys_bone = nil

	if dmginfo then
		phys_bone = GetPhysicsBoneDamageInfo(self, dmginfo) or 0
	end

	for physNum = 0, rag:GetPhysicsObjectCount() - 1 do
		local phys = rag:GetPhysicsObjectNum(physNum)
		local bone = rag:TranslatePhysBoneToBone(physNum)
		if bone < 0 then continue end

		local matrix = self:GetBoneMatrix(bone)

		phys:SetMass(CustomWeight[rag:GetModel()] or IdealMassPlayer[rag:GetBoneName(bone)] or 65)
		phys:SetVelocity(vel)

		if phys_bone and phys_bone == physNum then
			phys:ApplyForceOffset(dmginfo:GetDamageForce() * 10, dmginfo:GetDamagePosition())
		end

		phys:SetPos(matrix:GetTranslation())
		phys:SetAngles(matrix:GetAngles())

		if rag:GetBoneName(bone) == "ValveBiped.Bip01_Head1" then
			local _,ang = LocalToWorld(vector_origin,Angle(-80,0,90),vector_origin,self:EyeAngles())
			phys:SetAngles(ang)
		end

		phys:EnableDrag(1)
		phys:SetDragCoefficient( -1000 )
		phys:SetDamping(0,2)

		phys:Wake()
	end

	rag:SetNWString("Nickname",self:GetNWString("CustomName",false) or self:Name())

	local armors = {}

	for id,info in pairs(self.EZarmor.items) do
		local ent = CreateArmor(rag,info)
		ent.armorID = id
		ent.ragdoll = rag
		ent.Owner = self
		armors[id] = ent

		ent:CallOnRemove("Fake",Remove,self)
	end

	if IsValid(self.wep) then
		self.wep.rag = rag
	end

	rag.armors = armors
	rag:CallOnRemove("Armors",RemoveRag)
	self:SetNWEntity("Ragdoll", rag )

	rag:AddCallback("PhysicsCollide", function(phys, data)
		hook.Run("Ragdoll Collide", rag, data)
	end)

	if not self:Alive() then
		local wep = self:GetActiveWeapon()
		if IsValid(wep) and ishgweapon(wep) then
			SpawnWeapon(self)
		end

        rag:SetEyeTarget(Vector(0,0,0))
        rag:SetFlexWeight(9,0)

		if IsValid(rag.bull) then
			rag.bull:Remove()
		end
	end

	return rag
end

hook.Add("JMod Armor Remove","Fake",function(ply,slot,item,drop)
	local fake = ply:GetNWEntity("Ragdoll")
	if not IsValid(fake) then return end

	local ent = fake.armors[slot.id]
	if not IsValid(ent) then return end

	ent:Remove()
end)

hook.Add("JMod Armor Equip","Fake",function(ply,slot,item,drop)
	local fake = ply:GetNWEntity("Ragdoll")
	if not IsValid(fake) then return end

	local ent = CreateArmor(fake,item)
	ent.armorID = slot.id
	ent.Owner = ply
	fake.armors[slot.id] = ent
	ent:CallOnRemove("Fake",Remove,ent,ply)
end,2)--lol4ik

local gg = CreateConVar("hg_oldcollidefake","0")
COMMANDS.oldcollidefake = {function(ply,args)
	GetConVar("hg_oldcollidefake"):SetBool(tonumber(args[1]) > 0)
	PrintMessage(3,"Старая система collide fake - " .. tostring(gg:GetBool()))
end}

hook.Add("Player Collide","homigrad-fake",function(ply,hitEnt,data)
	--if not ply:HasGodMode() and data.Speed >= 250 / hitEnt:GetPhysicsObject():GetMass() * 20 and not IsValid(ply.FakeRagdoll) and not hitEnt:IsPlayerHolding() and hitEnt:GetVelocity():Length() > 80 then
	if
		(gg:GetBool() and not ply:HasGodMode() and data.Speed > 200) or
		(not gg:GetBool() and not ply:HasGodMode() and data.Speed >= 250 / hitEnt:GetPhysicsObject():GetMass() * 20 and not IsValid(ply.FakeRagdoll) and not hitEnt:IsPlayerHolding() and hitEnt:GetVelocity():Length() > 150)
	then
		timer.Simple(0,function()
			if not IsValid(ply) or IsValid(ply.FakeRagdoll) then return end

			if hook.Run("Should Fake Collide",ply,hitEnt,data) == false then return end

			Faking(ply)
		end)
	end
end)

hook.Add("OnPlayerHitGround","GovnoJopa",function(ply,a,b,speed)
	if speed > 200 then
		if hook.Run("Should Fake Ground",ply) ~= nil then return end

		local tr = {}
		tr.start = ply:GetPos()
		tr.endpos = ply:GetPos() - Vector(0,0,10)
		tr.mins = ply:OBBMins()
		tr.maxs = ply:OBBMaxs()
		tr.filter = ply
		local traceResult = util.TraceHull(tr)
		if traceResult.Entity:IsPlayer() and not IsValid(traceResult.Entity.FakeRagdoll) then
			Faking(traceResult.Entity)
		end
	end
end)

deadBodies = deadBodies or {}

hook.Add("Think","VelocityFakeHitPlyCheck",function() --проверка на скорость в фейке (для сбивания с ног других игроков)
	for i,rag in ipairs(ents.FindByClass("prop_ragdoll")) do
		if IsValid(rag) then
			if rag:GetVelocity():Length() > 200 then
				rag:SetCollisionGroup(COLLISION_GROUP_NONE)
			else
				rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end
	end
	for i = 1,#deadBodies do
		local ent = deadBodies[i]
		if not IsValid(ent) or not ent:IsPlayer() or not ent:IsRagdoll() then deadBodies[i] = nil continue end
	end
end)

local CurTime = CurTime
hook.Add("StartCommand","asdfgghh",function(ply,cmd)
	local rag = ply:GetNWEntity("Ragdoll")
	if (ply.GotUp or 0) - CurTime() > -0.1 and not IsValid(rag) then cmd:AddKey(IN_DUCK) end
	if IsValid(rag) then cmd:RemoveKey(IN_DUCK) end
end)

local dvec = Vector(0,0,0)
local HullVec = Vector(4,4,4)

hook.Add("Player Think","FakeControl",function(ply,time) --управление в фейке
	if not ply:Alive() then return end
	local rag = ply:GetNWEntity("Ragdoll")

	if not IsValid(rag) or not ply:Alive() then return end
	local bone = rag:LookupBone("ValveBiped.Bip01_Head1")
	if not bone then return end

	local head1 = rag:GetBonePosition(bone) + dvec

	local torsopos = rag:GetBonePosition(rag:LookupBone("ValveBiped.Bip01_Spine"))

	if IsValid(rag.bull) then
		rag.bull:SetPos(torsopos + vector_up * 10)
	end

	ply:SetPos(head1)

	ply.bullshithuy = ply.bullshithuy or CurTime()
	if (ply.bullshithuy + 1) < CurTime() then
		ply:SetRenderMode(RENDERMODE_NONE)
	end

	local deltatime = SysTime() - (rag.ZacLastCallTime or SysTime())

	rag.ZacLastCallTime = SysTime()

	local eyeangs = ply:EyeAngles()
	local head = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Head1" )) )
	rag:SetFlexWeight(9,0)

	local dist = (rag:GetAttachment(rag:LookupAttachment( "eyes" )).Ang:Forward()*10000):Distance(ply:GetAimVector()*10000)
	local distmod = math.Clamp(1-(dist/20000),0.1,1)
	local lookat = LerpVector(distmod,rag:GetAttachment(rag:LookupAttachment( "eyes" )).Ang:Forward()*100000,ply:GetAimVector()*100000)
	local attachment = rag:GetAttachment( rag:LookupAttachment( "eyes" ) )
	local LocalPos, LocalAng = WorldToLocal( lookat, Angle( 0, 0, 0 ), attachment.Pos, attachment.Ang )

	if !ply.unconscious then rag:SetEyeTarget( LocalPos ) else rag:SetEyeTarget( Vector(0,0,0) ) end

	if ply:Alive() then
		if !ply.unconscious then

			-- Remember to not swim 30 minutes after eating
			if (table.Count(constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Rope' ))>0 or ((rag.IsWeld or 0) > 0)) and ply.firstTimeNotifiedRestrained then
				ply:ChatPrint("You have been restrained. Spam G + Space to break free.")
				ply.firstTimeNotifiedRestrained = false
			end

			if ply:KeyDown( IN_JUMP ) and (table.Count(constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Rope' ))>0 or ((rag.IsWeld or 0) > 0)) and ply.stamina>45 and (ply.lastuntietry or 0) < CurTime() then
				ply.lastuntietry = CurTime() + 2

				rag.IsWeld = math.max((rag.IsWeld or 0) - 0.1,0)

				local RopeCount = table.Count(constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Rope' ))
				Ropes = constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Rope' )
				Try = math.random(1,10*RopeCount)
				ply.stamina=ply.stamina - 5
				local phys = rag:GetPhysicsObjectNum( 1 )
				local speed = 200
				local shadowparams = {
					secondstoarrive=0.05,
					pos=phys:GetPos()+phys:GetAngles():Forward()*20,
					angle=phys:GetAngles(),
					maxangulardamp=30,
					maxspeeddamp=30,
					maxangular=90,
					maxspeed=speed,
					teleportdistance=0,
					deltatime=deltatime,
				}
				phys:Wake()
				phys:ComputeShadowControl(shadowparams)
				if Try > (7*RopeCount) or ((rag.IsWeld or 0) > 0) then
					if RopeCount>1 or (rag.IsWeld or 0 > 0) then
						if RopeCount > 1 then
							ply:ChatPrint("Ropes Left: "..RopeCount - 1)
						end
						if (rag.IsWeld or 0) > 0 then
							ply:ChatPrint("You have been restrained. You can press Space + G to try to break free")
							ply.Bloodlosing = ply.Bloodlosing + 10
							ply.pain = ply.pain + 20
						elseif (not rag.IsWeld or 0) == 0 then
							ply:ChatPrint("You have broken free.")
						end
					else
						ply:ChatPrint("You have broken free.")
					end
					Ropes[1].Constraint:Remove()
					rag:EmitSound("snd_jack_hmcd_ducttape.wav",90,50,0.5,CHAN_AUTO)
				end
			end

			if(ply:KeyDown(IN_ATTACK))then
				if not (IsValid(ply.ActiveWeapon) and ishgweapon(ply.ActiveWeapon)) then
					local pos = ply:EyePos()
					pos[3] = head:GetPos()[3]
					local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) )
					local ang=ply:EyeAngles()
					ang:RotateAroundAxis(eyeangs:Forward(),90)
					ang:RotateAroundAxis(eyeangs:Right(),75)
					local shadowparams = {
						secondstoarrive=0.4,
						pos=head:GetPos()+eyeangs:Forward()*50+eyeangs:Right()*-5,
						angle=ang,
						maxangular=670,
						maxangulardamp=600,
						maxspeeddamp=50,
						maxspeed=1200,
						teleportdistance=0,
						deltatime=deltatime,
					}
					phys:Wake()
					phys:ComputeShadowControl(shadowparams)
				end
			end

			if(ply:KeyDown(IN_ATTACK2))then

				if IsValid(ply.ActiveWeapon) and ishgweapon(ply.ActiveWeapon) then
					if ply.ActiveWeapon:IsPistolHoldType() then
						local physa = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )) )
						local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) ) --rhand
						local ang=ply:EyeAngles()
						ang:RotateAroundAxis(eyeangs:Forward(),180)
						ang:RotateAroundAxis(eyeangs:Up(),10)
						ang:RotateAroundAxis(eyeangs:Right(),-10)
						local pos = ply:EyePos()
						pos[3] = head:GetPos()[3]
						local shadowparams = {
							secondstoarrive=0.4,
							pos=head:GetPos()+eyeangs:Forward()*50+eyeangs:Right()*0,
							angle=ang,
							maxangular=670,
							maxangulardamp=100,
							maxspeeddamp=50,
							maxspeed=600,
							teleportdistance=0,
							deltatime=deltatime,
						}
						physa:Wake()
						physa:ComputeShadowControl(shadowparams)
					else
						local pos = ply:EyePos()
						pos[3] = head:GetPos()[3]
						local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) )
						local physa = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )) )
						local ang=ply:EyeAngles()
						ang:RotateAroundAxis(eyeangs:Forward(),90)
						local shadowparams = {
							secondstoarrive=0.4,
							pos=head:GetPos()+eyeangs:Forward()*60+eyeangs:Right()*10+eyeangs:Up()*0,
							angle=ang,
							maxangular=670,
							maxangulardamp=600,
							maxspeeddamp=50,
							maxspeed=500,
							teleportdistance=0,
							deltatime=deltatime,
						}
						phys:Wake()
						phys:ComputeShadowControl(shadowparams)


						local ang=ply:EyeAngles()
						ang:RotateAroundAxis(eyeangs:Forward(),90)
						ang:RotateAroundAxis(eyeangs:Forward(),90)

						local shadowparams = {
							secondstoarrive=0.4,
							pos=physa:GetPos() + ang:Forward() * 10,
							angle=ang,
							maxangular=670,
							maxangulardamp=100,
							maxspeeddamp=50,
							maxspeed=600,
							teleportdistance=0,
							deltatime=deltatime,
						}
						physa:Wake()
						physa:ComputeShadowControl(shadowparams)
					end
				else
					local physa = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )) )
					local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) ) --rhand
					local ang=ply:EyeAngles()
					ang:RotateAroundAxis(eyeangs:Forward(),90)
					ang:RotateAroundAxis(eyeangs:Right(),75)
					local pos = ply:EyePos()
					pos[3] = head:GetPos()[3]
					local shadowparams = {
						secondstoarrive=0.4,
						pos=head:GetPos()+eyeangs:Forward()*50+eyeangs:Right()*15,
						angle=ang,
						maxangular=670,
						maxangulardamp=100,
						maxspeeddamp=50,
						maxspeed=1200,
						teleportdistance=0,
						deltatime=deltatime,
					}
					physa:Wake()
					physa:ComputeShadowControl(shadowparams)
				end
			end

			if(ply:KeyDown(IN_USE))then
				local phys = head
				local angs = ply:EyeAngles()
				angs:RotateAroundAxis(angs:Forward(),90)
				local shadowparams = {
					secondstoarrive=0.25, -- Halfed from .50
					pos=head:GetPos()+vector_up*(40/math.Clamp(rag:GetVelocity():Length()/300,1,12)),
					angle=angs,
					maxangulardamp=10,
					maxspeeddamp=2, -- Previously 10
					maxangular=370,
					maxspeed=40, -- Doubled from 40 e e e e e ee E
					teleportdistance=0,
					deltatime=deltatime,
				}
				head:Wake()
				head:ComputeShadowControl(shadowparams)
			end
		end
		if(ply:KeyDown(IN_SPEED)) and !ply.unconscious and !timer.Exists("StunTime"..ply:EntIndex()) then
			local bone = rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" ))
			local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) )

			if(!IsValid(rag.ZacConsLH) and (!rag.ZacNextGrLH || rag.ZacNextGrLH<=CurTime()))then
				rag.ZacNextGrLH=CurTime()+0.1
				local traceinfo={
					start=phys:GetPos(),
					endpos=phys:GetPos(),
					mins = -HullVec,
					maxs = HullVec,
					filter=rag,
				}

				local trace = util.TraceHull(traceinfo)
				if(trace.Hit and !trace.HitSky)then
					if !trace.Entity:IsWeapon() then
						local cons = constraint.Weld(rag,trace.Entity,bone,trace.PhysicsBone,0,false,false)
						if(IsValid(cons))then
							rag.ZacConsLH=cons

							ply:SetNWBool("lhon", true)

							rag:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 50, math.random(95, 105))



							rag:ManipulateBoneAngles(rag:LookupBone("ValveBiped.Bip01_L_Finger1"), Angle(0,-30,0), true)
							rag:ManipulateBoneAngles(rag:LookupBone("ValveBiped.Bip01_L_Finger2"), Angle(0,-30,0), true)
						end
					else
						ply:PickupWeapon(trace.Entity)
					end
				end
			end
		else
			if(IsValid(rag.ZacConsLH))then
				ply:SetNWBool("lhon", false)
				rag:ManipulateBoneAngles(rag:LookupBone("ValveBiped.Bip01_L_Finger1"), Angle(0,0,0), true)
				rag:ManipulateBoneAngles(rag:LookupBone("ValveBiped.Bip01_L_Finger2"), Angle(0,0,0), true)

				rag.ZacConsLH:Remove()
				rag.ZacConsLH=nil
			end
		end

		if(ply:KeyDown(IN_WALK)) and !ply.unconscious and !timer.Exists("StunTime"..ply:EntIndex()) then
			local bone = rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))
			local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )) )
			if(!IsValid(rag.ZacConsRH) and (!rag.ZacNextGrRH || rag.ZacNextGrRH<=CurTime()))then
				rag.ZacNextGrRH = CurTime()+0.1

				local traceinfo={
					start=phys:GetPos(),
					endpos=phys:GetPos(),
					mins = -HullVec,
					maxs = HullVec,
					filter=rag,
				}

				local trace = util.TraceHull(traceinfo)
				if(trace.Hit and !trace.HitSky)then
					if !trace.Entity:IsWeapon() then
						local cons = constraint.Weld(rag,trace.Entity,bone,trace.PhysicsBone,0,false,false)
						if(IsValid(cons))then
							ply:SetNWBool("rhon", true)

							rag:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 50, math.random(95, 105))

							rag:ManipulateBoneAngles(rag:LookupBone("ValveBiped.Bip01_R_Finger1"), Angle(0,-30,0), true)
							rag:ManipulateBoneAngles(rag:LookupBone("ValveBiped.Bip01_R_Finger2"), Angle(0,-30,0), true)

							rag.ZacConsRH=cons
						end
					else
						ply:PickupWeapon(trace.Entity)
					end
				end
			end
		else
			if(IsValid(rag.ZacConsRH))then
				ply:SetNWBool("rhon", false)
				rag:ManipulateBoneAngles(rag:LookupBone("ValveBiped.Bip01_R_Finger1"), Angle(0,0,0), true)
				rag:ManipulateBoneAngles(rag:LookupBone("ValveBiped.Bip01_R_Finger2"), Angle(0,0,0), true)

				rag.ZacConsRH:Remove()
				rag.ZacConsRH=nil
			end
		end
		if(ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsLH))then
			local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Spine2" )) )
			local lh = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) )
			local angs = ply:EyeAngles()
			angs:RotateAroundAxis(angs:Right(),30)
			local speed = 40

			if(rag.ZacConsLH.Ent2:GetVelocity():LengthSqr()<1000) then
				local shadowparams = {
					secondstoarrive=0.4,
					pos=phys:GetPos() + angs:Forward() * 20,
					angle=phys:GetAngles(),
					maxangulardamp=10,
					maxspeeddamp=10,
					maxangular=50,
					maxspeed=speed,
					teleportdistance=0,
					deltatime=deltatime,
				}
				phys:Wake()
				phys:ComputeShadowControl(shadowparams)
			end
		end
		if(ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsRH))then
			local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Spine2" )) )
			local rh = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )) )
			local angs = ply:EyeAngles()
			angs:RotateAroundAxis(angs:Right(),30)
			local speed = 40

			if(rag.ZacConsRH.Ent2:GetVelocity():LengthSqr()<1000)then
				local shadowparams = {
					secondstoarrive=0.4,
					pos=phys:GetPos() + angs:Forward() * 20,
					angle=phys:GetAngles(),
					maxangulardamp=10,
					maxspeeddamp=10,
					maxangular=50,
					maxspeed=speed,
					teleportdistance=0,
					deltatime=deltatime,
				}
				phys:Wake()
				phys:ComputeShadowControl(shadowparams)
			end
		end
		if(ply:KeyDown(IN_BACK) and IsValid(rag.ZacConsLH))then
			local phys = rag:GetPhysicsObjectNum( 1 )
			local chst = rag:GetPhysicsObjectNum( 0 )
			local angs = ply:EyeAngles()
			angs:RotateAroundAxis(angs:Right(),30)
			local speed = 60

			if(rag.ZacConsLH.Ent2:GetVelocity():LengthSqr()<1000)then
				local shadowparams = {
					secondstoarrive=0.5,
					pos=phys:GetPos() + angs:Forward() * -10,
					angle=phys:GetAngles(),
					maxangulardamp=10,
					maxspeeddamp=10,
					maxangular=50,
					maxspeed=speed,
					teleportdistance=0,
					deltatime=deltatime,
				}
				phys:Wake()
				phys:ComputeShadowControl(shadowparams)
			end
		end
		if(ply:KeyDown(IN_BACK) and IsValid(rag.ZacConsRH))then
			local phys = rag:GetPhysicsObjectNum( 1 )
			local chst = rag:GetPhysicsObjectNum( 0 )
			local angs = ply:EyeAngles()
			angs:RotateAroundAxis(angs:Right(),30)
			local speed = 60

			if(rag.ZacConsRH.Ent2:GetVelocity():LengthSqr()<1000)then
				local shadowparams = {
					secondstoarrive=0.5,
					pos=phys:GetPos() + angs:Forward() * -10,
					angle=phys:GetAngles(),
					maxangulardamp=10,
					maxspeeddamp=10,
					maxangular=50,
					maxspeed=speed,
					teleportdistance=0,
					deltatime=deltatime,
				}
				phys:Wake()
				phys:ComputeShadowControl(shadowparams)
			end
		end
	end
end)

hook.Add("Player Think","VelocityPlayerFallOnPlayerCheck",function(ply,time)
	local speed = ply:GetVelocity():Length()
	if ply:GetMoveType() ~= MOVETYPE_NOCLIP and not IsValid(ply.FakeRagdoll) and not ply:HasGodMode() and ply:Alive() then
		if speed < 600 then return end
		if hook.Run("Should Fake Velocity",ply,speed) ~= nil then return end

		Faking(ply)
	end
end)
util.AddNetworkString("ebal_chellele")
hook.Add("PlayerSwitchWeapon","fakewep",function(ply,oldwep,newwep)
	if ply.unconscious then return true end

	if IsValid(newwep) and ishgweapon(newwep) then
		ply:SetNWEntity("ActiveWeapon",newwep)
	else
		ply:SetNWEntity("ActiveWeapon",NULL)
	end

	if IsValid(ply.FakeRagdoll) then
		DespawnWeapon(ply)

		if IsValid(newwep) and ishgweapon(newwep) then
			ply:SetActiveWeapon(newwep)
			ply.ActiveWeapon = newwep
			ply:SetActiveWeapon(nil)
			SpawnWeapon(ply)
		else
			ply.ActiveWeapon = nil
			ply:SetActiveWeapon(nil)
		end

		return true
	end
end)

OrgansNextThink = 0.2
InternalBleeding = 20
local player_GetAll = player.GetAll
local organthink = 0
hook.Add("Player Think","InternalBleeding",function(ply,time)
	if organthink > CurTime() then return end
	organthink = CurTime() + OrgansNextThink
	for i,ply in ipairs(player_GetAll()) do
		if ply.organs and ply:Alive() then

			if ply.organs.heart == 0 then
				ply.Blood = ply.Blood - 10
			end

			if ply.organs.spine == 0 then
				ply.brokenspine = true
				if !IsValid(ply.FakeRagdoll) then Faking(ply) end
			end
		end
	end
end)

hook.Add("PlayerUse","nouseinfake",function(ply,ent)
	local class = ent:GetClass()

	if class == "prop_physics" or class=="prop_physics_multiplayer" or class == "func_physbox" then
		local PhysObj = ent:GetPhysicsObject()
		if PhysObj and PhysObj.GetMass and PhysObj:GetMass() > 14 then return false end
	end

	if IsValid(ply.FakeRagdoll) then return false end
	--if ent.IsJModArmor then return false end
end)

hook.Add("PlayerSay", "unconsay", function(ply,text)
	if not roundActive then return end
	if ply.unconscious and ply:Alive() then return false end
end)

hook.Add("PlayerSay","dropweaponhuy",function(ply,text)
    if string.lower(text)=="*drop" then
        ply:DropWeapon1()
		return ""
    end

	--[[if string.lower(text)=="!viptest" then
		if !IsValid(ply.FakeRagdoll) then
		ply:SetVelocity( Vector(0,0,50000) )
		timer.Simple( 5, function()
			ply:Ban(1,false)
			ply:Kick("Ну как тебе ВИП ТЕСТ!!! минутка бана))))")

		end)
		else
		ply:GetNWEntity("Ragdoll"):GetPhysicsObjectNum(0):SetVelocity( Vector(0,0,50000) )
		timer.Simple( 5, function()
			ply:Ban(1,false)
			ply:Kick("Ну как тебе ВИП ТЕСТ!!! хи фейк не поможет, жди минуту")
		end)
		end
	end]]--
end)

hook.Add("UpdateAnimation","huy",function(ply,event,data)
	ply:RemoveGesture(ACT_GMOD_NOCLIP_LAYER)
end)

hook.Add("Player Think","holdentity",function(ply,time)
	--[[if IsValid(ply.holdEntity) then

	end--]]
end)