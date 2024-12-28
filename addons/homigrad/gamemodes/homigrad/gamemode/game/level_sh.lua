LevelList = {}

function TableRound(name) return _G[name or roundActiveName] end

timer.Simple(0,function()
    if roundActiveName == nil then --and not (string.find(string.lower(game.GetMap()), "rp_desert_conflict")) then
        roundActiveName = "homicide"
        roundActiveNameNext = "homicide"
        StartRound()
    end
end)