SWEP.Base = "medkit"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.syringepoison.name")
	SWEP.Author = "Secret Society"
	SWEP.Instructions = language.GetPhrase("hg.syringepoison.inst")
	SWEP.Category = language.GetPhrase("hg.category.traitors")
	SWEP.IconOverride = "materials/items_icons/syringepoisonicon.png"
end

SWEP.Spawnable = true

SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.ViewModel = "models/weapons/w_models/w_jyringe_proj.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_jyringe_proj.mdl"
SWEP.HoldType = "normal"

SWEP.dwsPos = Vector(7, 7, 7)
SWEP.dwsItemPos = Vector(2, 0, 2)

SWEP.dwmModeScale = 0.5
SWEP.dwmForward = 3
SWEP.dwmRight = 1
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = 90
SWEP.dwmAForward = 0

local color_red = Color(255, 0, 0)
local injectsound = "Underwater.BulletImpact"

local function eyeTrace(ply)
	local att1 = ply:LookupAttachment("eyes")
	if not att1 then return end

	local att = ply:GetAttachment(att1)
	if not att then return end

	local tr = {}
	tr.start = att.Pos
	tr.endpos = tr.start + ply:EyeAngles():Forward() * 50
	tr.filter = ply

	return util.TraceLine(tr)
end

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
	if CLIENT then return end

	local ent = eyeTrace(self:GetOwner()).Entity
	local ply = (ent:IsPlayer() and ent) or RagdollOwner(ent)
	if not ply then return end

	self:Poison(ply)
end

function SWEP:SecondaryAttack()
end

if SERVER then
	function SWEP:Poison(ent)
		local entreal = IsValid(ent.FakeRagdoll) and ent.FakeRagdoll or ent

		local bone1 = entreal:LookupBone("ValveBiped.Bip01_Spine4")
		if not bone1 then return end

		local matrix1 = entreal:GetBoneMatrix(bone1)
		if not matrix1 then return end

		local trace = eyeTrace(self:GetOwner())
		local tracePos = trace.HitPos
		local traceDir = trace.HitPos - trace.StartPos
		traceDir:Normalize()
		traceDir:Mul(4)

		if not tracePos or not traceDir then return end

		local ang1 = matrix1:GetAngles()
		local pos1 = matrix1:GetTranslation()

		local raycast1 = util.IntersectRayWithOBB(tracePos, traceDir, pos1, ang1, Vector(-8, -1, -1), Vector(2, 0, 1))

		local bone2 = entreal:LookupBone("ValveBiped.Bip01_Spine1")
		if not bone2 then return end

		local matrix2 = entreal:GetBoneMatrix(bone2)
		if not matrix2 then return end

		local ang2 = matrix2:GetAngles()
		local pos2 = matrix2:GetTranslation()

		local raycast2 = util.IntersectRayWithOBB(tracePos, traceDir, pos2, ang2, Vector(-8, -3, -1), Vector(2, -2, 1))

		if not raycast1 and not raycast2 then
			self:GetOwner():EmitSound(injectsound)
			ent:EmitSound("vo/npc/male01/pain0" .. math.random(1, 5) .. ".wav", 60)
		end

		ent.poisoned = true
		ent.poisonbro = self:GetOwner()

		timer.Create("Cyanid" .. ent:EntIndex() .. "1", 30, 1, function()
			if ent:Alive() and ent.poisoned then ent:EmitSound("vo/npc/male01/moan0" .. math.random(1, 5) .. ".wav", 60) end

			timer.Create("Cyanid" .. ent:EntIndex() .. "2", 10, 1, function()
				if ent:Alive() and ent.poisoned then ent:EmitSound("vo/npc/male01/moan0" .. math.random(1, 5) .. ".wav", 60) end
			end)

			timer.Create("Cyanid" .. ent:EntIndex() .. "3", 15, 1, function()
				if ent:Alive() and ent.poisoned then
					ent.KillReason = "poison"
					-- ent:Kill()
					ent.nohook = true
					ent:TakeDamage(math.huge, ent.poisonbro)
					ent.nohook = nil
				end
			end)
		end)

		self:Remove()

		self:GetOwner():SelectWeapon("weapon_hands")

		return false
	end

	function SWEP:Think()
	end
end

if CLIENT then
	function SWEP:DrawHUD()
		local owner = self:GetOwner()

		local traceResult = eyeTrace(owner)
		local ent = traceResult.Entity
		if not IsValid(ent) then return end

		local bone1 = ent:LookupBone("ValveBiped.Bip01_Spine4")
		if not bone1 then return end

		local matrix1 = ent:GetBoneMatrix(bone1)
		if not matrix1 then return end

		local trace = eyeTrace(self:GetOwner())
		local tracePos = trace.HitPos
		local traceDir = trace.HitPos - trace.StartPos
		traceDir:Normalize()
		traceDir:Mul(4)

		if not tracePos or not traceDir then return end

		local ang1 = matrix1:GetAngles()
			local pos1 = matrix1:GetTranslation()

		local raycast1 = util.IntersectRayWithOBB(tracePos, traceDir, pos1, ang1, Vector(-8, -1, -1), Vector(2, 0, 1))

		local bone2 = ent:LookupBone("ValveBiped.Bip01_Spine1")
		if not bone2 then return end

		local matrix2 = ent:GetBoneMatrix(bone2)
		if not matrix2 then return end

		local ang2 = matrix2:GetAngles()
		local pos2 = matrix2:GetTranslation()

		local raycast2 = util.IntersectRayWithOBB(tracePos, traceDir, pos2, ang2, Vector(-8, -3, -1), Vector(2, -2, 1))

		local frac = traceResult.Fraction

		--[[ Debugging stuff
		if raycast2 then
			debugoverlay.BoxAngles(pos, Vector(-8, -1, -1), Vector(2, 0, 1), ang, 0.01, Color(125, 255, 0)) -- Green color for intersection
		else
			debugoverlay.BoxAngles(pos, Vector(-8, -1, -1), Vector(2, 0, 1), ang, 0.01, Color(255, 125, 0)) -- Red color for no intersection
		end --]]

		if raycast1 or raycast2 then
			surface.SetDrawColor(color_white)
			draw.DrawText("#hg.syringepoison.quiet", "TargetID", traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y - 40, color_white, TEXT_ALIGN_CENTER)
		else
			surface.SetDrawColor(color_red)
			draw.DrawText("#hg.syringepoison.loud", "TargetID", traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y - 40, color_red, TEXT_ALIGN_CENTER)
		end

		draw.NoTexture()

		Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)
	end
end