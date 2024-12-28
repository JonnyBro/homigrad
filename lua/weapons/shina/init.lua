if engine.ActiveGamemode() == "homigrad" then
    include("shared.lua")

    SWEP.Dealy = 0.25

    function SWEP:PrimaryAttack()
        self:SetNextPrimaryFire(CurTime() + self.Dealy)
        self:SetNextSecondaryFire(CurTime() + self.Dealy)

        local owner = self:GetOwner()
        if self:FixLegs(owner) then 
            owner:SetAnimation(PLAYER_ATTACK1)
            self:Remove() 
            self:GetOwner():SelectWeapon("weapon_hands") 
        end
    end

    function SWEP:SecondaryAttack()
        self:SetNextPrimaryFire(CurTime() + self.Dealy)
        self:SetNextSecondaryFire(CurTime() + self.Dealy)

        local owner = self:GetOwner()
        local trace = self:GetEyeTraceDist(150)
        local ent = trace.Entity
        ent = (ent:IsPlayer() and ent) or (RagdollOwner(ent)) or (ent:GetClass() == "prop_ragdoll" and ent)
        if not ent then return end

        if self:FixLegs(ent) then
            if ent:IsPlayer() then
                local dmg = DamageInfo()
                dmg:SetDamage(-5)
                dmg:SetAttacker(self)

                local att = self:GetOwner()

                if GuiltLogic(att, ent, dmg, true) then
                    att.Guilt = math.max(att.Guilt - 20, 0)
                end
            end
            owner:SetAnimation(PLAYER_ATTACK1)
            self:Remove()
            self:GetOwner():SelectWeapon("weapon_hands")
        end
    end

    function SWEP:GetEyeTraceDist(dist)
        local owner = self:GetOwner()
        if not owner or not owner:IsValid() then return end

        local trace = util.TraceLine({
            start = owner:EyePos(),
            endpos = owner:EyePos() + owner:EyeAngles():Forward() * dist,
            filter = owner
        })

        return trace
    end

    local healsound = Sound("snd_jack_bandage.wav")

    function SWEP:FixLegs(ent)
        if not ent or not ent:IsPlayer() then 
            sound.Play(healsound, ent:GetPos(), 75, 100, 0.5) 
            return true 
        end

        if ent.LeftLeg then
            ent.LeftLeg = math.min(ent.LeftLeg + 1, 1)
        end

        if ent.RightLeg then
            ent.RightLeg = math.min(ent.RightLeg + 1, 1)
        end

        sound.Play(healsound, ent:GetPos(), 75, 100, 0.5)
        return true
    end
end
