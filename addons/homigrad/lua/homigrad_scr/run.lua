AddCSLuaFile()

print("homigrad_scr is loading...")

local start = SysTime()
hg.includeDir("homigrad_scr/")

print("homigrad_scr loaded. Time used: " .. math.Round(SysTime() - start, 3) .. "s")