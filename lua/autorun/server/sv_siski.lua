util.AddNetworkString("PlayJoinSound")

hook.Add("PlayerInitialSpawn", "PlayJoinSoundOnLoad", function(ply)
    timer.Simple(10, function()
        if IsValid(ply) then
            net.Start("PlayJoinSound")
            net.Send(ply)
        end
    end)
end)

if CLIENT then
    net.Receive("PlayJoinSound", function()
        surface.PlaySound("Realni_Pacani.wav")
    end)
end

util.AddNetworkString("PlayBanSound")

hook.Add("PlayerBanned", "PlayBanSoundOnBan", function(ply, admin, reason)
    net.Start("PlayBanSound")
    net.Broadcast()
end)

hook.Add("ULibPlayerBanned", "PlayBanSoundOnBan", function(ply, admin, reason, time)
    net.Start("PlayBanSound")
    net.Broadcast()
end)

-- Client-side code to receive the net message and play the sound
if CLIENT then
    net.Receive("PlayBanSound", function()
        surface.PlaySound("path/to/ban_sound.wav")
    end)
end
