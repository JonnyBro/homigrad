

local PANEL = {}



surface.CreateFont( 'SolidMapVote.Title', { font = 'Roboto', size = ScreenScale( 20 ), weight = 1000 } )

surface.CreateFont( 'SolidMapVote.Time', { font = 'Roboto', size = ScreenScale( 7 ), weight = 1, italic = true } )

surface.CreateFont( 'SolidMapVote.SubTitle', { font = 'Roboto', size = ScreenScale( 9 ), weight = 1000, italic = true } )



function PANEL:Init()

    self.maps = {}

    self.mapButtons = {}

    self.startTime = RealTime()

    self.endTime = self.startTime + SolidMapVote[ 'Config' ][ 'Length' ]

    self.layoutPaused = false

    self.finished = false

    self.subTitleText = ''
-- DUMPED WITH GMODLUAINJECTOR MADE BY GAZTOOF FOR UNKNOWNCHEATS :)


    self:SetPos( 0, 0 )

    self:SetSize( ScrW(), ScrH() )



    if SolidMapVote[ 'Config' ][ 'Enable Extend' ] then

        self.extend = vgui.Create( 'SolidMapVoteButton', self )

        self.extend:SetLabel( 'extend' )

        self.extend:SetImage( SolidMapVote[ 'Config' ][ 'Extend Image' ] )

    end



    if SolidMapVote[ 'Config' ][ 'Enable Random' ] then

        self.random = vgui.Create( 'SolidMapVoteButton', self )

        self.random:SetLabel( 'random' )

        self.random:SetImage( SolidMapVote[ 'Config' ][ 'Random Image' ] )

    end



    hook.Add( 'SolidMapVote.WinningMaps', 'SolidMapVote.WinningMaps.main', function( winningMaps, realWinner, fixedWinner )

        self.finished = true



        local realDisplayName = string.upper( SolidMapVote.GetMapConfigInfo( realWinner ).displayname )

        local fixedDisplayName = string.upper( SolidMapVote.GetMapConfigInfo( fixedWinner ).displayname )



        if #winningMaps > 1 then

            if realWinner == 'extend' then

                self.subTitleText = 'MAP HAS BEEN EXTENDED AS TIE BREAKER!'

            elseif realWinner == 'random' then

                self.subTitleText = fixedDisplayName .. ' HAS BEEN CHOSEN RANDOMLY AS TIE BREAKER!'

            else

                self.subTitleText = realDisplayName .. ' HAS BEEN CHOSEN AS TIE BREAKER!'

            end

        elseif realWinner == 'extend' then

            self.subTitleText = 'MAP HAS BEEN EXTENDED!'

        elseif realWinner == 'random' then

            self.subTitleText = fixedDisplayName .. ' WAS RANDOMLY CHOSEN!'

        else

            self.subTitleText = 'WINNING MAP IS ' .. realDisplayName .. '!'

        end

    end )

end



function PANEL:SetMaps( maps )

    self.maps = maps



    self:CreateMapButtons()

end



function PANEL:CreateMapButtons()

    for k, map in pairs( self.maps ) do

        local btn = vgui.Create( 'SolidMapVoteMap', self )

        btn:SetMap( map )



        table.insert( self.mapButtons, btn )

    end

end



function PANEL:PauseLayout( bool )

    self.layoutPaused = bool

end



function PANEL:PerformLayout( w, h )

    if self.layoutPaused then return end -- Pause the layout when buttons are animating



    local buttonWidth = w * 0.13

    local buttonHeight = buttonWidth
--   CQxbMCbRbyA



    local startPosX = 20

    local startPosY = 90



    for k, btn in pairs( self.mapButtons ) do

        btn:SetSize(buttonWidth,buttonHeight)

        btn:SetPos(startPosX,startPosY)



        startPosX = startPosX + btn:GetWide() + 20



        if startPosX + btn:GetWide() >= w then

            startPosX = 20

            startPosY = startPosY + btn:GetTall() + 20

        end



        -- Set some return values for the animation after positioning

        local x, y = btn:GetPos()

        btn:SetOriginalSize( buttonWidth, buttonHeight )

        btn:SetOriginalPos( x, y )

    end



    local buttonSize = buttonHeight*0.3

    local buttonYPos = h - buttonSize - 20

    local buttonXPos = w * 0.5



    -- Reposition and size the extend button

    if SolidMapVote[ 'Config' ][ 'Enable Extend' ] then

        self.extend:SetPos( buttonXPos, buttonYPos )

        self.extend:SetSize( buttonWidth, buttonSize )



        -- Set some return values for the animation after positioning

        self.extend:SetOriginalSize( buttonWidth, buttonSize )

        self.extend:SetOriginalPos( buttonXPos, buttonYPos )

    end



    -- Reposition and size the random button

    if SolidMapVote[ 'Config' ][ 'Enable Random' ] then

        self.random:SetPos( buttonXPos, buttonYPos )

        self.random:SetSize( buttonWidth, buttonSize )



        -- if the extend button is there, move this one to the left of it

        if ValidPanel( self.extend ) then

            self.random:MoveLeftOf( self.extend, 20 )

        end



        -- Set some return values for the animation after positioning

        local x, y = self.random:GetPos()

        self.random:SetOriginalSize( buttonWidth, buttonSize )

        self.random:SetOriginalPos( x, y )

    end

end



function PANEL:Paint( w, h )

    local timeRemainingDelta = (self.endTime - RealTime()) / SolidMapVote[ 'Config' ][ 'Length' ]

    local timeRemainingFormatted = string.FormattedTime( math.max( math.Round( self.endTime - RealTime(), 2 ), 0 ), '%02i:%02i:%02i' )



    local startY = 15



    local titleW, titleH =

    draw.SimpleTextOutlined( 'MAPVOTE', 'SolidMapVote.Title', w*0.11, startY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )

    draw.SimpleTextOutlined( 'MAPVOTE', 'SolidMapVote.Title', w*0.11, startY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )



    local timeW, timeH =

    draw.SimpleTextOutlined( timeRemainingFormatted, 'SolidMapVote.Time', w*0.11 + titleW + 10, startY + titleH*0.12, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )

    draw.SimpleTextOutlined( timeRemainingFormatted, 'SolidMapVote.Time', w*0.11 + titleW + 10, startY + titleH*0.12, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )



    draw.SimpleTextOutlined( self.subTitleText, 'SolidMapVote.SubTitle', w*0.11 + titleW + 10, startY + titleH*0.12 + timeH*0.9, Color( 233, 212, 96 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )

    draw.SimpleTextOutlined( self.subTitleText, 'SolidMapVote.SubTitle', w*0.11 + titleW + 10, startY + titleH*0.12 + timeH*0.9, Color( 233, 212, 96 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )



    if self.finished then return end



    -- localizing so I can make the shadows easier

    local boxWidth = Lerp( timeRemainingDelta, 0, w - (w*0.23) - (titleW+10) )

    local boxHeight = titleH - timeH - 20

    local boxX, boxY = w*0.11 + titleW + 10, startY + h*0.027



    draw.RoundedBox( 0, boxX-2, boxY-2, boxWidth+4, boxHeight+4, Color( 0, 0, 0, 30 ) )

    draw.RoundedBox( 0, boxX-1, boxY-1, boxWidth+2, boxHeight+2, Color( 0, 0, 0, 60 ) )

    draw.RoundedBox( 0, boxX, boxY, boxWidth, boxHeight, color_white )

end



function PANEL:Think()

    gui.EnableScreenClicker( true )

end



vgui.Register( 'SolidMapVote', PANEL )

