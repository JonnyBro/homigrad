AddCSLuaFile()

SWEP.Base = "medkit"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.handcuffs.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.handcuffs.inst")
	SWEP.Category = language.GetPhrase("hg.category.tools")
	SWEP.IconOverride = "materials/items_icons/handcuffsicon.png"
end

SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP.ViewModel = "models/freeman/flexcuffs.mdl"
SWEP.WorldModel = "models/freeman/flexcuffs.mdl"

SWEP.dwmForward = 3.5
SWEP.dwmRight = 1
SWEP.dwmUp = -1

if SERVER then
	util.AddNetworkString("hg_cuffssync")
else
	net.Receive("hg_cuffssync", function(len)
		local ent = net.ReadEntity()
		ent.CuffPly = net.ReadEntity()
		ent.CuffTime = net.ReadFloat()
	end)
end

function SWEP:PrimaryAttack()
	if SERVER then
		local owner = self:GetOwner()
		local tr = {}
		tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos

		local dir = Vector(1, 0, 0)
		dir:Rotate(owner:EyeAngles())

		tr.endpos = tr.start + dir * 45
		tr.filter = owner

		local traceResult = util.TraceLine(tr)
		local ent = traceResult.Entity
		if not IsValid(ent) then return end

		local ply =  RagdollOwner(ent) and ent

		if IsValid(ent) and ply then
			self.CuffPly = ply
			self.CuffTime = CurTime()

			net.Start("hg_cuffssync")
				net.WriteEntity(self)
				net.WriteEntity(ply)
				net.WriteFloat(CurTime())
			net.Send(owner)
		end
	end
end

local cuffTime = 2

function SWEP:Think()
	if SERVER and IsValid(self.CuffPly) then
		local pos1 = self.CuffPly:GetPos()
		local pos2 = self:GetOwner():GetPos()

		if pos1:Distance(pos2) >= 100 then
			self.CuffPly = nil
		elseif self.CuffTime + cuffTime <= CurTime() then
			self:Cuff(self.CuffPly)
		end
	end
end

if SERVER then return end

function SWEP:DrawHUD()
	local owner = self:GetOwner()

	local tr = {}
	tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos

	local dir = Vector(1, 0, 0)
	dir:Rotate(owner:EyeAngles())

	tr.endpos = tr.start + dir * 45
	tr.filter = owner

	local traceResult = util.TraceLine(tr)
	local ent = traceResult.Entity

	local ply = RagdollOwner(ent) or ent
	ply = ply:IsPlayer() and ply

	local hit = traceResult.Hit and 1 or 0
	local x, y = traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y

	if not IsValid(ent) then
		local frac = traceResult.Fraction
		surface.SetDrawColor(Color(255, 255, 255, 255 * hit))
		draw.NoTexture()
		Circle(x, y, 5 / frac, 32)
	else
		local frac = traceResult.Fraction
		surface.SetDrawColor(Color(255, 255, 255, 255))
		draw.NoTexture()
		Circle(x, y, 5 / frac, 32)
		draw.DrawText(language.GetPhrase("hg.handcuffs.tieup"):format(ply:Name()), "TargetID", x, y - 40, color_white, TEXT_ALIGN_CENTER)

		if self.CuffTime then surface.DrawRect(x - 50, y + 50, 100 - math.max((self.CuffTime - CurTime() + cuffTime) * 100, 0), 25) end
	end
end