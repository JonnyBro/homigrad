SWEP.Base = "weapon_hg_grenade_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.smoke.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.smoke.inst")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
	SWEP.IconOverride = "materials/items_icons/smokeicon.png"
end

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/jmod/explosives/grenades/firenade/incendiary_grenade.mdl"
SWEP.WorldModel = "models/jmod/explosives/grenades/firenade/incendiary_grenade.mdl"

SWEP.Grenade = "ent_hgjack_smoke"

function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	if not IsValid(owner) then return self:DrawModel() end

	local mdl = self.worldModel
	if not IsValid(mdl) then
		mdl = ClientsideModel(self.WorldModel)
		mdl:SetNoDraw(true)
		mdl:SetModelScale(0.8)
		self.worldModel = mdl
	end

	self:CallOnRemove("hg_removesmokenade", function() mdl:Remove() end)

	local matrix = self:GetOwner():GetBoneMatrix(11)
	if not matrix then return end

	mdl:SetRenderOrigin(matrix:GetTranslation() + matrix:GetAngles():Forward() * 3 + matrix:GetAngles():Right() * 2)
	mdl:SetRenderAngles(matrix:GetAngles())
	mdl:DrawModel()
end