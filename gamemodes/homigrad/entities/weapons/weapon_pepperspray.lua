SWEP.Base = "weapon_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.pepperspray.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.pepperspray.inst")
	SWEP.Category = language.GetPhrase("hg.category.tools")
	SWEP.IconOverride = "materials/items_icons/sprayicon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 300
SWEP.Primary.DefaultClip = 300
SWEP.Primary.Automatic = true
SWEP.Primary.Wait = 0
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/custom/pepperspray.mdl"
SWEP.WorldModel = "models/weapons/custom/pepperspray.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(15, 15, 15)
SWEP.dwsItemPos = Vector(0, 0, 4)

SWEP.vbw = true
SWEP.vbwPistol = true
SWEP.vbwPos = Vector(-6, -3, 1)
SWEP.vbwAng = Angle(-40, -0, -90)
SWEP.vbwModelScale = 0.9

SWEP.dwr_reverbDisable = true

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

if SERVER then
	function SWEP:Think()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local attack = owner:KeyDown(IN_ATTACK)

		self:SetNWBool("Attack", attack)

		if attack and self:Clip1() > 0 then
			self:TakePrimaryAmmo(1)

			local tr = owner:GetEyeTrace()
			local ent = tr.Entity
			ent = RagdollOwner(ent) or ent
			local head = ent:LookupBone("ValveBiped.Bip01_Head1")
			local ent1 = ent

			if not self.Sound or not self.Sound:IsPlaying() then
				self.Sound = CreateSound(owner, "PhysicsCannister.ThrusterLoop")
				self.Sound:Play()
			end

			if IsValid(ent) and ent:IsPlayer() and tr.HitPos:Distance(tr.StartPos) <= 125 and head then
				head = ent1:GetBoneMatrix(head)

				local pepperInEyes = ent1:GetAttachment(ent1:LookupAttachment("eyes")).Ang:Forward():Dot(tr.Normal)

				if head:GetTranslation():Distance(tr.HitPos) <= 25 and pepperInEyes < -0.5 then
					if self.cantUsePepper then return end

					local dmgInfo = DamageInfo()
					dmgInfo:SetAttacker(owner)
					dmgInfo:SetInflictor(self)
					dmgInfo:SetDamage(5)
					GuiltLogic(ent, owner, dmgInfo)

					net.Start("JMod_VisionBlur")
						net.WriteFloat(5)
					net.Send(ent)

					ent.pain = math.min(ent.pain + 15, 190)
				end
			end
		else
			if self.Sound and self.Sound:IsPlaying() then self.Sound:Stop() end
		end
	end

	function SWEP:Holster()
		self:SetNWBool("Attack", false)

		if self.Sound and self.Sound:IsPlaying() then self.Sound:Stop() end

		return true
	end

	function SWEP:OwnerChanged()
		self:SetNWBool("Attack", false)

		if self.Sound and self.Sound:IsPlaying() then self.Sound:Stop() end
	end
else
	local WorldModel = ClientsideModel(SWEP.WorldModel)
	WorldModel:SetNoDraw(true)

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()

		if IsValid(owner) then
			-- Specify a good position
			local offsetVec = Vector(4, -1, 0)
			local offsetAng = Angle(180, 90, 0)

			local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
			if not boneid then return end

			local matrix = owner:GetBoneMatrix(boneid)
			if not matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)
			WorldModel:SetupBones()
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
		end

		WorldModel:DrawModel()
	end

	local sprites = {}
	local red = Color(122, 0, 0, 255)
	local mat = Material("pwb/sprites/explosion")
	local vectt = Vector(4, -2, -3)
	local vecZero = Vector(0, 0, 0)

	hook.Add("PostPlayerDraw", "hg_pepperspray_effect", function(ply)
		local wep = IsValid(ply) and ply:GetActiveWeapon()

		if IsValid(wep) and wep:GetClass() == "weapon_pepperspray" then
			render.SetMaterial(mat)

			local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
			if not bone then return end

			local matrix = ply:GetBoneMatrix(bone)
			if not matrix then return end

			if wep:GetNWBool("Attack") and wep:Clip1() > 0 then
				local vec = vecZero
				vec:Set(vectt)
				vec:Rotate(matrix:GetAngles())

				sprites[#sprites + 1] = {matrix:GetTranslation() + vec, CurTime(), ply:EyeAngles():Forward() + VectorRand(-0.03, 0.03) + ply:GetVelocity() / 300}
			end

			for i, sprite in pairs(sprites) do
				local animpos = math.max(sprite[2] + 0.5 - CurTime(), 0)

				if animpos < 0.2 then
					sprites[i] = nil

					continue
				end

				render.DrawSprite(sprite[1], 2 / animpos, 2 / animpos, red)

				sprite[1] = sprite[1] + sprite[3] * animpos * 4
			end
		end
	end)
end