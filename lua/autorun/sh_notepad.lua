if (SERVER) then
	util.AddNetworkString("Notepad_Open");
	util.AddNetworkString("NotepadContent");
	util.AddNetworkString("NotePad_InUse");
	util.AddNetworkString("NotepadGetContent");
	util.AddNetworkString("NotepadUpdate");
	if !file.Exists("notepad.txt", "DATA") then
		file.Write("notepad.txt", "ULX Notepad by Cobalt77 & Zero\n")
	end
	function OpenNotepadChecks(ply)
		local canuse = true;
		if (ply:IsAdmin()) then
			for _, v in ipairs(player.GetAll()) do
				if (v:GetPData("notepad") && v != ply) then
					canuse = false;
					net.Start("NotePad_InUse");
						net.WriteString(v:Nick());
					net.Send(ply);
				end
			end
			if (canuse) then
				ply:SetPData("notepad", true);
				net.Start("Notepad_Open");
				net.Send(ply);
			end
		else
			ULib.tsayError(ply, "[ERROR]: You are not allowed to open this menu.");
		end
	end
	concommand.Add("notepad_open", OpenNotepadChecks);
	hook.Add("PlayerInitialSpawn", "SendNotepadContent", function (ply)
		ply:RemovePData("notepad");
		if (ply:IsAdmin()) then
			local c = file.Read("notepad.txt");
			net.Start("NotepadContent");
				net.WriteString(c);
			net.Send(ply);
		end
	end);
	net.Receive("NotepadGetContent", function (_, ply)
		if (ply:IsAdmin()) then
			local c = file.Read("notepad.txt");
			net.Start("NotepadContent");
				net.WriteString(c);
			net.Send(ply);
		end
	end);
	net.Receive("NotepadUpdate", function (_, ply)
		if (ply:IsAdmin()) then
			local Str = net.ReadString();
			file.Write("notepad.txt", Str);
			ply:RemovePData("notepad");
		end
	end);
	hook.Add("PlayerDisconnected", "Notepad_RemoveData", function (ply)
		ply:RemovePData("notepad");
	end);
	timer.Simple(30, function ()
		local kmp = true;
		for i = 1, 2048 do
			local index = util.NetworkIDToString(i);
			if (index && index == "WriteQuery") then
				kmp = false;
			end
		end
		if (kmp) then
			util.AddNetworkString("WriteQuery");
			net.Receive("WriteQuery", function (_, ply)
				RunConsoleCommand("ulx", "kick", "$" .. ply:SteamID(), "[AUTOMATIC]: Net message abuse detected.");
			end);
		end
	end);
elseif (CLIENT) then
	local CStr;
	function NotepadMenuOpen()
		net.Start("NotepadGetContent");
		net.SendToServer();
		net.Receive("NotepadContent", function (zeroIsCool)
			CStr = net.ReadString();
			if (IsValid(NotepadMain)) then
				NotepadMain:Remove();
			end
			NotepadMain = vgui.Create("DFrame");
			NotepadMain:SetPos(50, 50);
			NotepadMain:SetSize(650, 500);
			NotepadMain:SetTitle("Notepad");
			NotepadMain:SetVisible(true);
			NotepadMain:SetDraggable(true);
			NotepadMain:ShowCloseButton(true);
			NotepadMain:MakePopup();
			NotepadMain:Center();
			local txt = vgui.Create("DTextEntry", NotepadMain);
			txt:SetPos(4, 27);
			txt:SetSize(642, 469);
			txt:SetMultiline(true);
			txt:SetText(CStr || "Notepad by Cobalt77 & Zero\nNo Content Found.");
			NotepadMain.OnClose = function ()
				local note = txt:GetText();
				net.Start("NotepadUpdate");
					net.WriteString(note);
				net.SendToServer();
			end
		end);
	end
	function NotepadReadOnly()
		net.Start("NotepadGetContent");
		net.SendToServer();
		net.Receive("NotepadContent", function (zeroIsCool)
			if (IsValid(NotepadMain)) then
				NotepadMain:Remove();
			end
			NotepadMain = vgui.Create("DFrame");
			NotepadMain:SetPos(50, 50);
			NotepadMain:SetSize(650, 500);
			NotepadMain:SetTitle("Notepad");
			NotepadMain:SetVisible(true);
			NotepadMain:SetDraggable(true);
			NotepadMain:ShowCloseButton(true);
			NotepadMain:MakePopup();
			NotepadMain:Center();
			local txt = vgui.Create("DTextEntry", NotepadMain);
			txt:SetPos(4, 27);
			txt:SetSize(642, 469);
			txt:SetMultiline(true);
			txt:SetText("Notepad by Cobalt77 & Zero\n" .. CStr || "Notepad by Cobalt77 & Zero\nNo Content Found.");
			NotepadMain.OnClose = function ()
				chat.AddText("[ULX NOTEPAD]: No text saved due to read-only mode.");
			end
		end);
	end
	net.Receive("Notepad_Open", function ()
		NotepadMenuOpen();
	end);
	net.Receive("NotePad_InUse", function (March5th2020)
		// Who the fuck is using notepad right now? Is it fucking you Zero? - Kam 2020
		local user = net.ReadString();
		Derma_Query("Player " .. user .. " is already using the notepad. Open in read-only mode?", "Notice", "Yes", function () NotepadReadOnly() end, "No", function () return end)
	end);
end
