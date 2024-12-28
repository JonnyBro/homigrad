local soundsTable = {};
local blockedGroups = {};
net.Receive("sendsoundgroups", function ()
	blockedGroups = net.ReadTable();
end);
function OpenPanelSounds( ply, cmd, args, str )
	if (blockedGroups) then
		if table.HasValue( blockedGroups, string.lower(tostring(ply:GetUserGroup()))) then
			chat.AddText( Color( 255, 127, 0 ), "You are not allowed to open the soundlist." )
			return;
		end
		if (IsValid(SoundMain)) then
			SoundMain:Remove();
		end
		SoundMain = vgui.Create( "DFrame" )
		SoundMain:SetPos( 50, 50 )
		SoundMain:SetSize( 350, 550 )
		SoundMain:SetTitle( "Sound List" )
		SoundMain:SetVisible( true )
		SoundMain:SetDraggable( true )
		SoundMain:ShowCloseButton( false )
		timer.Simple(8, function ()
			if (IsValid(SoundMain)) then // Make sure we still have the menu.
				SoundMain:ShowCloseButton(true); // Fail-safe. If we don't receive a net message we can't close the menu.
			end
		end);
		SoundMain:MakePopup()
		SoundMain:Center()
		local list = vgui.Create( "DListView" )
		list:SetParent( SoundMain )
		list:SetPos( 4, 27 )
		list:SetSize( 342, 519 )
		list:SetMultiSelect( false )
		list:AddColumn( "Sound" )
		list.OnRowRightClick = function( main, line )
			local menu = DermaMenu()
				menu:AddOption( "Play for all", function()
					RunConsoleCommand( "ulx", "playsound", tostring( list:GetLine( line ):GetValue( 1 ) ) )
				end ):SetIcon("icon16/control_play_blue.png")
				menu:AddOption( "Play for self", function()
					RunConsoleCommand( "play", tostring( list:GetLine( line ):GetValue( 1 ) ) )
					chat.AddText( Color( 151, 211, 255 ), "Sound ", Color( 0, 255, 0 ), tostring( list:GetLine( line ):GetValue( 1 ) ), Color( 151, 211, 255 ), " playing locally." )
				end ):SetIcon("icon16/control_play.png")
				menu:AddOption( "Stop all sounds", function()
					RunConsoleCommand( "ulx", "stopsounds" )
				end ):SetIcon("icon16/control_stop_blue.png")
				menu:AddOption( "Stop sounds for self", function()
					RunConsoleCommand( "stopsound" )
					chat.AddText( Color( 151, 211, 255 ), "Stopped sounds locally." )
				end ):SetIcon("icon16/control_stop.png")
			menu:Open()
		end
		list:AddLine("Please wait while the list populates...");
		net.Start("sendsoundlist");
		net.SendToServer();
		net.Receive("sendsoundlist", function ()
			if (IsValid(SoundMain)) then
				soundsTable = net.ReadTable();
				list:RemoveLine(1);
				for k, v in pairs(soundsTable) do
					list:AddLine(v);
				end
				list:SortByColumn(1, false);
				SoundMain:ShowCloseButton(true);
			end
		end);
	else
		chat.AddText(Color(222, 49, 99), "[FATAL]: No blocked groups detected! Backing out...");
	end
end
concommand.Add( "menu_sounds", OpenPanelSounds )
