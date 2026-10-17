local blackListedAmmo = {
	[8] = true,
	[9] = true,
	[10] = true
}

local AmmoTypes = {
	[1] = "vgui/hud/hmcd_round_556",
	[2] = "vgui/hud/hmcd_health",
	[6] = "vgui/hud/hmcd_round_arrow",
	[8] = "vgui/wep_jack_hmcd_oldgrenade",
	[9] = "vgui/wep_jack_hmcd_oldgrenade",
	[10] = "vgui/wep_jack_hmcd_oldgrenade",
	[11] = "vgui/wep_jack_hmcd_ied",
	[38] = "vgui/hud/hmcd_round_38",
	[40] = "vgui/hud/hmcd_round_792",
	[41] = "vgui/hud/hmcd_round_12",
	[42] = "vgui/hud/hmcd_round_12",
	[44] = "vgui/hud/hmcd_round_792",
	[45] = "vgui/hud/hmcd_round_556",
	[46] = "vgui/hud/hmcd_round_556",
	[47] = "vgui/hud/hmcd_round_792",
	[48] = "vgui/hud/hmcd_round_9",
	[49] = "vgui/hud/hmcd_round_9",
}

local black = Color(0, 0, 0, 128)
local grey = Color(64, 64, 64, 128)

local function getText(text, limitW)
	local newText = {}
	local newText_I = 1
	local curretText = ""

	surface.SetFont("DefaultFixedDropShadow")

	for i = 1, #text do
		local sumbol = string.sub(text, i, i)
		local w, _ = surface.GetTextSize(curretText .. sumbol)

		if w >= limitW then
			newText_I = newText_I + 1
			curretText = sumbol
		else
			curretText = curretText .. sumbol
		end

		newText[newText_I] = curretText
	end

	return newText
end

local panel
hg_searched = {}

local slotEmptyColor = Color(0, 0, 0, 160)
local slotProgressColor = Color(255, 255, 255, 40)
local slotQuestionColor = Color(255, 255, 255, 40)

net.Receive("hg_inventory", function()
	if IsValid(panel) then
		panel.override = true
		panel:Remove()
	end

	local plr = LocalPlayer()
	local lootEnt = net.ReadEntity()
	local ragdoll

	-- If player is dead (lootEnt is prop_ragdoll) return who's ragdoll it was
	if IsValid(lootEnt) and lootEnt:GetClass() == "prop_ragdoll" then
		ragdoll = lootEnt
		lootEnt = lootEnt:GetNWEntity("OldRagdollController")
	end

	if not GetConVar("hg_LootAlive"):GetBool() and lootEnt:Alive() then return end

	local success, items = pcall(net.ReadTable)
	if not success or not lootEnt then return end

	if IsValid(lootEnt:GetNWEntity("ActiveWeapon")) and items[lootEnt:GetNWEntity("ActiveWeapon"):GetClass()] then items[lootEnt:GetNWEntity("ActiveWeapon"):GetClass()] = nil end

	local items_ammo = net.ReadTable()
	local targetID = IsValid(lootEnt) and lootEnt:IsPlayer() and lootEnt:SteamID64() or lootEnt:EntIndex()

	items.weapon_hands = nil

	panel = vgui.Create("DFrame")
	panel:SetTitle("")
	panel:SetAlpha(255)
	panel:SetSize(400, 400)
	panel:Center()
	panel:SetDraggable(false)
	panel:ShowCloseButton()
	panel:MakePopup()

	local closeButton = vgui.Create("DButton", panel)
	closeButton:SetPos(375, 5)
	closeButton:SetSize(20, 20)
	closeButton:SetText("")

	closeButton.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, black)
		surface.SetDrawColor(255, 255, 255, 128)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		draw.SimpleText("X", "DefaultFixedDropShadow", 6, 5, color_white)
	end

	closeButton.DoClick = function()
		panel:Remove()
	end

	function panel:OnKeyCodePressed(key)
		if key == KEY_W or key == KEY_S or key == KEY_A or key == KEY_D or key == KEY_E then
			self:Remove()
		end
	end

	local frame = panel
	local lootingTime = math.Clamp(GetConVar("hg_SearchTime"):GetFloat(), 0, 10)
	local corner = 6
	local x, y = 40, 40

	if not targetID then return end

	local found = hg_searched[targetID]
	if not istable(found) then
		found = {}
		hg_searched[targetID] = found
	end

	function panel:OnRemove()
		if self.override then return end

		found.__progressKey = nil
		found.__progressStart = nil

		net.Start("hg_inventory")
			net.WriteEntity(lootEnt)
		net.SendToServer()
	end

	local entries = {}

	for wep, weapon in pairs(items) do
		entries[#entries + 1] = {key = "w:" .. wep, wep = wep, weapon = weapon}
	end

	for ammo, _ in pairs(items_ammo) do
		if blackListedAmmo[ammo] then continue end

		entries[#entries + 1] = {key = "a:" .. ammo, ammo = ammo}
	end

	table.sort(entries, function(a, b) return a.key < b.key end)

	local pending = {}
	local current
	local searchStart = 0

	panel.Paint = function(self, w, h)
		if not IsValid(lootEnt) or not plr:Alive() then return self:Remove() end

		local nickname = lootEnt:IsPlayer() and lootEnt:Name() or lootEnt:GetNWString("Nickname") or ""

		draw.RoundedBox(0, 0, 0, w, h, black)
		surface.SetDrawColor(255, 255, 255, 128)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		draw.SimpleText(language.GetPhrase("hg.inventory.title"):format(nickname), "DefaultFixedDropShadow", corner, corner, color_white)

		if current then
			draw.SimpleText(language.GetPhrase("hg.inventory.searching"), "DefaultFixedDropShadow", corner, h - corner - 12, color_white)
		end
	end

	local function nextSlot(button)
		button:SetPos(x, y)
		button:SetSize(64, 64)

		x = x + button:GetWide() + 6

		if x + button:GetWide() >= frame:GetWide() then
			x = 40
			y = y + button:GetTall() + 6
		end

		button:SetText("")
	end

	local function paintHidden(entry)
		return function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, slotEmptyColor)
			surface.SetDrawColor(255, 255, 255, 48)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

			if entry == current then
				local frac = lootingTime > 0 and math.Clamp((CurTime() - searchStart) / lootingTime, 0, 1) or 1
				local fillH = math.floor((h - 4) * frac)

				draw.RoundedBox(0, 2, h - 2 - fillH, w - 4, fillH, slotProgressColor)

				local dots = string.rep(".", math.floor(CurTime() * 3) % 4)
				draw.SimpleText(dots, "DefaultFixedDropShadow", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText("?", "DefaultFixedDropShadow", w / 2, h / 2, slotQuestionColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end

	local function setupWeaponButton(button, wep, weapon)
		local text = weapon.PrintName or wep
		text = getText(text, button:GetWide() - corner * 2)

		button.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and grey or black)
			surface.SetDrawColor(255, 255, 255, 128)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

			local x, y = self:LocalToScreen(0, 0)
			DrawWeaponSelectionEX(weapon, x, y, w, h)

			for i, text in pairs(text) do
				draw.SimpleText(text, "DefaultFixedDropShadow", corner, corner + (i - 1) * 12, color_white)
			end
		end

		button.DoClick = function()
			net.Start("ply_take_item")
				net.WriteEntity(ragdoll or lootEnt)
				net.WriteString(wep)
			net.SendToServer()
		end

		button.DoRightClick = button.DoClick
	end

	local function setupAmmoButton(button, ammo)
		local text = game.GetAmmoName(ammo) or tostring(ammo)
		text = getText(text, button:GetWide() - corner * 2)

		local round = Material(AmmoTypes[tonumber(ammo)] or "vgui/hud/hmcd_person", "noclamp smooth")

		button.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and grey or black)
			surface.SetDrawColor(255, 255, 255, 128)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

			surface.SetMaterial(round)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(2, 2, w - 4, h - 4)

			for i, text in pairs(text) do
				draw.SimpleText(text, "DefaultFixedDropShadow", corner, corner + (i - 1) * 12, color_white)
			end
		end

		button.DoClick = function()
			net.Start("ply_take_ammo")
				net.WriteEntity(ragdoll or lootEnt)
				net.WriteFloat(tonumber(ammo))
			net.SendToServer()
		end

		button.DoRightClick = button.DoClick
	end

	local function reveal(entry)
		found[entry.key] = true

		if entry.wep then
			setupWeaponButton(entry.button, entry.wep, entry.weapon)
		else
			setupAmmoButton(entry.button, entry.ammo)
		end
	end

	local function nextSearch(start)
		current = table.remove(pending, 1)
		searchStart = start or CurTime()

		found.__progressKey = current and current.key or nil
		found.__progressStart = current and searchStart or nil
	end

	for _, entry in ipairs(entries) do
		local button = vgui.Create("DButton", frame)
		nextSlot(button)

		entry.button = button

		if found[entry.key] or lootingTime <= 0 then
			reveal(entry)
		else
			button.Paint = paintHidden(entry)
			button.DoClick = function() end
			button.DoRightClick = button.DoClick

			pending[#pending + 1] = entry
		end
	end

	if pending[1] and found.__progressKey == pending[1].key then
		nextSearch(found.__progressStart)
	else
		nextSearch()
	end

	function panel:Think()
		if not current then return end
		if CurTime() - searchStart < lootingTime then return end

		reveal(current)
		nextSearch()
	end

	timer.Create("hg_forget_inventory_" .. targetID, 60, 1, function() hg_searched[targetID] = nil end)
end)

hook.Add("PostCleanupMap", "hg_ForgetInventories", function()
	hg_searched = {}
end)
