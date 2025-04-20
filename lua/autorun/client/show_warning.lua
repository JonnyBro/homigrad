if engine.ActiveGamemode() ~= "homigrad" then return end

hook.Add("InitPostEntity", "hg_BindFakeCommandWarning", function()
	if cookie.GetString("jhg_bindfakewarning") == "1" then return end

	local frame = vgui.Create("DFrame")
	frame:SetTitle("#hg.warning.title")
	frame:ShowCloseButton(false)
	frame:SetSize(450, 300)
	frame:Center()
	frame:MakePopup()
	frame:SetBackgroundBlur(true)

	local text = vgui.Create("DLabel", frame)
	text:SetPos(20, 40)
	text:SetSize(frame:GetWide() - 40, 150)
	text:SetText("#hg.warning.text")
	text:SetWrap(true)
	text:SetContentAlignment(7)
	text:SetFont("DermaDefaultBold")

	local checkBox = vgui.Create("DCheckBoxLabel", frame)
	checkBox:SetPos(20, 200)
	checkBox:SetText("#hg.warning.check")
	checkBox:SetValue(0)
	checkBox:SizeToContents()

	local closeButton = vgui.Create("DButton", frame)
	closeButton:SetText("#hg.warning.close")
	closeButton:SetPos(frame:GetWide() / 2 - 75, 240)
	closeButton:SetSize(150, 30)
	closeButton:SetEnabled(false)

	closeButton.DoClick = function()
		if input.LookupBinding("fake") then
			cookie.Set("jhg_bindfakewarning", "1")

			frame:Close()
		else
			closeButton:SetTextColor(Color(255, 50, 50))
			closeButton:SetText("#hg.warning.no")

			timer.Simple(2, function()
				if IsValid(closeButton) then
					closeButton:SetTextColor(Color(0, 0, 0))
					closeButton:SetText("#hg.warning.close")
				end
			end)
		end
	end

	checkBox.OnChange = function()
		closeButton:SetEnabled(checkBox:GetChecked())
	end
end)