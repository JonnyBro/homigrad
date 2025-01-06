skins = {
	megapenis = true,
	meagsponsor = true,
	donator = true,
	superadmin = true,
	microdonater = true,
	admin = true
}
local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)
SWEP.Base = 'weapon_base' -- base

SWEP.PrintName 				= "salat_base"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= ""
SWEP.Category 				= "Other"
SWEP.WepSelectIcon			= ""

SWEP.Spawnable 				= false
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 100
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/fiveseven/fiveseven-1.wav"
SWEP.Primary.SoundFar = "m9/m9_dist.wav"
SWEP.Primary.Force = 0
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.12
SWEP.NextShot = 0
SWEP.Sight = false
SWEP.ReloadSound = ""
SWEP.TwoHands = false


FrameTimeClamped = 1/66
ftlerped = 1/66

local def = 1 / 144

local FrameTime, TickInterval, engine_AbsoluteFrameTime = FrameTime, engine.TickInterval, engine.AbsoluteFrameTime
local Lerp, LerpVector, LerpAngle = Lerp, LerpVector, LerpAngle
local math_min = math.min
local math_Clamp = math.Clamp

hook.Add("Think", "Mul lerp", function()
	local ft = FrameTime()
	ftlerped = math_Clamp(ft,0.001,0.1)
end)


function hg.FrameTimeClamped(ft)
	return math_Clamp(1 - math.exp(-0.5 * (ft or ftlerped)), 0.001, 0.01)
end

local FrameTimeClamped_ = hg.FrameTimeClamped

local function lerpFrameTime(lerp,frameTime)
	return math_Clamp(1 - lerp ^ (frameTime or FrameTime()), 0, 1)
end

local function lerpFrameTime2(lerp,frameTime)
	return math_Clamp(lerp * FrameTimeClamped_(frameTime) * 150, 0, 1)
end

hg.lerpFrameTime2 = lerpFrameTime2
hg.lerpFrameTime = lerpFrameTime

function LerpFT(lerp, source, set)
	return Lerp(lerpFrameTime2(lerp), source, set)
end

function LerpVectorFT(lerp, source, set)
	return LerpVector(lerpFrameTime2(lerp), source, set)
end

function LerpAngleFT(lerp, source, set)
	return LerpAngle(lerpFrameTime2(lerp), source, set)
end

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.CSMuzzleFlashes = true

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = ""
SWEP.revolver = false
SWEP.shotgun = false

------------------------------------------

SWEP.DrawWeaponSelection = function(...) DrawWeaponSelection(...) end
SWEP.vbw = true
SWEP.vbwPos = false
SWEP.vbwAng = false
SWEP.Suppressed = false

local hg_skins = CreateClientConVar("hg_skins","1",true,false,"ubrat govno",0,1)
local hg_show_hitposmuzzle = CreateClientConVar("hg_show_hitposmuzzle","0",false,false,"huy",0,1)



hook.Add("HUDPaint","admin_hitpos",function()
	if hg_show_hitposmuzzle:GetBool() and LocalPlayer():IsAdmin() then
		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) or wep.Base != "salat_base" then return end

		local pos,ang = wep:GetTrace()

		local tr = util.QuickTrace(pos,ang:Forward() * 1000,LocalPlayer())
		local hit = tr.HitPos:ToScreen()
		local start = pos:ToScreen()

		surface.SetDrawColor( 255, 255, 255, 100 )
		surface.DrawRect(hit.x - 2,hit.y - 2,4,4)

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect(start.x - 2,start.y - 2,4,4)

		surface.SetDrawColor( 255, 255, 255, 20 )
		surface.DrawRect(ScrW() / 2 - 2,ScrH() / 2 - 2,4,4)
	end
end)

function SWEP:DrawHUDAdd()
end

function SWEP:DrawHUD()
	self:DrawHUDAdd()
	show = math.Clamp(self.AmmoChek or 0,0,1)
	self.AmmoChek = Lerp(2*FrameTime(),self.AmmoChek or 0,0)
	color_gray = Color(225,215,125,190*show)
	color_gray1 = Color(225,215,125,255*show)
	if show > 0 then
	local ply = LocalPlayer()
	local ammo,ammobag = self:GetMaxClip1(), self:Clip1()
	if ammobag > ammo - 1 then
		text = "Full"
	elseif ammobag > ammo - ammo/3 then
		text = "Nearly Full"
	elseif ammobag > ammo/3 then
		text = "Half Empty"
	elseif ammobag >= 1 then
		text = "Nearly Empty"
	elseif ammobag < 1 then
		text = "Empty"
	end

	local ammomags = ply:GetAmmoCount( self:GetPrimaryAmmoType() )

	if oldclip != ammobag then
		randomx = math.random(0, 5)
		randomy = math.random(0, 5)
		timer.Simple(0.15, function()
			oldclip = ammobag
		end)
	else
		randomx = 0
		randomy = 0
	end

	if oldmag != ammomags then
		randomxmag = math.random(0, 5)
		randomymag = math.random(0, 5)
		timer.Simple(0.35, function()
			oldmag = ammomags
		end)
	else
		randomxmag = 0
		randomymag = 0
	end

	local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
	local textpos = (hand.Pos+hand.Ang:Forward()*7+hand.Ang:Up()*5+hand.Ang:Right()*-1):ToScreen()
	if self.revolver then
		draw.DrawText( "Rounds Chambered | "..ammobag, "HomigradFontBig", textpos.x+randomx, textpos.y+randomy, color_gray1, TEXT_ALIGN_RIGHT )
		draw.DrawText( "Remaining | "..ammomags, "HomigradFontBig", textpos.x+randomxmag, textpos.y+25+randomymag, color_gray, TEXT_ALIGN_RIGHT )
	elseif self.shotgun then
		draw.DrawText( "Shells Loaded | "..text, "HomigradFontBig", textpos.x+randomx, textpos.y+randomy, color_gray1, TEXT_ALIGN_RIGHT )
		draw.DrawText( "Remaining | "..ammomags, "HomigradFontBig", textpos.x+randomxmag, textpos.y+25+randomymag, color_gray, TEXT_ALIGN_RIGHT )
	else
		draw.DrawText( "Bullets Loaded | "..text, "HomigradFontBig", textpos.x+randomx, textpos.y+randomy, color_gray1, TEXT_ALIGN_RIGHT )
		draw.DrawText( "Remaining| "..math.Round(ammomags/ammo), "HomigradFontBig", textpos.x+5+randomxmag, textpos.y+25+randomymag, color_gray, TEXT_ALIGN_RIGHT )
	end
	end
end

function SWEP:DrawWorldModel()
    self:DrawModel()

	if not hg_skins:GetBool() then return end

    if (IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and skins[self:GetOwner():GetUserGroup()]) then
        --self:SetSubMaterial( 0, self:GetNWString( "skin" ) )
		--для лохов
        self:DrawModel()
    end
end

HMCD_SurfaceHardness={
    [MAT_METAL]=.95,[MAT_COMPUTER]=.95,[MAT_VENT]=.95,[MAT_GRATE]=.95,[MAT_FLESH]=.5,[MAT_ALIENFLESH]=.3,
    [MAT_SAND]=.1,[MAT_DIRT]=.3,[74]=.1,[85]=.2,[MAT_WOOD]=.5,[MAT_FOLIAGE]=.5,
    [MAT_CONCRETE]=.9,[MAT_TILE]=.8,[MAT_SLOSH]=.05,[MAT_PLASTIC]=.3,[MAT_GLASS]=.6
}


local pos = Vector(0,0,0)

function SWEP:BulletCallbackFunc(dmgAmt,ply,tr,dmg,tracer,hard,multi)
	if(tr.MatType==MAT_FLESH)then
		util.Decal("Impact.Flesh",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
		local vPoint = tr.HitPos
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		--util.Effect( "BloodImpact", effectdata )
	end
	if(self.NumBullet or 1>1)then return end
	if(tr.HitSky)then return end
	if(hard)then self:RicochetOrPenetrate(tr) end
end
function SWEP:RicochetOrPenetrate(initialTrace)
	local AVec,IPos,TNorm,SMul=initialTrace.Normal,initialTrace.HitPos,initialTrace.HitNormal,HMCD_SurfaceHardness[initialTrace.MatType]
	if not(SMul)then SMul=.5 end
	local ApproachAngle=-math.deg(math.asin(TNorm:DotProduct(AVec)))
	local MaxRicAngle=60*SMul
	if(ApproachAngle>(MaxRicAngle*1.25))then -- all the way through
		local MaxDist,SearchPos,SearchDist,Penetrated=(self.Primary.Damage/SMul)*.15,IPos,5,false
		while((not(Penetrated))and(SearchDist<MaxDist))do
			SearchPos=IPos+AVec*SearchDist
			local PeneTrace=util.QuickTrace(SearchPos,-AVec*SearchDist)
			if((not(PeneTrace.StartSolid))and(PeneTrace.Hit))then
				Penetrated=true
			else
				SearchDist=SearchDist+5
			end
		end
		if(Penetrated)then
			self:FireBullets({
				Attacker=self:GetOwner(),
				Damage=1,
				Force=1,
				Num=1,
				Tracer=0,
				TracerName="",
				Dir=-AVec,
				Spread=Vector(0,0,0),
				Src=SearchPos+AVec
			})
			self:FireBullets({
				Attacker=self:GetOwner(),
				Damage=self.Primary.Damage*.65,
				Force=self.Primary.Damage/15,
				Num=1,
				Tracer=0,
				TracerName="",
				Dir=AVec,
				Spread=Vector(0,0,0),
				Src=SearchPos+AVec
			})
		end
	elseif(ApproachAngle<(MaxRicAngle*.25))then -- ping whiiiizzzz
		sound.Play("snd_jack_hmcd_ricochet_"..math.random(1,2)..".wav",IPos,70,math.random(90,100))
		local NewVec=AVec:Angle()
		NewVec:RotateAroundAxis(TNorm,180)
		NewVec=NewVec:Forward()
		self:FireBullets({
			Attacker=self:GetOwner(),
			Damage=self.Primary.Damage*.85,
			Force=self.Primary.Damage/15,
			Num=1,
			Tracer=0,
			TracerName="",
			Dir=-NewVec,
			Spread=Vector(0,0,0),
			Src=IPos+TNorm
		})
	end
end

homigrad_weapons = homigrad_weapons or {}

local skini = {
	"sal/acc/armor01_2",
	"sal/acc/armor01_3",
	"sal/acc/armor01_4",
	"sal/acc/armor01_5",
	"models/foodnhouseholditems/cj_b_plastic",
	"models/jacky_camouflage/digi",
	"models/jacky_camouflage/digi2"
}

--util.AddNetworkString("SendHomigradWeapons")

function AddHomigradWeapon(self)
	table.insert(homigrad_weapons,self)

	--[[if SERVER then
		net.Start("SendHomigradWeapons", true)
		net.WriteEntity(homigrad_weapons)
		net.Broadcast()
	end--]]
end

function SWEP:InitAdd()
end

function SWEP:Initialize()
	AddHomigradWeapon(self)

	if SERVER then
		self:SetNWString( "skin", table.Random(skini) )
	end

	self.lerpClose = 0

	self:InitAdd()
end

function SWEP:PrePrimaryAttack()
end

function SWEP:CanFireBullet()
	return true
end

SWEP.ZazhimYaycami = 0

function SWEP:PrimaryAttack()
	self.ShootNext = self.NextShot or NextShot

	if not IsFirstTimePredicted() then return end

	if self.NextShot > CurTime() then return end
	if timer.Exists("reload"..self:EntIndex()) then return end


	local canfire = self:CanFireBullet()
	--self:GetOwner():ChatPrint(tostring(canfire)..(CLIENT and " client" or " server"))
	if self:Clip1() <= 0 or not canfire then
		if SERVER then
			sound.Play("snd_jack_hmcd_click.wav",self:GetPos(),65,100)
		end

		self.NextShot = CurTime() + self.ShootWait
		self.AmmoChek = 3
		return
	end

	self:PrePrimaryAttack()

	if not (self:GetOwner():IsNPC() or IsValid(self:GetOwner().FakeRagdoll)) and (self.isClose and self:IsSprinting()) then return end

	local ply = self:GetOwner() -- а ну да
	self.NextShot = CurTime() + self.ShootWait

	if SERVER then
		local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
		ent:EmitSound(self.Primary.Sound,80,math.random(100,120),1,CHAN_WEAPON)
	end

    self:FireBullet()

	if SERVER and not ply:IsNPC() then
		if ply.RightArm < 1 then
			ply.pain = ply.pain + self.Primary.Damage / 30 * (self.NumBullet or 1)
		end

		if ply.LeftArm < 1 and self.TwoHands then
			ply.pain = ply.pain + self.Primary.Damage / 30 * (self.NumBullet or 1)
		end
	end

	if CLIENT and ply == LocalPlayer() then
		self.ZazhimYaycami = math.min(self.ZazhimYaycami + 1,self.Primary.ClipSize)
	end

	if CLIENT and (self:GetOwner() != LocalPlayer()) then
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	end

	self.lastShoot = CurTime()
	self:SetNWFloat("LastShoot",CurTime())

	if CLIENT and ply == LocalPlayer() then
		self.eyeSpray = self.eyeSpray or Angle(0,0,0)

		local func = self.ApplyEyeSpray
		if func then
			func(self)
		else
			self.eyeSpray:Add(Angle(math.Rand(-0.9,0) * self.Primary.Damage / 30 * math.max((self.ZazhimYaycami / self.Primary.ClipSize),0.2),math.Rand(-0.5,0.5) * self.Primary.Damage / 30 * math.max((self.ZazhimYaycami / self.Primary.ClipSize),0.2),0))
		end
	end
end

function SWEP:Reload()

	if !self:GetOwner():KeyDown(IN_WALK) then
		self.AmmoChek = 3
		if timer.Exists("reload"..self:EntIndex())  or self:Clip1()>=self:GetMaxClip1() or self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() )<=0 then return nil end
		if self:IsSprinting() then return nil end
		if ( self.NextShot > CurTime() ) then return end
		self:GetOwner():SetAnimation(PLAYER_RELOAD)
		if SERVER then self:GetOwner():EmitSound(self.ReloadSound,60,100,0.8,CHAN_AUTO) end
		timer.Create( "reload"..self:EntIndex(), self.ReloadTime, 1, function()
			if not IsValid(self) or not IsValid(self:GetOwner()) then return end
			local wep = self:GetOwner():GetActiveWeapon()
			if IsValid(self) and IsValid(self:GetOwner()) and (IsValid(wep) and wep or self:GetOwner().ActiveWeapon) == self then
				local oldclip = self:Clip1()
				self:SetClip1(math.Clamp(self:Clip1()+self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ),0,self:GetMaxClip1()))
				local needed = self:Clip1()-oldclip
				self:GetOwner():SetAmmo(self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() )-needed, self:GetPrimaryAmmoType())
				self.AmmoChek = 5
			end
		end)
	else
		self.AmmoChek = 5
	end
end

Sound("snd_jack_hmcd_lightning.wav")

SWEP.addPos = Vector(0,0,0)
SWEP.addAng = Angle(0,0,0)

if SERVER then
	util.AddNetworkString("shoot_huy")
else
	net.Receive("shoot_huy",function(len)
		local tr = net.ReadTable()
		--snd_jack_hmcd_bc_1.wav

		local dist,vec,dist2 = util.DistanceToLine(tr.StartPos,tr.HitPos,EyePos())
		if dist < 128 and dist2 > 128 then
			EmitSound("snd_jack_hmcd_bc_"..tostring(math.random(1,7))..".wav", vec, 1, CHAN_WEAPON, 1, 75, 0, 100)
		end
	end)
end

function SWEP:GetSAttachment(obj)
	local pos, ang = self:GetTransform()
	local owner = self:GetOwner()

	local wep = IsValid(owner) and owner:GetNWEntity("ragdollWeapon",self) or self

	local model = IsValid(wep) and wep or self

	local att = model:GetAttachment(obj)

	if not att then return end

	if IsValid(wep) then return att end

	local bon = att.Bone or 0
	local mat = model:GetBoneMatrix(bon)
	local bonepos, boneang = mat:GetTranslation(), mat:GetAngles()
	local lpos, lang = WorldToLocal(att.Pos or bonepos, att.Ang or boneang, bonepos, boneang)

	if CLIENT then self:SetupBones() end

	local mat = model:GetBoneMatrix(bon)
	local bonepos, boneang = mat:GetTranslation(), mat:GetAngles()

	local pos, ang = LocalToWorld(lpos, lang, bonepos, boneang)

	return {Pos = pos, Ang = ang, Bone = bon}
end

function SWEP:GetHitTrace()
	local pos, ang = self:GetTrace()

	local tr = {}
	tr.start = pos
	tr.endpos = pos + ang:Forward() * 50000
	tr.filter = {self, self:GetOwner()}

	return util.TraceLine(tr), pos, ang
end

function SWEP:GetTrace(nomodify)
	local owner = self:GetOwner()
	local obj = self:LookupAttachment("muzzle") or 0

	local att = self:GetSAttachment(self.att or obj)

	if not att then
		local Pos, Ang

		local wep = IsValid(owner) and owner:GetNWEntity("ragdollWeapon")
		if wep and IsValid(wep) then
			Pos, Ang = wep:GetPos(), wep:GetAngles()
		else
			Pos, Ang = self:GetTransform()
		end

		att = {Pos = Pos, Ang = Ang}
	end

	local pos, ang = att.Pos, att.Ang

	if not nomodify then
		pos, ang = LocalToWorld(self.addPos or vector_origin,self.addAng or angle_zero,att.Pos,att.Ang)
	end

	return pos, ang
end
--[[
local huyprecahche = {
    "muzzleflash_SR25",
    "pcf_jack_mf_tpistol",
    "pcf_jack_mf_mshotgun",
    "pcf_jack_mf_msmg",
    "pcf_jack_mf_spistol",
    "pcf_jack_mf_mrifle2",
    "pcf_jack_mf_mrifle1",
    "pcf_jack_mf_mpistol",
    "pcf_jack_mf_suppressed",
    "muzzleflash_pistol_rbull",
    "muzzleflash_m24",
    "muzzleflash_m79",
    "muzzleflash_M3",
    "muzzleflash_m14",
    "muzzleflash_g3",
    "muzzleflash_FAMAS",
    "muzzleflash_ak74",
    "muzzleflash_ak47",
    "muzzleflash_mp5",
    "muzzleflash_suppressed",
    "muzzleflash_MINIMI",
    "muzzleflash_svd",
    "new_ar2_muzzle"
}
]]
local CaliberEffects = {
	[".44 Remington Magnum"] = "pcf_jack_mf_mshotgun",
	["5.7×28 mm"] = "pcf_jack_mf_msmg",
	["4.6×30 mm"] = "pcf_jack_mf_msmg",
	[".45 Rubber"] = "pcf_jack_mf_spistol",
	["12/70 beanbag"] = "pcf_jack_mf_mshotgun",
	["12/70 gauge"] = "pcf_jack_mf_mshotgun",
	["7.62x39 mm"] = "pcf_jack_mf_mrifle1",
	["5.56x45 mm"] = "pcf_jack_mf_mrifle1",
	["5.45x39 mm"] = "pcf_jack_mf_mrifle2",
	["9x19 mm"] = "pcf_jack_mf_spistol",
	["9x39 mm"] = "pcf_jack_mf_spistol",
}

function SWEP:FireBullet()
	if self:Clip1() <= 0 then return end
	if timer.Exists("reload"..self:EntIndex()) then return nil end

	local ply = self:GetOwner()

	ply:LagCompensation(true)

	local shootOrigin, shootAngles = self:GetTrace()

	local cone = self.Primary.Cone

	local _
	if not ply:IsNPC() and not IsValid(ply.FakeRagdoll) then
		--_, shootOrigin, _ = util.DistanceToLine(shootOrigin - shootAngles:Forward(),shootOrigin,ply:EyePos())
	end

	if IsValid(ply.wep) then
		local phys = ply.wep:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceCenter(phys:GetAngles():Forward() * -250)
		end
	end

	local shootDir = shootAngles:Forward()

	local npc = ply:IsNPC() and ply:GetShootPos() or shootOrigin
	local npcdir = ply:IsNPC() and ply:GetAimVector() or shootDir
	local bullet = {}
	bullet.Num 			= self.NumBullet or 1
	bullet.Src 			= npc
	bullet.Dir 			= npcdir
	bullet.Spread 		= Vector(cone,cone,0)
	bullet.Force		= self.Primary.Force / 40
	bullet.Damage		= self.Primary.Damage * 4
	bullet.AmmoType     = self.Primary.Ammo
	bullet.Attacker 	= self:GetOwner()
	bullet.Tracer       = 1
	bullet.TracerName   = self.Tracer or "Tracer"
	bullet.IgnoreEntity = IsValid(self:GetOwner():GetVehicle()) and self:GetOwner():GetVehicle() or IsValid(self:GetOwner().wep) and self:GetOwner().wep or self:GetOwner()

	local wep = self
	bullet.Callback = function(ply,tr,dmgInfo)
		wep:BulletCallbackFunc(self.Primary.Damage,ply,tr,self.Primary.Damage,false,true,false)

		--dmgInfo:SetDamageForce(dmgInfo:GetDamageForce())

		if self.Primary.Ammo == "buckshot" then
			local k = math.max(1 - tr.StartPos:Distance(tr.HitPos) / 750,0)

			dmgInfo:ScaleDamage(k)
		end

		local effectdata = EffectData()
		effectdata:SetEntity(tr.Entity)
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetStart(tr.StartPos)

		effectdata:SetSurfaceProp(tr.SurfaceProps)
		effectdata:SetDamageType(DMG_BULLET)
		effectdata:SetHitBox(tr.HitBox)

		util.Effect("Impact",effectdata,true,true)

		net.Start("shoot_huy")
		net.WriteTable(tr)
		net.Broadcast()
	end

	if SERVER then self:TakePrimaryAmmo(1) end


	if ply:GetNWBool("Suiciding") then
		if SERVER then
			ply.KillReason = "killyourself"

			--self:GetOwner():FireBullets(bullet)
			local dmgInfo = DamageInfo()
			dmgInfo:SetAttacker(ply)
			dmgInfo:SetInflictor(self)
			dmgInfo:SetDamage(bullet.Damage * 4 * (self.NumBullet or 1))
			dmgInfo:SetDamageType(DMG_BULLET)
			dmgInfo:SetDamageForce(shootDir * 1024)
			dmgInfo:SetDamagePosition(ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1")))
			ply:TakeDamageInfo(dmgInfo)

			ply.LastDMGInfo = dmgInfo
			ply.LastHitBoneName = "ValveBiped.Bip01_Head1"

			--if ply:Alive() then ply:Kill() end
		end
	elseif not self:GetOwner():IsNPC() then
		if SERVER then
			self:GetOwner():FireBullets(bullet)
		end
		self:SetLastShootTime()
	else
		--if SERVER then
			self:FireBullets(bullet)
		--end
	end

	ply:LagCompensation(false)

	--local effectdata = EffectData()
	--effectdata:SetOrigin(shootOrigin)
	--effectdata:SetAngles(shootAngles)
	--effectdata:SetScale(self:IsSighted() and 0.1 or 1)
	--effectdata:SetNormal(shootDir)
	--util.Effect(self.Efect or "MuzzleEffect",effectdata, true, true)
	local particle = ParticleEffect(self.Supressed and "pcf_jack_mf_suppressed" or CaliberEffects[self.Primary.Ammo] or "pcf_jack_mf_spistol",npc,npcdir:Angle(),self)

	if self:GetOwner():IsNPC() then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	end
end

hook.Add("Think","weapons-sadsalat",function()
	for i,wep in ipairs(homigrad_weapons) do
		if not IsValid(wep) then table.remove(homigrad_weapons,i) continue end

		local owner = wep:GetOwner()
		if not owner.GetActiveWeapon then continue end
		if not IsValid(owner) or (owner:IsPlayer() and not owner:Alive()) or owner:GetActiveWeapon() ~= wep then continue end--wtf i dont know

		if wep.Step then wep:Step() end
	end
end)

function SWEP:Think()
end

local timer_Exists = timer.Exists

function SWEP:IsLocal()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:IsReloaded()
	return timer_Exists("reload"..self:EntIndex())
end

function SWEP:IsSighted()
	local ply = self:GetOwner()
	if ply:IsNPC() then return end

	if (self:IsLocal() or SERVER) and ply:IsPlayer() then
		return not self:IsSprinting() and ply:KeyDown(IN_ATTACK2) and not self:IsReloaded()
	else
		return self:GetNWBool("IsSighted")
	end
end

if SERVER then
	concommand.Add("suicide",function(ply)
		if not ply:Alive() then return end
		ply.suiciding = not ply.suiciding
		ply:SetNWBool("Suiciding",ply.suiciding)
	end)
end

hook.Add("Player Death","suciding",function(ply)
	ply.suiciding = false
	ply:SetNWBool("Suiciding",false)
end)

local util_QuickTrace = util.QuickTrace
local math_Clamp = math.Clamp
local closeAng = Angle(0,0,0)

local angZero = Angle(0,0,0)
local angSuicide = Angle(160,30,90)
local angSuicide2 = Angle(160,30,90)
local angSuicide3 = Angle(60,-30,90)
local forearm,clavicle,hand = Angle(0,0,0),Angle(0,0,0),Angle(0,0,0)
local ENTITY = FindMetaTable("Entity")

function ENTITY:SetBoneMatrix2(boneID,matrix,dontset)
	local localpos = self:GetManipulateBonePosition(boneID)
	local localang = self:GetManipulateBoneAngles(boneID)
	local newmat = Matrix()
	newmat:SetTranslation(localpos)
	newmat:SetAngles(localang)
	local inv = newmat:GetInverse()
	local oldMat = self:GetBoneMatrix(boneID) * inv
	local newMat = oldMat:GetInverse() * matrix
	local lpos,lang = newMat:GetTranslation(),newMat:GetAngles()

	if not dontset then
		self:ManipulateBonePosition(boneID,lpos,false)
		self:ManipulateBoneAngles(boneID,lang,false)
	end

	return lpos,lang
end

local pistol_hold = Angle(10,-10,0)
local rifle_hold = Angle(-5,-8,0)

function SWEP:IsPistolHoldType()
	return self.HoldType == "revolver"
end

SWEP.ishgweapon = true

function ishgweapon(wep)
	return wep.ishgweapon
end

function SWEP:IsSprinting()
	local owner = self:GetOwner()
	return hg.KeyDown(owner,IN_SPEED) or (((self:GetNWFloat("DeployTime",0) or 0) + 0.2) > CurTime())
end

SWEP.localAng = Angle(10,0,-90)

function SWEP:Step()
	local ply = self:GetOwner()
	local isLocal = self:IsLocal()

	if not IsValid(ply) or ply:IsNPC() or IsValid(ply:GetNWEntity("Ragdoll")) then return end

	if isLocal then
		self.eyeSpray = self.eyeSpray or Angle(0,0,0)

		ply:SetEyeAngles(ply:EyeAngles() + self.eyeSpray)

		self.eyeSpray = LerpAngleFT(0.5,self.eyeSpray,Angle(0,0,0))

		if not ply:KeyDown(IN_ATTACK) then
			self.ZazhimYaycami = math.max((self.ZazhimYaycami or 0) - 3,0)
		end
	end

	if SERVER then
		ply:SetNWInt("RightArm",ply.RightArm)
		ply:SetNWInt("LeftArm",ply.LeftArm)
	end

	if SERVER then self:WorldModelTransform() end

	if SERVER then
		local pos, ang = self:GetTrace()
		local tr = {}
		tr.start = pos
		tr.endpos = pos + ang:Forward() * 9999
		tr.filter = {ply}
		local trace = util.TraceLine(tr)
		debugoverlay.Sphere(trace.HitPos,2,0.1,color_white)
	end
end

function SWEP:ApplyAnim(ply)
	local t = {}

	if not self.TwoHands then
		t.start = ply:GetShootPos() + ply:GetAngles():Right()*2.5 --+ Angle(0,ply:GetAngles().y,ply:GetAngles().z):Forward() * 10
	else
		t.start = ply:GetShootPos() + ply:GetAngles():Right()*7 --+ Angle(0,ply:GetAngles().y,ply:GetAngles().z):Forward() * 10
	end

	t.endpos = t.start + Angle(0,ply:GetAngles().y,ply:GetAngles().z):Forward() * 100
	t.filter = player.GetAll()
	local tr = util.TraceLine(t)
	self.dist = (tr.HitPos - t.start):Length()

	if not self:IsSprinting() then
		local scope = self:IsSighted()
		if SERVER then self:SetNWBool("IsSighted",scope) end

		if isLocal then
			--self.eyeSpray = self.eyeSpray + Angle(math.Rand(-0.03,0.03),math.Rand(-0.03,0.03),math.Rand(-0.03,0.03))
			if (ply:GetNWInt("LeftArm") < 1 or ply:GetNWInt("RightArm") < 1) then
				local p = 0.3 - math.min((painlosing or 0),0.3)
				self.eyeSpray = self.eyeSpray + Angle(math.Rand(-p,p),math.Rand(-p,p),math.Rand(-p,p))
			end
		end

		if isLocal or SERVER then
			local head = ply:LookupBone("ValveBiped.Bip01_L_Hand")

			if head then
				local pos,ang = ply:GetBonePosition(head)
				pos[3] = pos[3] + 5
				ang:RotateAroundAxis(ang:Up(),-90)

				local dir = ang:Forward() * 1000
				local tr = util_QuickTrace(pos,dir,ply)
				local dist = pos:DistToSqr(tr.HitPos)

				self.isClose = self.dist <= 35 and not self:IsReloaded()

				if SERVER then self:SetNWBool("isClose",self.isClose) end
			end
		else
			self.isClose = self:GetNWBool("isClose")
		end
		hand:Set(angZero)
		if not self.isClose and not self:IsSprinting() then
			if not ply:GetNWBool("Suiciding") then
				self:SetWeaponHoldType(self.HoldType)
				hand:Set(angZero)
				forearm:Set(self:IsPistolHoldType() and pistol_hold or rifle_hold)
			elseif not self.TwoHands and ply:GetNWBool("Suiciding") then
				self:SetWeaponHoldType("normal")
				forearm:Set(angSuicide2)
				hand:Set(angSuicide3)
			elseif ply:GetNWBool("Suiciding") then
				self:SetWeaponHoldType("normal")
				hand:Set(angSuicide)
			end
		end
	else
		self.isClose = true
		--[[if not self.TwoHands then
			self:SetWeaponHoldType("normal")
		else
			self:SetWeaponHoldType("passive")
		end--]]
	end
	self.lerpClose = LerpFT(0.1,self.lerpClose,(self.isClose and 1) or 0)

	clavicle:Set(angZero)
	closeAng[3] = -40 * self.lerpClose--(-60 + math_Clamp(ply:EyeAngles()[1],0,60)) * self.lerpClose
	clavicle:Add(closeAng)

	if not ply:LookupBone("ValveBiped.Bip01_R_Forearm") then return end--;c

	local hand_index = ply:LookupBone("ValveBiped.Bip01_R_Hand")
	local forearm_index = ply:LookupBone("ValveBiped.Bip01_R_Forearm")
	local clavicle_index = ply:LookupBone("ValveBiped.Bip01_R_Clavicle")

	local attPos, attAng = self:GetTrace()
	local matrix = ply:GetBoneMatrix(hand_index)
	if not matrix then return end
	local plyang = ply:EyeAngles()
	plyang:RotateAroundAxis(plyang:Forward(),0)

	local _,newAng = LocalToWorld(vector_origin,self.localAng or angle_zero,vector_origin,plyang)
	local ang = newAng
	--attAng[3] = attAng[3] + (ply:KeyDown(IN_ALT1) and -30 or ply:KeyDown(IN_ALT2) and 30 or 0) / 3
	ang:RotateAroundAxis(ang:Forward(),-90)
	--ang:RotateAroundAxis(ang:Right(),8)
	matrix:SetAngles(ang)

	local lpos, lang = ply:SetBoneMatrix2(hand_index, matrix, false)

	if not ply:GetNWBool("Suiciding") then

		if not self:IsSprinting() and not self.isClose then
			self.lerp_aim = LerpFT(0.1, self.lerp_aim or 0, 1)
		else
			self.lerp_aim = LerpFT(0.1, self.lerp_aim or 0, 0)
		end

		hand = lang * self.lerp_aim
	end

	local _,localAng = WorldToLocal(vector_origin,attAng,vector_origin,ang)
	localAng:RotateAroundAxis(localAng:Forward(),0)

	if not ply:GetNWBool("Suiciding") and not self:IsSprinting() and not self.isClose then
		self.localAng = LerpFT(0.1, self.localAng or angle_zero, localAng)
		--print(self.localAng)
	end

	ply:ManipulateBoneAngles(forearm_index, forearm, false)
	ply:ManipulateBoneAngles(clavicle_index, clavicle, false)
	ply:ManipulateBoneAngles(hand_index, hand, false)
end

hook.Add("UpdateAnimation","weapon_animations",function(ply,vel,maxseqgroundspeed)
	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and ishgweapon(wep) then
		wep:ApplyAnim(ply)
	end

	local spine_index = ply:LookupBone("ValveBiped.Bip01_Spine")
	if not spine_index then return end
	local spine_angle = ply.spine_angle or Angle(0,0,0)
	if not spine_angle then return end

	spine_angle[1] = LerpFT(0.1, spine_angle[1], ply:KeyDown(IN_ALT1) and -30 or ply:KeyDown(IN_ALT2) and 30 or 0)
	spine_angle[2] = 0
	spine_angle[3] = 0

	ply:ManipulateBoneAngles(spine_index, spine_angle, false)
	ply.spine_angle = spine_angle
end)

function SWEP:Holster( wep )
	--if not IsFirstTimePredicted() then return end
	local ply = self:GetOwner()

	if not IsValid(ply) or not ply:LookupBone("ValveBiped.Bip01_R_Forearm") then return end--;c

	ply:ManipulateBoneAngles( ply:LookupBone( "ValveBiped.Bip01_R_Hand" ), Angle( 0,0,0 ) )
	ply:ManipulateBoneAngles( ply:LookupBone( "ValveBiped.Bip01_R_Forearm" ), Angle( 0,0,0 ))
	ply:ManipulateBoneAngles( ply:LookupBone( "ValveBiped.Bip01_R_Clavicle" ),Angle( 0,0,0 ))

	return true
end

hook.Add("Player Death","weapons",function(ply)
	if not ply:LookupBone("ValveBiped.Bip01_R_Forearm") then return end
	ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"),angZero,false)
	ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"),angZero,false)
	ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"),angZero,false)
end)

function SWEP:SecondaryAttack() return end

function SWEP:Deploy()
	self:SetHoldType("normal")
	if SERVER then
		self:GetOwner():EmitSound("snd_jack_hmcd_pistoldraw.wav", 65,(self.TwoHands and 100) or (!self.TwoHands and 110), 1, CHAN_AUTO)
	end

	self.NextShot = CurTime() + 0.5
	self:SetNWFloat("DeployTime",CurTime())

	self:SetHoldType( self.HoldType )
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:CreateWorldModel()
	if CLIENT then
		local model = ClientsideModel(self.WorldModel,RENDER_GROUP_OPAQUE_ENTITY)
		model:SetNoDraw(true)
		model:SetModel(self.WorldModel)
		model:SetModelScale(self.dwmModeScale or 1)
		return model
	else
		local model = ents.Create("prop_physics")
		model:SetNoDraw(true)
		model:SetModel(self.WorldModel)
		model:SetMaterial("models/wireframe")
		model:Spawn()
		model:PhysicsDestroy()
		model:SetMoveType(MOVETYPE_NONE)
		model:SetNWBool("nophys", true)
		model:SetSolidFlags(FSOLID_NOT_SOLID)
		model:AddEFlags(EFL_NO_DISSOLVE)

		return model
	end
end

function SWEP:WorldModelTransform()
    local owner = self:GetOwner()
    if not IsValid(owner) then
		if IsValid(self.worldModel) then
			self.worldModel:Remove()
			self.worldModel = nil
		end

		self:DrawModel()

        return
    end

    local model = self.worldModel
    if not IsValid(self.worldModel) then
        self.worldModel = self:CreateWorldModel()
        model = self.worldModel
    end

    local Pos,Ang = self:GetTransform(model)
	--local _,ang = self:GetTrace()
	--local _,localang = WorldToLocal(vector_origin,owner:EyeAngles(),vector_origin,ang)
	--print(localang)
	--Ang:RotateAroundAxis(ang:Up(),localang[2])
	--Ang:RotateAroundAxis(ang:Right(),localang[1])

    model:SetPos(Pos)
    model:SetAngles(Ang)

	if CLIENT then
		model:SetRenderOrigin(Pos)
    	model:SetRenderAngles(Ang)
	end

	if CLIENT then model:SetupBones() end

    --model:DrawModel()
end

function SWEP:DrawWorldModelAdd()
end

function SWEP:DrawWorldModel()
	--self:DrawModel()
	self:WorldModelTransform()

	if IsValid(self.worldModel) then
		self.worldModel:DrawModel()
	end

	self:DrawWorldModelAdd()
end

SWEP.localpos = Vector(0,0,0)
SWEP.localang = Angle(0,0,0)

function SWEP:GetTransform(model, force)
    local owner = self:GetOwner()
	local model = IsValid(model) and model

	if not IsValid(owner) then return self:GetPos(),self:GetAngles() end

	if not IsValid(model) then
		self.worldModel = IsValid(self.worldModel) and self.worldModel or self:CreateWorldModel()
		model = self.worldModel
	end

	local wep = owner:GetNWEntity("ragdollWeapon")
	if IsValid(wep) and not force then return wep:GetPos(),wep:GetAngles() end

	local owner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
	local model = IsValid(wep) and wep or model

	if CLIENT then model:SetPredictable(true) end

	if CLIENT then owner:SetupBones() model:SetupBones() end

	local bon = owner:LookupBone("ValveBiped.Bip01_R_Hand")

	if not bon then return self:GetPos(),self:GetAngles() end

	local rh = owner:GetBoneMatrix(bon)

	if owner:IsRagdoll() then--fuck source engine
		rh = Matrix()
		local phys = owner:GetPhysicsObjectNum(owner:TranslateBoneToPhysBone(bon))
		if not IsValid(phys) then return end

		local pos, ang = phys:GetPos(), phys:GetAngles()
		rh:SetTranslation(pos)
		rh:SetAngles(ang)
	end

	if not rh then return self:GetPos(),self:GetAngles() end

	local pos,ang = rh:GetTranslation(),rh:GetAngles()

	local oldpos,oldang = model:GetPos(),model:GetAngles()

	model:SetPos(pos)
	model:SetAngles(ang)

	if CLIENT then
		model:SetRenderOrigin(pos)
    	model:SetRenderAngles(ang)
	end

	if CLIENT then model:SetupBones() end

	local bon2 = model:LookupBone("ValveBiped.Bip01_R_Hand")
	if bon2 then
		local rh_wep = model:GetBoneMatrix(bon2)

		if rh_wep and rh then
			local newmat = rh_wep:GetInverse() * rh

			pos, ang = LocalToWorld(newmat:GetTranslation(),newmat:GetAngles(), pos, ang)
		end
	end

	model:SetPos(oldpos)
	model:SetAngles(oldang)

    pos:Add(ang:Forward() * (self.dwmForward or 0))
    pos:Add(ang:Right() * (self.dwmRight or 0))
    pos:Add(ang:Up() * (self.dwmUp or 0))

	local timehuy = 0.1
	local animpos = math.ease.InBack(math.max(self:LastShootTime() - CurTime() + timehuy,0) / timehuy) * 1

    ang:RotateAroundAxis(ang:Up(),(self.dwmAUp or 0))
    ang:RotateAroundAxis(ang:Right(),(self.dwmARight or 0))-- + animpos * (self:IsPistolHoldType() and 1 or 0))
    ang:RotateAroundAxis(ang:Forward(),(self.dwmAForward or 0))

    return pos, ang
end

if CLIENT then
	SWEP.SightPos = Vector(-30, 2.3, -0.28)
	SWEP.SightAng = Angle(0, 0, 0)--unused (D)

	local addfov = 0

	local lerpaim = 0
	function SWEP:Camera(ply, origin, angles, fov)
		local pos, ang = self:GetTrace(true)
		local _, anglef = self:GetTrace()

		lerpaim = LerpFT(0.1, lerpaim, self:IsSighted() and 1 or 0)

		local neworigin, _ = LocalToWorld(self.SightPos, self.SightAng, pos, ang)

		origin = Lerp(lerpaim,origin,neworigin)

		local animpos = math.max(self:LastShootTime() - CurTime() + 0.1,0) * 20
		origin = origin + anglef:Forward() * animpos --+ angles:Up() * animpos / 20

		origin = origin + anglef:Right() * math.random(-0.1,0.1) * (animpos/200) + anglef:Up() * math.random(-0.1,0.1) * (animpos/200)

		addfov = LerpFT(0.1, addfov, self:IsSighted() and -(self.addfov or 20) or 0)

		return origin, angles, fov + addfov
	end

end

function SWEP:AdjustMouseSensitivity()
    return self:IsSighted() and 0.75 or 1
end