SWEP.Base = "weapon_base"

SWEP.PrintName = "Mortar Installer"
SWEP.Author = "Homigrad"
SWEP.Instructions = "Allows you to place down a mortar"
SWEP.Category = "Miscellaneous"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 5
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/Items/item_item_crate.mdl"
SWEP.WorldModel = "models/Items/item_item_crate.mdl"

SWEP.ViewBack = true

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(40, 40, 40)

local function getModel(className)
	local ent = scripted_ents.Get(className)
	if not ent then return end

	return ent.HullModel, ent.TurretModel, ent.TurretPos or Vector(0, 0, 0)
end

local mortars = {
	gred_emp_pm41 = Vector(0, 0, 26),
	gred_emp_3inchmortar = Vector(0, 0, 5)
}

local function getPos(ply, ent)
	local tr = {}
	tr.start = ply:EyePos()

	local dir = Vector(75, 0, 0)
	dir:Rotate(ply:EyeAngles())

	tr.endpos = tr.start + dir
	tr.filter = ply

	tr = util.TraceLine(tr)

	return tr.HitPos + mortars[ent], tr.Hit
end

function SWEP:Initialize()
	AddHomigradWeapon(self)

	if SERVER then
		local _, ent = RandomFromTable(mortars)
		self:SetNWString("Gred", ent)
	end
end

if SERVER then
	function SWEP:PrimaryAttack()
		local owner = self:GetOwner()
		local ent = self:GetNWString("Gred")
		local pos, hit = getPos(owner, ent)
		if not hit then return end

		ent = ents.Create(ent)
		ent:SetPos(pos)
		ent:SetAngles(Angle(0, owner:EyeAngles()[2], 0))
		ent:Spawn()

		owner:EmitSound("garrysmod/balloon_pop_cute.wav")

		self:Remove()
	end

	hook.Add("Gred Emplacment Use", "Mimomet", function(ent, ply)
		if not ply:KeyDown(IN_WALK) or not mortars[ent:GetClass()] then return end
		if ply:HasWeapon("weapon_gredmimomet") then return true end

		ply:Give("weapon_gredmimomet"):SetNWString("Gred", ent:GetClass())

		ent:Remove()

		return true
	end)
else
	function SWEP:PrimaryAttack()
	end

	function SWEP:OnRemove()
		if IsValid(self.model) then self.model:Remove() end
		if IsValid(self.model2) then self.model2:Remove() end
	end

	function SWEP:DrawWorldModel()
		self:SetHoldType("normal")

		local owner = self:GetOwner()
		if not IsValid(owner) then return self:DrawModel() end

		local mdl = self.worldModel
		if not IsValid(mdl) then
			mdl = ClientsideModel(self.WorldModel)
			mdl:SetNoDraw(true)
			mdl:SetModelScale(0.5)
			self.worldModel = mdl
		end

		self:CallOnRemove("hg_removegregmortar", function() mdl:Remove() end)

		local matrix = self:GetOwner():GetBoneMatrix(11)
		if not matrix then return end

		mdl:SetRenderOrigin(matrix:GetTranslation())
		mdl:SetRenderAngles(matrix:GetAngles() + Angle(90, 180, 0))
		mdl:DrawModel()
	end

	local green = Color(0, 255, 0)
	local red = Color(255, 0, 0)

	function SWEP:Step()
		local owner = self:GetOwner()
		local ent = self:GetNWString("Gred")
		local mdlStand, mdlTurret, turretPos = getModel(ent)
		if not mdlStand then return end

		local model = self.model
		if not IsValid(model) then
			model = ClientsideModel(mdlStand)
			self.model = model
		end

		local model2 = self.model2
		if not IsValid(model2) then
			model2 = ClientsideModel(mdlTurret)
			self.model2 = model2
		end

		local pos, hit = getPos(owner, ent)
		model:SetPos(pos)
		model:SetAngles(Angle(0, owner:EyeAngles()[2], 0))

		model2:SetPos(model:GetPos() + turretPos)
		model2:SetAngles(model:GetAngles())

		model:SetColor(hit and green or red)

		model2:SetColor(hit and green or red)
	end

	local hg_hint = CreateClientConVar("hg_hint", "1", true, false)

	function SWEP:DrawHUD()
		local ent = scripted_ents.Get(self:GetNWString("Gred"))
		if not ent then return draw.SimpleText("something is not right...", "DebugFixedSmall", ScrW() / 2, ScrH() - 175, color_white, TEXT_ALIGN_CENTER) end

		draw.SimpleText(ent.PrintName, "ChatFont", ScrW() / 2, ScrH() - 175, color_white, TEXT_ALIGN_CENTER)

		if not hg_hint:GetBool() then return end

		draw.SimpleText("#hg.hint.ammo", "DebugFixedSmall", ScrW() / 2, ScrH() - 150, color_white, TEXT_ALIGN_CENTER)
		draw.SimpleText("#hg.hint.pickup", "DebugFixedSmall", ScrW() / 2, ScrH() - 125, color_white, TEXT_ALIGN_CENTER)
		draw.SimpleText("#hg.hint.show", "DebugFixedSmall", ScrW() / 2, ScrH() - 100, color_white, TEXT_ALIGN_CENTER)
	end

	function SWEP:Holster()
		if IsValid(self.model) then self.model:Remove() end
		if IsValid(self.model2) then self.model2:Remove() end
	end

	function SWEP:OwnerChanged()
		self:Holster()
	end
end