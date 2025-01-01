if not ConVarExists("alternate_sprint_anim") then
	CreateClientConVar("alternate_sprint_anim", "1", true, false, "Enable/Disable the animation override for when sprinting without a weapon?", 0, 1)
end

if not ConVarExists("alternate_crouch_anim") then
	CreateClientConVar("alternate_crouch_anim", "1", true, false, "Enable/Disable the animation override for when crouching without a weapon?", 0, 1)
end

hook.Add("CalcMainActivity", "Alter Crouch and Run Anim", function(Player, Velocity)
	local activeWeapon = Player:GetActiveWeapon()
	if Player:IsOnGround() and Player:GetRunSpeed() >= 350 and GetConVar("alternate_sprint_anim"):GetInt() == 1 and ((IsValid(activeWeapon) and (activeWeapon:GetHoldType() == "normal" or activeWeapon:GetClass() == "weapon_hands")) or activeWeapon == NULL) then return ACT_HL2MP_RUN_FAST, -1 end

	if Player:IsOnGround() and ((IsValid(activeWeapon) and (activeWeapon:GetHoldType() == "normal" or activeWeapon:GetClass() == "weapon_hands")) or activeWeapon == NULL) and Player:Crouching() and Velocity:Length2DSqr() < 1 and Player:GetSequence() ~= Player:LookupSequence("pose_ducking_02") and Player:GetSequence() ~= Player:LookupSequence("run_all_01") and Player:GetSequence() ~= Player:LookupSequence("walk_all") and Player:GetSequence() ~= Player:LookupSequence("cwalk_all") and GetConVar("alternate_crouch_anim"):GetInt() == 1 then
		local crouch_anim = Player:LookupSequence("pose_ducking_01")

		return ACT_MP_JUMP, crouch_anim
	else
		return
	end
end)