util.AddNetworkString("blood_gotten")

include("shared.lua")

local healsound1 = Sound("npc/antlion/foot4.wav")
local healsound2 = Sound("npc/antlion/shell_impact2.wav")

local bloodtranslate = {
	[1] = "o-",
	[2] = "o+",
	[3] = "a-",
	[4] = "a+",
	[5] = "b-",
	[6] = "b+",
	[7] = "ab-",
	[8] = "ab+"
}

local bloodtypes = {
	["o-"] = {
		["o-"] = true,
		["o+"] = true,
		["a-"] = true,
		["a+"] = true,
		["b-"] = true,
		["b+"] = true,
		["ab-"] = true,
		["ab+"] = true
	},
	["o+"] = {
		["o+"] = true,
		["a+"] = true,
		["b+"] = true,
		["ab+"] = true
	},
	["a-"] = {
		["a+"] = true,
		["a-"] = true,
		["ab+"] = true,
		["ab-"] = true
	},
	["a+"] = {
		["a+"] = true,
		["ab+"] = true
	},
	["b-"] = {
		["b+"] = true,
		["b-"] = true,
		["ab+"] = true,
		["ab-"] = true
	},
	["b+"] = {
		["b+"] = true,
		["ab+"] = true
	},
	["ab-"] = {
		["ab+"] = true,
		["ab-"] = true
	},
	["ab+"] = {
		["ab+"] = true
	}
}

function SWEP:Think()
	local owner = self:GetOwner()

	if owner:KeyDown(IN_ATTACK) then
		local ent = owner

		if not ent then
			self.zabortime = nil

			return
		end

		self.bloodinside = self.bloodinside or false

		if owner:KeyPressed(IN_ATTACK) then
			self.zabortime = self.zabortime or CurTime()

			ent:EmitSound(healsound2)

			owner:SetAnimation(PLAYER_ATTACK1)

			ent.bloodtype = ent.bloodtype or math.random(1, 8)

			owner:ChatPrint(self.bloodinside and "#hg.bloodbag.empty" or "#hg.bloodbag.fill")
		end

		if ent and self.zabortime and self.zabortime + 2 <= CurTime() then
			self:Heal(ent)
			self:SetSkin(not self.bloodinside and 1 or 0)
		end
	elseif owner:KeyDown(IN_ATTACK2) then
		local ent = self:GetEyeTraceDist(75).Entity
		ent = ent:IsPlayer() and ent or RagdollOwner(ent) or (ent.Blood or 0) > 500 and ent

		if not ent then
			self.zabortime = nil

			return
		end

		if owner:KeyPressed(IN_ATTACK2) then
			self.zabortime = self.zabortime or CurTime()

			ent:EmitSound(healsound2)

			owner:SetAnimation(PLAYER_ATTACK1)

			ent.bloodtype = ent.bloodtype or math.random(1, 8)

			owner:ChatPrint(self.bloodinside and "#hg.bloodbag.emptyp" or "#hg.bloodbag.fillp")
		end

		if ent and self.zabortime and self.zabortime + 2 <= CurTime() then
			self:Heal(ent)
			self:SetSkin(not self.bloodinside and 1 or 0)
		end
	else
		self.zabortime = nil
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:PostInit()
	self.bloodinside = math.random(1, 5) > 2 and true or false

	if self.bloodinside then
		self.bloodtype = 1 -- math.random(1,8)

		net.Start("blood_gotten")
			net.WriteEntity(self)
			net.WriteBool(self.bloodinside)
		net.Broadcast()
	end

	self:SetSkin(self.bloodinside and 0 or 1) -- Skins are switched around for some reason
end

function SWEP:SecondaryAttack()
end

function SWEP:Heal(ent)
	ent:EmitSound(healsound1)

	self.zabortime = nil

	if self.bloodinside then
		self.bloodinside = false

		local compatible = bloodtypes[bloodtranslate[self.bloodtype]][bloodtranslate[ent.bloodtype]]

		ent.Blood = math.min(ent.Blood + (compatible and 500 or 0), 5000)

		if not compatible then ent.InternalBleeding6 = 20 end

		net.Start("blood_gotten")
			net.WriteEntity(self)
			net.WriteBool(self.bloodinside)
		net.Broadcast()

		ent:EmitSound(healsound1)
	else
		if ent.Blood > 4000 then
			self.bloodinside = true

			ent.Blood = math.max(ent.Blood - 500, 0)

			self.bloodtype = ent.bloodtype

			net.Start("blood_gotten")
				net.WriteEntity(self)
				net.WriteBool(self.bloodinside)
			net.Broadcast()

			ent:EmitSound(healsound1)
		end
	end
end