local ammotypes = {
	["556x45mm"] = {
		name = "5.56x45 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 200,
		maxcarry = 120,
		minsplash = 10,
		maxsplash = 5
	},
	["762x39mm"] = {
		name = "7.62x39 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 400,
		maxcarry = 120,
		minsplash = 10,
		maxsplash = 5
	},
	["545x39mm"] = {
		name = "5.45x39 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 160,
		maxcarry = 120,
		minsplash = 10,
		maxsplash = 5
	},
	["12/70gauge"] = {
		name = "12/70 gauge",
		dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 350,
		maxcarry = 46,
		minsplash = 10,
		maxsplash = 5
	},
	["12/70beanbag"] = {
		name = "12/70 beanbag",
		dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 350,
		maxcarry = 46,
		minsplash = 10,
		maxsplash = 5
	},
	["9x19mm"] = {
		name = "9x19 mm Parabellum",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 10,
		maxsplash = 5
	},
	[".380"] = {
		name = ".380 ACP",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 90,
		maxcarry = 80,
		minsplash = 10,
		maxsplash = 5
	},
	["46x30mm"] = {
		name = "4.6x30 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 120,
		minsplash = 10,
		maxsplash = 5
	},
	["57x28mm"] = {
		name = "5.7x28 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 150,
		minsplash = 10,
		maxsplash = 5
	},
	[".44magnum"] = {
		name = ".44 Magnum",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 150,
		minsplash = 10,
		maxsplash = 5
	},
	["9x39mm"] = {
		name = "9x39 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 150,
		minsplash = 10,
		maxsplash = 5
	},
	["127x99mm"] = {
		name = "12.7x99 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 500,
		maxcarry = 80,
		minsplash = 10,
		maxsplash = 5
	}
}

local ammoents = {
	["556x45mm"] = {
		Material = "models/hmcd_ammobox_556",
		Scale = 1.2
	},
	["762x39mm"] = {
		Material = "mmodels/hmcd_ammobox_792",
		Scale = 1,
		Color = Color(95, 95, 95)
	},
	["545x39mm"] = {
		Material = "mmodels/hmcd_ammobox_792",
		Scale = 0.8,
		Color = Color(125, 155, 95)
	},
	["12/70gauge"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.1,
	},
	["12/70beanbag"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 0.9,
		Color = Color(255, 155, 55)
	},
	["9x19mm"] = {
		Material = "models/hmcd_ammobox_9",
		Scale = 0.8,
	},
	[".380"] = {
		Material = "models/hmcd_ammobox_9",
		Scale = 0.7,
	},
	["46x30mm"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 1,
	},
	[".44magnum"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 0.8,
	},
	["9x39mm"] = {
		Material = "models/hmcd_ammobox_9",
		Scale = 1,
		Color = Color(125, 155, 95)
	},
	["57x28mm"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 1.2,
		Color = Color(125, 155, 95)
	},
	["127x99mm"] = {
		Material = "models/hmcd_ammobox_556",
		Scale = 1.6
	},
}

print("[HG} AmmoTypes loaded!")

for k, v in pairs(ammotypes) do
	-- PrintTable(v)

	game.AddAmmoType(v)

	if CLIENT then language.Add(v.name .. "_ammo", v.name) end

	timer.Simple(1, function()
		local ammoent = {}
		ammoent.Base = "ammo_base"
		ammoent.PrintName = v.name
		ammoent.Category = "[HG] Ammo"
		ammoent.Spawnable = true
		ammoent.AmmoCount = 10
		ammoent.AmmoType = v.name
		ammoent.ModelMaterial = ammoents[k].Material
		ammoent.ModelScale = ammoents[k].Scale
		ammoent.Color = ammoents[k].Color or nil

		scripted_ents.Register(ammoent, "ent_ammo_" .. k)
	end)
end

timer.Simple(1, function()
	game.BuildAmmoTypes()
end)

if CLIENT then
	function AmmoMenu(ply)
		if not ply:Alive() then return end

		local ammodrop = 0

		local Frame = vgui.Create("DFrame")
		Frame:SetTitle("#hg.ammo.title")
		Frame:SetSize(200, 300)
		Frame:Center()
		Frame:MakePopup()
		Frame.Paint = function(self, w, h)
			draw.RoundedBox(5, 0, 0, w, h, Color(115, 115, 115))
			draw.RoundedBox(2, 0, 0, w, 25, Color(95, 95, 95))
			draw.RoundedBox(2, 0, 268, w, h, Color(95, 95, 95))
		end

		local DPanel = vgui.Create("DScrollPanel", Frame)
		DPanel:SetPos(5, 30)
		DPanel:SetSize(190, 215)
		DPanel.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(175, 175, 175))
		end

		local sbar = DPanel:GetVBar()
		function sbar:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(115, 115, 115))
		end

		function sbar.btnUp:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(145, 145, 145))
		end

		function sbar.btnDown:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(145, 145, 145))
		end

		function sbar.btnGrip:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(195, 195, 195))
		end

		local DermaNumSlider = vgui.Create("DNumSlider", Frame)
		DermaNumSlider:SetPos(10, 245)
		DermaNumSlider:SetSize(210, 25)
		DermaNumSlider:SetText("#hg.ammo.quantity")
		DermaNumSlider:SetMin(0)
		DermaNumSlider:SetMax(100)
		DermaNumSlider:SetDecimals(0)
		DermaNumSlider.OnValueChanged = function(self, value) ammodrop = math.Round(value) end

		local ammos = LocalPlayer():GetAmmo()

		for k, v in pairs(ammos) do
			local DermaButton = vgui.Create("DButton", DPanel)
			DermaButton:SetText(game.GetAmmoName(k) .. ": " .. v)
			DermaButton:SetPos(0, 0)
			DermaButton:Dock(TOP)
			DermaButton:DockMargin(5, 5, 5, 0)
			DermaButton:SetSize(120, 20)
			DermaButton.Paint = function(self, w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(225, 225, 225))
			end

			DermaButton.DoClick = function()
				net.Start("drop_ammo")
					net.WriteFloat(k)
					net.WriteFloat(math.min(ammodrop, v))
				net.SendToServer()

				Frame:Close()
			end

			DermaButton.DoRightClick = function()
				net.Start("drop_ammo")
					net.WriteFloat(k)
					net.WriteFloat(v)
				net.SendToServer()
				Frame:Close()
			end
		end

		local DLabel = vgui.Create("DLabel", Frame)
		DLabel:SetPos(10, 270)
		DLabel:SetText("#hg.ammo.drop")
		DLabel:SizeToContents()
	end

	concommand.Add("hg_ammomenu", function(ply, cmd, args) AmmoMenu(ply) end)
end

local ammolist = game.GetAmmoTypes()
local reverse = {
	["5.56x45 mm"] = "556x45mm",
	["7.62x39 mm"] = "762x39mm",
	["5.45x39 mm"] = "545x39mm",
	["12/70 gauge"] = "12/70gauge",
	["12/70 beanbag"] = "12/70beanbag",
	["9x19 mm Parabellum"] = "9x19mm",
	[".380 ACP"] = ".380",
	["4.6x30 mm"] = "46x30mm",
	["5.7x28 mm"] = "57x28mm",
	[".44 Magnum"] = ".44magnum",
	["9x39 mm"] = "9x39mm",
	["12.7x99 mm"] = "127x99mm",
	["AR2"] = "ar2",
	["XBowBolt"] = "XBowBolt"
}

if SERVER then
	util.AddNetworkString("drop_ammo")

	net.Receive("drop_ammo", function(len, ply)
		if not IsValid(ply) or not ply:Alive() or ply.unconscious then return end

		local ammotype = net.ReadFloat()
		local count = net.ReadFloat()
		local pos = ply:EyePos() + ply:EyeAngles():Forward() * 70
		local ammo = reverse[ammolist[ammotype]]
		count = count == 0 and ply:GetAmmoCount(ammotype) or math.min(count, ply:GetAmmoCount(ammotype))

		if ply:GetAmmoCount(ammotype) - count < 0 then
			net.Start("hg_sendchat_simple")
				net.WriteString("#hg.ammo.toomany")
			net.Send(ply)

			return
		end

		if count < 1 then
			net.Start("hg_sendchat_simple")
				net.WriteString("#hg.ammo.notenough")
			net.Send(ply)

			return
		end

		if not ammo then
			net.Start("hg_sendchat_simple")
				net.WriteString("#hg.ammo.notfound")
			net.Send(ply)

			return
		end

		local AmmoEnt = ents.Create("ent_ammo_" .. string.lower(ammo))
		if not IsValid(AmmoEnt) then
			AmmoEnt = ents.Create("item_ammo_" .. string.lower(ammo))
		end

		if not IsValid(AmmoEnt) then return end

		AmmoEnt:SetPos(pos)
		AmmoEnt:Spawn()

		if string.StartsWith(AmmoEnt:GetClass(), "ent_ammo") then AmmoEnt.AmmoCount = count end

		ply:SetAmmo(ply:GetAmmoCount(ammotype) - count, ammotype)
		ply:EmitSound("snd_jack_hmcd_ammobox.wav", 75, math.random(80, 90), 1, CHAN_ITEM)
	end)
end