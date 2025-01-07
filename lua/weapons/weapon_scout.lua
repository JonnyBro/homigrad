SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "Scout"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "A good sniper rifle."
SWEP.Category 				= "Weapon"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 65
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "snd_jack_hmcd_snp_close.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_snp_far.wav"
SWEP.Primary.Force = 65
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.5
SWEP.Sight = true
SWEP.TwoHands = true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "ar2"

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/w_jmod_r700.mdl"
SWEP.WorldModel				= "models/weapons/w_jmod_r700.mdl"

function SWEP:ApplyEyeSpray()
    self.eyeSpray = self.eyeSpray - Angle(1,math.Rand(-1,1),0)
end

if CLIENT then
    local rtsize = 512
    local rtmat = GetRenderTarget("huy-glass", rtsize, rtsize, false)

    function SWEP:InitAdd()
        --self.scope_mat = Material("models/weapons/v_models/snip_awp/v_awp_scope")

        --self.lpos = Vector(-14,0,0)
        --self.lang = Angle(0,180,0)
    end

    SWEP.lpos = Vector(-14,0,0)
    SWEP.lang = Angle(0,180,0)

    SWEP.scope_mat = Material("models/weapons/v_models/snip_awp/v_awp_scope")

    SWEP.opticpos = Vector(0, 0, 8)
    SWEP.opticang = Angle(0, -90, 0)

    SWEP.opticmodel = "models/weapons/arccw/atts/magnus.mdl"
    SWEP.opticmodel2 = "models/weapons/arccw/atts/magnus_hsp.mdl"

    function SWEP:DrawWorldModelAdd(worldModel)
        local model = worldModel or self.worldModel or self

        if not IsValid(self.optic) then
            self.optic = ClientsideModel(self.opticmodel)
            self.optic:SetSubMaterial(1, "null")
        end

        if not IsValid(self.optic_scope) then
            self.optic_scope = ClientsideModel(self.opticmodel2)

            --self.optic_scope:SetSubMaterial(0, "null")
            --self.optic_scope:SetSubMaterial(1, "!scope_mat1")
        end

        local mdl = self.optic
        local mdl2 = self.optic_scope
        mdl:SetNoDraw(true)
        mdl2:SetNoDraw(true)

        local pos, ang = LocalToWorld(self.opticpos, self.opticang, model:GetPos(), model:GetAngles())

        mdl:SetPos(pos)
        mdl:SetAngles(ang)
        if model:GetMaterial() ~= "null" then mdl:DrawModel() end

        render.SetLightingMode(1)
        local pos, ang = LocalToWorld(self.lpos,self.lang,pos,ang)
        mdl2:SetPos(pos)
        mdl2:SetAngles(ang)
        if model:GetMaterial() ~= "null" then mdl2:DrawModel() end

        render.SetLightingMode(0)
    end

    local vector_one = Vector( 1, 1, 1 )

    local scope = Material("pwb/sprites/scope")
    local sight_alpha = 0

    SWEP.spos = Vector(-15, 0, 1)
    SWEP.sang = Angle(0, 0, 0)
    SWEP.zoomfov = 7

    function SWEP:DrawHUDAdd()
        local ply = self:GetOwner()
        local pos, ang = self:GetTrace()
        ang:RotateAroundAxis(ang:Forward(), -90)

        local pos, ang = LocalToWorld(self.spos, self.sang, pos, ang)

        self.scope_mat:SetTexture("$basetexture", rtmat)

        local view = render.GetViewSetup()

        local swayang = (diffang2 or Angle(0, 0, 0)) * 4
        swayang[3] = 0

        local tr = util.QuickTrace(ply:EyePos(),pos - ply:EyePos(), ply)
        pos = tr.HitPos - ang:Forward()

        local rt = {
            x = 0,
            y = 0,
            w = rtsize,
            h = rtsize,
            angles = ang - swayang,
            origin = pos,
            drawviewmodel = false,
            fov = self.zoomfov,
            znear = 1,
        }

        local scrw, scrh = ScrW(), ScrH()
        render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)
            render.RenderView(rt)
            cam.Start3D()
                local tr, pos, ang = self:GetHitTrace()
                local aimWay = (tr.HitPos - tr.StartPos):GetNormalized() * 10000000000
                local pos = aimWay:ToScreen()
                pos.x = pos.x / scrw
                pos.y = pos.y / scrh
            cam.End3D()

            local scope_posx = pos.x * ScrW() - ScrW() / 2
            local scope_posy = pos.y * ScrH() - ScrW() / 2
            cam.Start2D()
                sight_alpha = LerpFT(0.5, sight_alpha, not self:IsSighted() and 255 or 0)
                surface.SetDrawColor(0, 0, 0, sight_alpha)
                surface.DrawRect(0, 0, ScrW(), ScrH())
                surface.SetMaterial(scope)
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawTexturedRect(scope_posx, scope_posy, ScrW(), ScrH())
                surface.DrawRect(scope_posx + ScrW(), scope_posy - ScrH(), ScrW(), ScrH() * 3)
                surface.DrawRect(scope_posx - ScrW(), scope_posy - ScrH(), ScrW(), ScrH() * 3)
                surface.DrawRect(scope_posx, scope_posy + ScrH(), ScrW(), ScrH())
                surface.DrawRect(scope_posx, scope_posy - ScrH(), ScrW(), ScrH())
            cam.End2D()
        render.PopRenderTarget()
    end

    SWEP.addfov = 60
end

function SWEP:AdjustMouseSensitivity()
    return self:IsSighted() and (GetConVar("hg_scopespeed"):GetFloat() / 10) or 1
end

SWEP.vbwPos = Vector(-3,-5,-5)
SWEP.vbwAng = Vector(-80,-20,0)
SWEP.vbw = false

SWEP.CLR_Scope = 0.05
SWEP.CLR = 0.025

SWEP.addAng = Angle(-5.4,0,-90)
SWEP.addPos = Vector(-14,-0.7,-0.5)

SWEP.SightPos = Vector(-60, -0.68, -6)--Vector(-60, -0.68, -5.4)