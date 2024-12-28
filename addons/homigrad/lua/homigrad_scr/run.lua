if engine.ActiveGamemode() ~= "homigrad" then return end

AddCSLuaFile()

print("homigrad start.")

local start = SysTime()
hg.includeDir("homigrad_scr/")

print("homigrad structure end " .. math.Round(SysTime() - start, 3) .. "s")