// INTERNAL, DO NOT USE


util.AddNetworkString("ConvStrip")
util.AddNetworkString("ConvGiveAmmo")


net.Receive("ConvStrip", function(len, ply)
    ply:StripWeapons()
    ply:Give("weapon_physgun")
    ply:Give("gmod_camera")
    ply:Give("gmod_tool")
    ply:Give("weapon_physcannon")
end)


net.Receive("ConvGiveAmmo", function(len, ply)
    if !ply:IsAdmin() then return end
    for ammoid, ammoname in pairs(game.GetAmmoTypes()) do
        ply:GiveAmmo(game.GetCurrentAmmoMax(ammoid), ammoname)
    end
end)