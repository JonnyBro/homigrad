local menuCommands = {
	"goto", "bring", "return", "fake", "unfake", "revive", "slay", "freeze", "unfreeze", "god", "ungod", "spectate",
	"fullup", "stopbleed", "bleed", "organism", "setrole", "forceteam", "playerclass",
	"vomit", "virus", "russian_roulette", "scared", "kick", "ban"
}

local function can(cmd)
	return ULib ~= nil and ULib.ucl.query(LocalPlayer(), "ulx " .. cmd)
end

local function run(cmd, ply, ...)
	RunConsoleCommand("ulx", cmd, "$" .. ply:UserID(), ...)
end

local function confirm(label, ply, func)
	Derma_Query(
		language.GetPhrase("hg.adminmenu.confirm"):format(language.GetPhrase(label), ply:Nick()),
		language.GetPhrase("hg.adminmenu.title"),
		language.GetPhrase("hg.yes"), func,
		language.GetPhrase("hg.no")
	)
end

local function addOption(menu, label, cmd, func, icon)
	if not can(cmd) then return end

	local option = menu:AddOption(label, func)
	if icon then option:SetIcon(icon) end

	menu.hgCount = (menu.hgCount or 0) + 1

	return option
end

local function addSubMenu(menu, label, icon, build)
	local sub, option = menu:AddSubMenu(label)
	option:SetIcon(icon)

	build(sub)

	if (sub.hgCount or 0) == 0 then
		option:Remove()
		sub:Remove()

		return
	end

	menu.hgCount = (menu.hgCount or 0) + 1
end

function hg.CanUseAdminMenu()
	for _, cmd in ipairs(menuCommands) do
		if can(cmd) then return true end
	end

	return false
end

function hg.BuildAdminMenu(menu, ply)
	local alive = ply:Alive()
	local faked = alive and IsValid(ply:GetNWEntity("Ragdoll"))

	addSubMenu(menu, "#hg.adminmenu.teleport", "icon16/arrow_switch.png", function(sub)
		addOption(sub, "#hg.adminmenu.goto", "goto", function() run("goto", ply) end)
		addOption(sub, "#hg.adminmenu.bring", "bring", function() run("bring", ply) end)
		addOption(sub, "#hg.adminmenu.return", "return", function() run("return", ply) end)
	end)

	addSubMenu(menu, "#hg.adminmenu.state", "icon16/user.png", function(sub)
		if alive then
			if faked then addOption(sub, "#hg.adminmenu.unfake", "unfake", function() run("unfake", ply) end)
			else addOption(sub, "#hg.adminmenu.fake", "fake", function() run("fake", ply) end) end

			if ply:IsFrozen() then addOption(sub, "#hg.adminmenu.unfreeze", "unfreeze", function() run("unfreeze", ply) end)
			else addOption(sub, "#hg.adminmenu.freeze", "freeze", function() run("freeze", ply) end) end

			if ply:HasGodMode() then addOption(sub, "#hg.adminmenu.ungod", "ungod", function() run("ungod", ply) end)
			else addOption(sub, "#hg.adminmenu.god", "god", function() run("god", ply) end) end

			addOption(sub, "#hg.adminmenu.slay", "slay", function() confirm("#hg.adminmenu.slay", ply, function() run("slay", ply) end) end)
		else
			addOption(sub, "#hg.adminmenu.revive", "revive", function() run("revive", ply) end)
		end

		if ply ~= LocalPlayer() then
			addOption(sub, "#hg.adminmenu.spectate", "spectate", function() run("spectate", ply) end)
		end
	end)

	addSubMenu(menu, "#hg.adminmenu.health", "icon16/heart.png", function(sub)
		if alive then
			addOption(sub, "#hg.adminmenu.fullup", "fullup", function() run("fullup", ply) end)
			addOption(sub, "#hg.adminmenu.stopbleed", "stopbleed", function() run("stopbleed", ply) end)

			if can("bleed") then
				addSubMenu(sub, "#hg.adminmenu.bleed", "icon16/cut_red.png", function(bleed)
					for _, amount in ipairs({20, 50, 100}) do
						addOption(bleed, language.GetPhrase("hg.adminmenu.bleed.amount"):format(amount), "bleed", function() run("bleed", ply, amount) end)
					end
				end)
			end
		end

		addOption(sub, "#hg.adminmenu.organism", "organism", function() run("organism", ply) end)
	end)

	addSubMenu(menu, "#hg.adminmenu.role", "icon16/user_red.png", function(sub)
		for _, role in ipairs({"traitor", "armed", "innocent"}) do
			addOption(sub, "#hg.adminmenu.role." .. role, "setrole", function() run("setrole", ply, role) end)
		end
	end)

	addSubMenu(menu, "#hg.adminmenu.team", "icon16/group.png", function(sub)
		addOption(sub, "#hg.adminmenu.team.join", "forceteam", function() run("forceteam", ply, "Join Game") end)
		addOption(sub, "#hg.adminmenu.team.spectator", "forceteam", function() run("forceteam", ply, "Spectator") end)
	end)

	addSubMenu(menu, "#hg.adminmenu.class", "icon16/user_suit.png", function(sub)
		local classes = table.GetKeys(player.classList or {})
		table.sort(classes)
		table.insert(classes, 1, "none")

		for _, class in ipairs(classes) do
			addOption(sub, class, "playerclass", function() run("playerclass", ply, class) end)
		end
	end)

	addSubMenu(menu, "#hg.adminmenu.fun", "icon16/emoticon_tongue.png", function(sub)
		if alive then
			addOption(sub, "#hg.adminmenu.vomit", "vomit", function() run("vomit", ply) end)
			addOption(sub, "#hg.adminmenu.virus", "virus", function() run("virus", ply) end)
			addOption(sub, "#hg.adminmenu.roulette", "russian_roulette", function() run("russian_roulette", ply) end)
		end

		local scared = ply:GetNWBool("scared")
		addOption(sub, scared and "#hg.adminmenu.unscared" or "#hg.adminmenu.scared", "scared", function() run("scared", ply, scared and "0" or "1") end)
	end)

	if ply ~= LocalPlayer() then
		addSubMenu(menu, "#hg.adminmenu.punish", "icon16/exclamation.png", function(sub)
			addOption(sub, "#hg.adminmenu.kick", "kick", function() confirm("#hg.adminmenu.kick", ply, function() run("kick", ply) end) end)

			if can("ban") then
				addSubMenu(sub, "#hg.adminmenu.ban", "icon16/delete.png", function(ban)
					for _, info in ipairs({{"hour", 60}, {"day", 1440}, {"week", 10080}, {"perma", 0}}) do
						local label = "#hg.adminmenu.ban." .. info[1]

						addOption(ban, label, "ban", function()
							confirm("#hg.adminmenu.ban", ply, function() run("ban", ply, info[2]) end)
						end)
					end
				end)
			end
		end)
	end

	return (menu.hgCount or 0) > 0
end

local function targetFromEntity(ent)
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return ent end

	local ply = ent:GetNWEntity("RagdollController")
	if IsValid(ply) then return ply end

	ply = ent:GetNWEntity("OldRagdollController")
	if IsValid(ply) then return ply end
end

properties.Add("hg_admin", {
	MenuLabel = "#hg.adminmenu.title",
	MenuIcon = "icon16/shield.png",
	Order = -100,
	Filter = function(self, ent, ply)
		return IsValid(targetFromEntity(ent)) and hg.CanUseAdminMenu()
	end,
	MenuOpen = function(self, option, ent, tr)
		hg.BuildAdminMenu(option:AddSubMenu(), targetFromEntity(ent))
	end,
	Action = function() end
})
