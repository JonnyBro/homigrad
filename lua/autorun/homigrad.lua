if engine.ActiveGamemode() ~= "homigrad" then return end

hg = hg or {}

include("homigrad_scr/loader.lua")
include("homigrad_scr/run.lua")