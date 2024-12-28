
surface.CreateFont( "RageFontEsEs", {
    font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 85,
    weight = 700,
    blursize = 0,
    shadow = true,
})




function rageall_text()
    local rage = Color(255,89,89,0)
    local lox = 0
    
    print("start rage text")-- DUMPED WITH GMODLUAINJECTOR MADE BY GAZTOOF FOR UNKNOWNCHEATS :)
    hook.Add("HUDPaint", "RESADLLLAS", function()
        rage.a = lox
        lox = Lerp(.005, lox, 255)
        print(rage.a)
        draw.SimpleText("РЕЗЬНЯ", "RageFontEsEs", ScrW()/2, ScrH()-150, rage, 1, 1)
    end)

    timer.Simple(5, function()
        hook.Remove("HUDPaint", "RESADLLLAS")
        print("End rage text")
    end)
end

concommand.Add("ragetest", rageall_text)



SolidMapVote.isOpen = SolidMapVote.isOpen or false
SolidMapVote.isNominating = SolidMapVote.isNominating or false

function SolidMapVote.open( maps )
    SolidMapVote.close()
    
    SolidMapVote.isOpen = true
    gui.EnableScreenClicker( SolidMapVote.isOpen )

    SolidMapVote.Menu = vgui.Create( 'SolidMapVote' )
    SolidMapVote.Menu:SetMaps( maps )

    /*sound.PlayURL("https://rate.space-host.ru/hom/golos.mp3","mono",function(s)
        if IsValid(s) then
            s:SetPos(LocalPlayer():GetPos())
            s:SetVolume(0.5)
            s:Play()
        end
    end)*/

end

function SolidMapVote.close()
    if ValidPanel( SolidMapVote.Menu ) then
        SolidMapVote.isOpen = false
        SolidMapVote.Menu:Remove()

        gui.EnableScreenClicker( SolidMapVote.isOpen )
    end
end

function SolidMapVote.GetMapConfigInfo( map )
    for _, mapData in pairs( SolidMapVote[ 'Config' ][ 'Specific Maps' ] ) do
        if map == mapData.filename then
            return mapData
        end
    end

    return {
        filename = map,
        displayname = string.Replace( map, '_', ' ' ),
        image = SolidMapVote[ 'Config' ][ 'Missing Image' ],
        width = SolidMapVote[ 'Config' ][ 'Missing Image Size' ].width,
        height = SolidMapVote[ 'Config' ][ 'Missing Image Size' ].height
    }
end

hook.Add( 'PlayerBindPress', 'SolidMapVote.StopMovement', function( ply, bind )
    if ValidPanel( SolidMapVote.Menu ) and--   C/Yf-ajVLn/

       SolidMapVote.Menu:IsVisible() and
       bind != 'solidmapvote_test' and
       (bind != 'messagemode' and SolidMapVote[ 'Config' ][ 'Enable Chat' ]) and
       (bind != 'messagemode2' and SolidMapVote[ 'Config' ][ 'Enable Chat' ]) and
       (bind != '+voicerecord' and SolidMapVote[ 'Config' ][ 'Enable Voice' ])
    then
        return true
    end
end )

local matBlur = Material( 'pp/blurscreen' )
hook.Add( 'HUDPaint', 'SolidMapVote.DrawBackgroundBlur', function()
    if SolidMapVote.isOpen then
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( matBlur )

        for i = 1, 3 do
            matBlur:SetFloat( '$blur', i )
            matBlur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end
    end
end )

concommand.Add( 'solidmapvote_nomination_menu', function()
    -- Check for reasons to not open the menu or remove it
    if SolidMapVote.isOpen then return end
    if SolidMapVote.isNominating then
        if ValidPanel( SolidMapVote.Nominate ) then
            SolidMapVote.Nominate:Remove()
            SolidMapVote.isNominating = false
            gui.EnableScreenClicker( SolidMapVote.isNominating )
        end

        return
    end

    SolidMapVote.isNominating = true
    gui.EnableScreenClicker( SolidMapVote.isNominating )
    SolidMapVote.Nominate = vgui.Create( 'SolidMapVoteNomination' )
end )

concommand.Add( 'solidmapvote_close_ui', function()
    SolidMapVote.close()
end )
