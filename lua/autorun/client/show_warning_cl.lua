net.Receive("ShowWelcomeWindow", function()
	--Create main frame
	local frame = vgui.Create("DFrame")
	frame:SetTitle("#hg.warning.title")
	frame:ShowCloseButton(false)
	frame:SetSize(400, 250)
	frame:Center()
	frame:MakePopup()
	--Create frame text
	local text = vgui.Create("DLabel", frame)
	text:SetPos(10, 20)
	text:SetSize(360, 120)
	text:SetText("#hg.warning.text")
	text:SetWrap(true)
	text:SetContentAlignment(5)
	-- Create the checkbox
	local checkBox = vgui.Create("DCheckBoxLabel", frame)
	checkBox:SetPos(10, 165)
	checkBox:SetText("#hg.warning.check")
	checkBox:SetValue(0)
	checkBox:SizeToContents()
	-- Create a close button to close the window
	local closeButton = vgui.Create("DButton", frame)
	closeButton:SetText("#hg.warning.button")
	closeButton:SetPos(120, 200)
	closeButton:SetSize(150, 30)
	closeButton:SetEnabled(false)
	-- Enable confirm button only if checkbox is checked
	checkBox.OnChange = function()
		if closeButton:IsEnabled() then 
			closeButton:SetEnabled(false)
		else 
			closeButton:SetEnabled(true) 
		end
	end

	-- Define the action for closeButton
	-- Don't allow player to skip this part until he binds `FAKE`
	closeButton.DoClick = function()
		if input.LookupBinding("fake") then
			if timer.Exists("FakeCheck") then timer.Remove("FakeCheck") frame:Close()
			else frame:Close() end
		else
			closeButton:SetText("[ ◄ BIND G FAKE ► ]") -- translation doesn't work here wtf	
			timer.Create("FakeCheck", 2, 0, function() -- resets text back.
				closeButton:SetText("#hg.warning.button")
			end)
		end
	end
end)