-- Convars are here for dedicated servers... (who cares that they are replicated :shrug:)

CreateConVar("hg_LootAlive", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Toggles ability to loot alive players that are faking", 0, 1)
CreateConVar("hg_SearchTime", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Time between discovering items in the inventory search", 0, 10)
