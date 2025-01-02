SWEP.Base = "weapon_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.radio.name")
	SWEP.Author = "homigrad"
	SWEP.Instructions = language.GetPhrase("hg.radio.inst")
	SWEP.Category = language.GetPhrase("hg.category.tools")
end

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
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/sirgibs/ragdoll/css/terror_arctic_radio.mdl"
SWEP.WorldModel = "models/sirgibs/ragdoll/css/terror_arctic_radio.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(15, 15, 5)
SWEP.dwsItemPos = Vector(0, 7, -40)

SWEP.vbw = true
SWEP.vbwPistol = true
SWEP.vbwPos = Vector(0.5, -44, -0.5)
SWEP.vbwAng = Angle(-90, 0, -90)
SWEP.vbwModelScale = 1

if SERVER then
	util.AddNetworkString("hg_radio_cl")

	homigrad_weapons = homigrad_weapons or {}

	function SWEP:Initialize()
		self:SetHoldType("normal")

		homigrad_weapons[self] = true

		self.voiceSpeak = 0
		self.lisens = {}
	end

	function SWEP:BippSound(ent, pitch)
		ent:EmitSound("buttons/button16.wav", 75, pitch)
	end

	function SWEP:CanLisen(output, input, isChat)
		if not output:Alive() or output.Otrub or not input:Alive() or input.Otrub then return false end

		if output:InVehicle() and output:IsSpeaking() then
			self.voiceSpeak = CurTime() + 0.5
		end

		if not input:HasWeapon("weapon_radio") then return end
		if output:GetActiveWeapon() ~= self or (not isChat and not self.Transmit) then return end
		if output:Team() == input:Team() or output:Team() == 1002 then return true end
	end

	function SWEP:CanTransmit()
		local owner = self:GetOwner()

		return not owner:InVehicle() and (self.voiceSpeak > CurTime() or owner:KeyDown(IN_ATTACK2))
	end

	function SWEP:Step()
		local output = self:GetOwner()

		if not IsValid(output) then return end

		local Transmit = self:CanTransmit()
		self.Transmit = Transmit

		if Transmit then
			local lisens = self.lisens

			for i, input in pairs(player.GetAll()) do
				if not self:CanLisen(output, input) then
					if lisens[input] then
						lisens[input] = nil
						self:BippSound(input, 80)
					end
				elseif not lisens[input] then
					lisens[input] = true

					net.Start("hg_radio_cl")
						net.WriteString(output:Name())
					net.Send(input)

					self:BippSound(input, 100)
				end
			end

			self:SetHoldType("slam")
		else
			local lisens = self.lisens

			for input in pairs(lisens) do
				lisens[input] = nil

				self:BippSound(input, 80)
			end

			self:SetHoldType("normal")
		end
	end

	function SWEP:OnRemove()
	end

	hook.Add("Player Can Lisen", "radio", function(output, input, isChat)
		local wep = output:GetWeapon("weapon_radio")

		if IsValid(wep) and wep:CanLisen(output, input, isChat) then
			if isChat then
				for i, input in pairs(player.GetAll()) do
					if not wep:CanLisen(output, input, isChat) then continue end

					wep:BippSound(input, 140)
				end
			end

			return true, false
		end
	end)
else
	local hg_hint = CreateClientConVar("hg_hint", "1", true, false)

	function SWEP:DrawHUD()
		if LocalPlayer():InVehicle() or not hg_hint:GetBool() then return end

		draw.SimpleText("#hg.radio.hud1", "DebugFixedSmall", ScrW() / 2 - 200, ScrH() - 175, color_white)
		draw.SimpleText("#hg.radio.hud2", "DebugFixedSmall", ScrW() / 2 + 200, ScrH() - 175, color_white, TEXT_ALIGN_RIGHT)
		draw.SimpleText("#hg.radio.hud3", "DebugFixedSmall", ScrW() / 2 - 200, ScrH() - 150, color_white)
		draw.SimpleText("#hg.radio.hud4", "DebugFixedSmall", ScrW() / 2 + 200, ScrH() - 150, color_white, TEXT_ALIGN_RIGHT)
		draw.SimpleText("#hg.radio.hud5", "DebugFixedSmall", ScrW() / 2, ScrH() - 125, color_white, TEXT_ALIGN_CENTER)
		draw.SimpleText("#hg.sweps.hint", "DebugFixedSmall", ScrW() / 2, ScrH() - 100, color_white, TEXT_ALIGN_CENTER)
	end

	net.Receive("hg_radio_cl", function()
		local name = net.ReadString()

		LocalPlayer():ChatPrint(language.GetPhrase("hg.radio.speaking"):format(name))
	end)
end