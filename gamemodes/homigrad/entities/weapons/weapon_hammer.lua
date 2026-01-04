SWEP.Base = "weapon_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.hammer.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.hammer.inst")
	SWEP.Category = language.GetPhrase("hg.category.tools")
	SWEP.IconOverride = "materials/items_icons/hammericon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 12
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 1.1
SWEP.Primary.Force = 180

SWEP.Secondary.ClipSize = 6
SWEP.Secondary.DefaultClip = 6
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "ammo_crossbow"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 3
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/w_jjife_t.mdl"
SWEP.WorldModel = "models/weapons/w_jjife_t.mdl"

SWEP.ViewBack = true
SWEP.ForceSlot1 = true

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(15, 15, 15)
SWEP.dwsItemPos = Vector(-2, 0, 3)
SWEP.dwsItemAng = Angle(-32, 0, 0)

SWEP.vbw = true
SWEP.vbwPistol = true
SWEP.vbwPos = Vector(-7, 2, 0)

SWEP.dwr_reverbDisable = true

SWEP.UseHands = true

SWEP.FiresUnderwater = false

SWEP.DrawCrosshair = false

SWEP.DrawAmmo = true

SWEP.DrawSound = "weapons/melee/holster_in_light.wav"
SWEP.HitSound = "snd_jack_hmcd_hammerhit.wav"
SWEP.FlashHitSound = "Impact.Flesh"
SWEP.ShouldDecal = false
SWEP.HoldTypeWep = "melee2"
SWEP.DamageType = DMG_CLUB

function SWEP:Deploy()
	if not IsFirstTimePredicted() then return end

	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)

	self:SetHoldType("melee")
end

local function TwoTrace(ply)
	local owner = ply
	local tr = {}
	tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos

	local dir = Vector(1, 0, 0)
	dir:Rotate(owner:EyeAngles())

	tr.endpos = tr.start + dir * 75
	tr.filter = {owner}

	local tRes1 = util.TraceLine(tr)
	if not IsValid(tRes1.Entity) then return end

	tr.start = tRes1.HitPos + tRes1.Normal
	tr.endpos = tRes1.HitPos + dir * 25
	tr.filter[2] = tRes1.Entity

	if SERVER then
		for _, info in pairs(constraint.GetTable(tRes1.Entity)) do
			if info.Ent1 ~= game.GetWorld() then table.insert(tr.filter, info.Ent1) end
			if info.Ent2 ~= game.GetWorld() then table.insert(tr.filter, info.Ent2) end
		end
	end

	local tRes2 = util.TraceLine(tr)
	if not tRes2.Hit then return end

	return tRes1, tRes2
end

function SWEP:PrimaryAttack()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if SERVER then
		self:SetNextPrimaryFire(CurTime() + 1 / (self:GetOwner().stamina / 100))
		self:SetNextSecondaryFire(CurTime() + 2)

		self:GetOwner():EmitSound("weapons/slam/throw.wav", 60)

		self:GetOwner().stamina = math.max(self:GetOwner().stamina - 1, 0)
	end

	self:GetOwner():LagCompensation(true)

	local ply = self:GetOwner()
	local tra = {}
	tra.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
	tra.endpos = tra.start + ply:GetAngles():Forward() * 80
	tra.filter = self:GetOwner()
	local Tr = util.TraceLine(tra)

	local t = {}
	local pos1, pos2
	local tr
	if not Tr.Hit then
		t.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
		t.endpos = t.start + ply:GetAngles():Forward() * 80
		t.filter = function(ent) return ent ~= self:GetOwner() and (ent:IsPlayer() or ent:IsRagdoll()) end
		t.mins = -Vector(10, 10, 10)
		t.maxs = Vector(10, 10, 10)
		tr = util.TraceHull(t)
	else
		tr = util.TraceLine(tra)
	end

	pos1 = tr.HitPos + tr.HitNormal
	pos2 = tr.HitPos - tr.HitNormal

	if true then
		if SERVER and tr.HitWorld then self:GetOwner():EmitSound(self.HitSound, 60) end

		if IsValid(tr.Entity) and SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType(self.DamageType)
			dmginfo:SetAttacker(self:GetOwner())
			dmginfo:SetInflictor(self)
			dmginfo:SetDamagePosition(tr.HitPos)
			dmginfo:SetDamageForce(self:GetOwner():GetForward() * self.Primary.Force)

			local angle = self:GetOwner():GetAngles().y - tr.Entity:GetAngles().y
			if angle < -180 then angle = 360 + angle end

			if angle <= 90 and angle >= -90 then
				dmginfo:SetDamage(self.Primary.Damage * 1.5)
			else
				dmginfo:SetDamage(self.Primary.Damage / 1.5)
			end

			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
				self:GetOwner():EmitSound(self.FlashHitSound, 60)
			else
				if IsValid(tr.Entity:GetPhysicsObject()) then
					local dmginfo2 = DamageInfo()
						dmginfo2:SetDamageType(self.DamageType)
						dmginfo2:SetAttacker(self:GetOwner())
						dmginfo2:SetInflictor(self)
						dmginfo2:SetDamagePosition(tr.HitPos)
						dmginfo2:SetDamageForce(self:GetOwner():GetForward() * self.Primary.Force * 7)
						dmginfo2:SetDamage(self.Primary.Damage)
					tr.Entity:TakeDamageInfo(dmginfo2)

					if tr.Entity:GetClass() == "prop_ragdoll" then
						self:GetOwner():EmitSound(self.FlashHitSound, 60)
					else
						self:GetOwner():EmitSound(self.HitSound, 60)
					end
				end
			end

			tr.Entity:TakeDamageInfo(dmginfo)
		end
		-- self:GetOwner():EmitSound(self.HitSound, 60)
	end

	if SERVER and Tr.Hit and self.ShouldDecal then
		if IsValid(Tr.Entity) and Tr.Entity:GetClass() == "prop_ragdoll" then
			util.Decal("Impact.Flesh", pos1, pos2)
		else
			util.Decal("ManhackCut", pos1, pos2)
		end
	end

	self:GetOwner():LagCompensation(false)
end

function SWEP:SecondaryAttack()
	if not self.mode then
		local att = self:GetOwner()
		local tRes1, tRes2 = TwoTrace(att)
		if not tRes1 then return end

		if self:Clip2() == 0 then return end

		if SERVER then
			self:SetClip2(self:Clip2() - 1)

			local ent1, ent2 = tRes1.Entity, tRes2.Entity
			ent1.IsWeld = (ent1.IsWeld or 0) + 1
			ent2.IsWeld = (ent2.IsWeld or 0) + 1

			local ply = RagdollOwner(ent1) or RagdollOwner(ent2) or false
			if ply then
				local dmg = DamageInfo()
					dmg:SetDamage(10)
					dmg:SetAttacker(self)
					dmg:SetDamageType(DMG_SLASH)
				ply:TakeDamageInfo(dmg)

				ply.Bloodlosing = ply.Bloodlosing + 10

				if GuiltLogic(att, ply, dmg) then GuiltCheck(att) end
			end

			if not IsValid(ent1:GetPhysicsObject()) or not IsValid(ent2:GetPhysicsObject()) then return end

			local weldEntity = constraint.Weld(ent1, ent2, tRes1.PhysicsBone or 0, tRes2.PhysicsBone or 0, 0, false, false)
			ent1.weld = ent1.weld or {}
			ent2.weld = ent2.weld or {}
			ent1.weld[weldEntity] = ent2
			ent2.weld[weldEntity] = ent1

			self:GetOwner():EmitSound("snd_jack_hmcd_hammerhit.wav", 65)
		end

		self:SetNextSecondaryFire(CurTime() + 1)
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	else
		local att = self:GetOwner()
		local tRes1, tRes2 = TwoTrace(att)
		if not tRes1 then return end

		local ent1, ent2 = tRes1.Entity, tRes2.Entity
		local ply = RagdollOwner(ent1) or RagdollOwner(ent2)

		if ent1.weld then
			for weldEntity, ent in pairs(ent1.weld) do
				ent1.IsWeld = math.max((ent1.IsWeld or 0) - 1, 0)
				ent.IsWeld = math.max((ent.IsWeld or 0) - 1, 0)

				if ent1.IsWeld == 0 and ent.IsWeld == 0 then
					ent.weld[weldEntity] = nil
					ent1.weld[weldEntity] = nil

					weldEntity:Remove()
				end

				self:SetClip2(self:Clip2() + 1)

				ent1:EmitSound("snd_jack_hmcd_hammerhit.wav", 65)
			end

			if ply then
				local dmg = DamageInfo()
					dmg:SetDamage(10)
					dmg:SetAttacker(self)
					dmg:SetDamageType(DMG_SLASH)
				ply:TakeDamageInfo(dmg)

				ply.Bloodlosing = ply.Bloodlosing + 10
			end
		end

		self:SetNextSecondaryFire(CurTime() + 1)
	end
end

function SWEP:Think()
	local ply = self:GetOwner()

	if SERVER then
		if ply:KeyDown(IN_ATTACK2) then
			if ply:KeyDown(IN_USE) and not self.modechanged then
				self.modechanged = true

				self.mode = not (self.mode or false)

				net.Start("hammer_mode")
					net.WriteEntity(self)
					net.WriteBool(self.mode)
				net.Send(ply)

				net.Start("hg_sendchat_simple")
					net.WriteString("#hg.hammer.nailing." .. tostring(not self.mode))
				net.Send(ply)
			end
		else
			self.modechanged = false
		end
	end
end

if SERVER then
	util.AddNetworkString("hammer_mode")

	hook.Add("Fake Up", "hg_hammer_weldcheck", function(ply, rag) if (rag.IsWeld or 0) > 0 then return false end end)
else
	net.Receive("hammer_mode", function(len)
		net.ReadEntity().mode = net.ReadBool()
	end)
end

local bonenames = {
	["ValveBiped.Bip01_Head1"] = "#hg.bones.head",
	["ValveBiped.Bip01_Spine"] = "#hg.bones.spine",
	["ValveBiped.Bip01_Spine2"] = "#hg.bones.spine",
	["ValveBiped.Bip01_Pelvis"] = "#hg.bones.pelvis",

	["ValveBiped.Bip01_R_Hand"] = "#hg.bones.rhand",
	["ValveBiped.Bip01_R_Forearm"] = "#hg.bones.rforearm",
	["ValveBiped.Bip01_R_Shoulder"] = "#hg.bones.rshoulder",
	["ValveBiped.Bip01_R_UpperArm"] = "#hg.bones.rshoulder",
	["ValveBiped.Bip01_R_Elbow"] = "#hg.bones.relbow",

	["ValveBiped.Bip01_R_Foot"] = "#hg.bones.rfoot",
	["ValveBiped.Bip01_R_Thigh"] = "#hg.bones.rthigh",
	["ValveBiped.Bip01_R_Calf"] = "#hg.bones.rcalf",

	["ValveBiped.Bip01_L_Hand"] = "#hg.bones.lhand",
	["ValveBiped.Bip01_L_Forearm"] = "#hg.bones.lforearm",
	["ValveBiped.Bip01_L_Shoulder"] = "#hg.bones.lshoulder",
	["ValveBiped.Bip01_L_UpperArm"] = "#hg.bones.lshoulder",
	["ValveBiped.Bip01_L_Elbow"] = "#hg.bones.lelbow",

	["ValveBiped.Bip01_L_Foot"] = "#hg.bones.lfoot",
	["ValveBiped.Bip01_L_Thigh"] = "#hg.bones.lthigh",
	["ValveBiped.Bip01_L_Calf"] = "#hg.bones.lcalf"
}

function SWEP:DrawHUD()
	local owner = self:GetOwner()
	local tr = {}
	tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos

	local dir = Vector(1, 0, 0)
	dir:Rotate(owner:EyeAngles())

	tr.endpos = tr.start + dir * 75
	tr.filter = owner

	local tRes1, _ = TwoTrace(owner)
	local traceResult = util.TraceLine(tr)
	local hit = traceResult.Hit and 1 or 0

	local hitEnt = traceResult.Entity ~= Entity(0) and 1 or 0
	local isRag = traceResult.Entity:IsRagdoll()
	local frac = traceResult.Fraction

	surface.SetDrawColor(Color(255 * hitEnt, 255 * hitEnt, 255 * hitEnt, 255 * hit))
	draw.NoTexture()

	Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)

	draw.DrawText(not tRes1 and "" or isRag and language.GetPhrase("hg.hammer.nailin"):format(language.GetPhrase(bonenames[traceResult.Entity:GetBoneName(traceResult.Entity:TranslatePhysBoneToBone(traceResult.PhysicsBone))])) or tobool(hitEnt) and tobool(hit) and "#hg.hammer.nailinprop" or "", "TargetID", traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y - 40, color_white, TEXT_ALIGN_CENTER)
end