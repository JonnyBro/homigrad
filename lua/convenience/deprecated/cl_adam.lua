// DEPRECATED, DO NOT USE

-- Create a simple derma frame
function conv.dermaFrame( title, width, height )
    local frame = vgui.Create("DFrame")
    frame:SetPos( (ScrW()*0.5)-width*0.5, (ScrH()*0.5)-height*0.5 )
    frame:SetSize(width, height)
    frame:SetTitle(title)
    frame:MakePopup()
    return frame
end