
// Variables that are used on both client and server

if (SERVER) then
	function SWEP:Deploy()
		self.Owner:DrawViewModel( false )
	end
end

SWEP.HoldType			= "normal"

SWEP.Author			= "spy"
SWEP.Purpose		= ""
SWEP.Instructions	= "ЛКМ - Кончить/Пкм - камбомба"

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Timer = CurTime()

local ShootSound = Sound( "physics/flesh/flesh_bloody_impact_hard1.wav" )

local HitSounds = {"vo/k_lab/ba_guh.wav",
"ambient/voices/m_scream1.wav",
"vo/coast/odessa/male01/nlo_cubdeath01.wav",
"vo/npc/male01/answer20.wav",
"vo/npc/male01/answer39.wav",
"vo/npc/male01/fantastic01.wav",
"vo/npc/male01/goodgod.wav",
"vo/npc/male01/gordead_ans05.wav",
"vo/npc/male01/gordead_ans04.wav",
"vo/npc/male01/gordead_ans19.wav",
"vo/npc/male01/ohno.wav",
"vo/npc/male01/pain05.wav",
"vo/npc/male01/pain08.wav",
"vo/npc/male01/pardonme01.wav",
"vo/npc/male01/stopitfm.wav",
"vo/npc/male01/uhoh.wav",
"vo/npc/male01/vanswer01.wav",
"vo/npc/male01/vanswer14.wav",
"vo/npc/male01/watchwhat.wav",
"vo/trainyard/male01/cit_hit01.wav",
"vo/trainyard/male01/cit_hit02.wav",
"vo/trainyard/male01/cit_hit03.wav",
"vo/trainyard/male01/cit_hit04.wav",
"vo/trainyard/male01/cit_hit05.wav"}

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:Holster()
	for k,v in pairs(player.GetAll()) do
		v:SetNWFloat("cum",0)
	end
	return true
end

function SWEP:Reload()
	for k,v in pairs(player.GetAll()) do
		v:SetNWFloat("cum",0)
	end
end

function SWEP:Think()	
	if self.Timer < CurTime() then
		self.Timer = CurTime() + math.random(2,5)
		for k,v in pairs(player.GetAll()) do
			if (v:GetNWFloat("cum") or 1) < 0 then
				v:SetNWFloat("cum",0)
			else
				v:SetNWFloat("cum",(v:GetNWFloat("cum") or 1) - 1)
			end
		end
	end
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire( CurTime() + 0.8 )

	local tr = self.Owner:GetEyeTrace()
	
	local effectdata = EffectData()
		effectdata:SetOrigin( (self.Owner:GetPos() + Vector(0,0,35)) + (self.Owner:GetForward() * 5))
		effectdata:SetNormal( self.Owner:GetPos():GetNormalized() )
		effectdata:SetAngles( self.Owner:GetAngles() )
	util.Effect( "sementrail", effectdata )
	
	self.Weapon:EmitSound( ShootSound, 100, math.random(100,110) )
	
	if tr.Hit then
		if tr.HitNonWorld then
			if tr.Entity:IsPlayer() then
				tr.Entity:SetNWFloat("cum",(tr.Entity:GetNWFloat("cum") or 1) + 1)
				local rand = math.random(1,5)
				if rand == 5 then
					tr.Entity:EmitSound(Sound(HitSounds[math.random(1,table.Count(HitSounds))]),100,math.random(95,105))
				end
			end
		end
	end
	
end

function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire( CurTime() + 2 )

	self.Weapon:EmitSound( ShootSound, 100, math.random(100,110) )
	
	if CLIENT then return end
	
	local cg = ents.Create( "sent_cumgrenade" )
	if ( !cg:IsValid() ) then return end
	cg:SetPos( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 7 )
	cg:SetAngles(self.Owner:GetAngles())
	cg:Spawn()
	cg:Initialize()
	cg:Activate()
	
	local phys = cg:GetPhysicsObject()
	if !phys:IsValid() or (phys == nil) then return end
	
	phys:SetVelocity( self.Owner:GetAimVector() * 5000 )

end