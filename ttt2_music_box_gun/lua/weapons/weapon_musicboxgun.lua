local songs = { }
local song_path = "weapons/musicboxgun/songs/"

if ( SERVER ) then
    AddCSLuaFile( )
    resource.AddFile( "materials/effects/mbg/refract_ring.vmt" )
    resource.AddFile( "materials/icon/weapon_music_box_gun.vmt" )
    resource.AddFile( "models/mark2580/sr4/dubstepgun.dx80.vtx" )
    resource.AddFile( "models/mark2580/sr4/dubstepgun.dex90.vtx" )
    resource.AddFile( "models/mark2580/sr4/dubstepgun.mdl" )
    resource.AddFile( "models/mark2580/sr4/dubstepgun.phy" )
    resource.AddFile( "models/mark2580/sr4/dubstepgun.sw.vtx" )
    resource.AddFile( "models/mark2580/sr4/dubstepgun.vvd" )
    resource.AddFile( "materials/models/mark2580/sr4/dubstepgun_lg_d.vmt" )
    resource.AddFile( "meme.mp3" )
    local song_files = file.Find( "sound/" .. song_path .. "*.wav" , "GAME" )

    if song_files then
        for i = 1 , #song_files do
            local song = song_files[ i ]
            resource.AddFile( "sound/" .. song_path .. song_files[ i ] )
            songs[ i ] = song
        end
    end
end

//- TTT STUFF ---
SWEP.EquipMenuData = {
    type = "item_weapon" ,
    name = "ttt2_music_box_gun_name" ,
    desc = "ttt2_music_box_gun_desc"
}

SWEP.Kind = WEAPON_EQUIP1

SWEP.CanBuy = { ROLE_DETECTIVE }

SWEP.LimitedStock = true
SWEP.Icon = "icon/weapon_music_box_gun"
//- END TTT STUFF ---
SWEP.Base = "weapon_tttbase"
SWEP.PrintName = "Music Box Gun"
SWEP.AutoSpawnable = false
SWEP.ViewModel = "models/mark2580/sr4/dubstepgun.mdl"
SWEP.WorldModel = "models/mark2580/sr4/dubstepgun.mdl"
SWEP.ShowWorldModel = true
SWEP.ShowViewModel = true
SWEP.HoldType = "rpg"
SWEP.ViewModelFOV = 90
SWEP.UseHands = true
SWEP.IronSightsPos = Vector( 10.6 , 0 , -12.12 )
SWEP.IronSightsAng = Vector( 0 , 0 , 0 )
SWEP.PreventEffectSpam = false
SWEP.AllowBounce = false
SWEP.SkinType = 1
SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Delay = 0.5
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
//- Fix position stuff ---
SWEP.Pos = nil
SWEP.Ang = nil

SWEP.Offset = {
    Pos = {
        Up = 0 ,
        Right = 4.5 ,
        Forward = 3 ,
    } ,
    Ang = {
        Up = 0 ,
        Right = 0 ,
        Forward = 0 ,
    }
}

//- End of fix position stuff ---
function SWEP:Initialize( )
    if CLIENT then
        self:AddHUDHelp( "ttt2_music_box_gun_help1" , "ttt2_music_box_gun_help2" , true )
    end

    self:SetWeaponHoldType( self.HoldType )

    if SERVER then
        self:SetWeaponHoldType( self.HoldType )
    end

    if CLIENT then
        self:SetWeaponHoldType( self.HoldType )
    end

    return true
end

function SWEP:PrimaryAttack( )
    if ( !self:CanPrimaryAttack( ) ) then return end

    if SERVER then
        if !self.LoopSound then
            self.LoopSound = CreateSound( self:GetOwner( ) , Sound( song_path .. songs[ math.random( #songs ) ] ) )

            if ( self.LoopSound ) then
                self.LoopSound:Play( )
            end
        end
    end

    if ( self.BeatSound ) then
        self.BeatSound:ChangeVolume( 0 , 0.1 )
    end

    //- Wub effect ---
    if self.PreventEffectSpam == true then return end
    self.PreventEffectSpam = true
    self.AllowBounce = true

    timer.Simple( 0.3 , function( )
        self.PreventEffectSpam = false
    end )

    timer.Simple( 0.45 , function( )
        self.AllowBounce = false
    end )

    //if IsValid( Ply ) then
    local tr = self:GetOwner( ):GetEyeTrace( )
    local effectdata = EffectData( )
    effectdata:SetOrigin( tr.HitPos )
    util.Effect( "musicboxgun_wub_effect" , effectdata , true , true )
    effectdata:SetOrigin( tr.HitPos )
    effectdata:SetStart( self:GetOwner( ):GetShootPos( ) )
    effectdata:SetScale( 5 )
    effectdata:SetAttachment( 1 )
    effectdata:SetEntity( self )
    util.Effect( "musicboxgun_wub_beam" , effectdata , true , true )
    util.BlastDamage( self , self:GetOwner( ) , tr.HitPos , 175 , 10 )
    //end
    //- End of Wub effect ---
    //self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    //self.Owner:SetAnimation( PLAYER_ATTACK1 )
    self:SetNextPrimaryFire( CurTime( ) + self.Primary.Delay )
    self:SetNextSecondaryFire( CurTime( ) + self.Primary.Delay )
end

function SWEP:SecondaryAttack( )
    if SERVER then
        self.currentOwner = self:GetOwner( )
        self:GetOwner( ):EmitSound( "meme.mp3" )
    end

    self:SetNextSecondaryFire( CurTime( ) + 3 )
end

function SWEP:Reload( )
    return false
end

function SWEP:DoImpactEffect( trace , damageType )
    local effectdata = EffectData( )
    effectdata:SetStart( trace.HitPos )
    effectdata:SetOrigin( trace.HitNormal + Vector( math.Rand( -0.5 , 0.5 ) , math.Rand( -0.5 , 0.5 ) , math.Rand( -0.5 , 0.5 ) ) )

    return true
end

function SWEP:FireAnimationEvent( pos , ang , event )
    return true
end

function SWEP:KillSounds( )
    if ( self.BeatSound ) then
        self.BeatSound:Stop( )
        self.BeatSound = nil
    end

    if ( self.LoopSound ) then
        self.LoopSound:Stop( )
        self.LoopSound = nil
    end
end

function SWEP:OnRemove( )
    self:KillSounds( )

    if SERVER && IsValid( self.currentOwner ) then
        self.currentOwner:StopSound( "meme.mp3" )
    end
end

function SWEP:CalcAbsolutePosition( pos , ang )
    self.Pos = pos
    self.Ang = ang

    return
end

/*if ( !self.IronSightsPos ) then return end
  if ( self.NextSecondaryAttack > CurTime() ) then return end

  bIronsights = !self.Weapon:GetNetworkedBool( "Ironsights", false )

  self:SetIronsights( bIronsights )

  self.NextSecondaryAttack = CurTime() + 0.3*/
function SWEP:Think( )
    ironSightStatus = self:GetNWBool( "Ironsights" , false )

    if ironSightStatus == false then
        MsgN( "Ironsights are false, setting to true" )
        self:SetNWBool( "Ironsights" , true )
    end

    /*if !ironSightStatus then
    Msg("Ironsight status is false, setting into ironsight")
    self:SetIronsights( bIronsights )
    ironSightStatus = true
  end*/
    if ( self:GetOwner( ):IsPlayer( ) && ( self:GetOwner( ):KeyReleased( IN_ATTACK ) || !self:GetOwner( ):KeyDown( IN_ATTACK ) ) ) then
        if ( self.BeatSound ) then
            self.BeatSound:ChangeVolume( 1 , 0.1 )
        end

        if ( self.LoopSound ) then
            self.LoopSound:Stop( )
            self.LoopSound = nil
        end
    end

    self:DrawWorldModel( )
end

function SWEP:RenderOverride( )
    self:DrawWorldModel( )
end

function SWEP:OnDrop( )
    self:KillSounds( )
    self.GetOwner = nil

    if SERVER && IsValid( self.currentOwner ) then
        self.currentOwner:StopSound( "meme.mp3" )
    end
end

function SWEP:DrawWorldModel( )
    local hand , offset , rotate

    if !IsValid( self:GetOwner( ) ) then
        self:SetRenderOrigin( self.Pos )
        self:SetRenderAngles( self.Ang )
        self:DrawModel( )

        return
    end

    if !self.Hand then
        self.Hand = self:GetOwner( ):LookupAttachment( "anim_attachment_rh" )
    end

    hand = self:GetOwner( ):GetAttachment( self.Hand )

    if !hand then
        //self:SetRenderOrigin(self:GetNetworkOrigin())
        //self:SetRenderAngles(self:GetNetworkAngles())
        self:SetRenderOrigin( self.Pos )
        self:SetRenderAngles( self.Ang )
        self:DrawModel( )

        return
    end

    offset = hand.Ang:Right( ) * self.Offset.Pos.Right + hand.Ang:Forward( ) * self.Offset.Pos.Forward + hand.Ang:Up( ) * self.Offset.Pos.Up
    hand.Ang:RotateAroundAxis( hand.Ang:Right( ) , self.Offset.Ang.Right )
    hand.Ang:RotateAroundAxis( hand.Ang:Forward( ) , self.Offset.Ang.Forward )
    hand.Ang:RotateAroundAxis( hand.Ang:Up( ) , self.Offset.Ang.Up )
    if self.SetRenderOrigin == nil || self.SetRenderAngles == nil then return end
    self:SetRenderOrigin( hand.Pos + offset )
    self:SetRenderAngles( hand.Ang )
    self:DrawModel( )
end

function SWEP:Deploy( )
    self:SendWeaponAnim( ACT_VM_DRAW )
    self:SetNextPrimaryFire( CurTime( ) + self:SequenceDuration( ) )
    if ( CLIENT ) then return true end
    self.BeatSound = CreateSound( self:GetOwner( ) , Sound( "weapons/musicboxgun/songs/dullsounds/popstar_loop.wav" ) )

    if ( self.BeatSound ) then
        self.BeatSound:Play( )
    end

    return true
end

function SWEP:Holster( )
    self:KillSounds( )

    if SERVER && IsValid( self.currentOwner ) then
        self.currentOwner:StopSound( "meme.mp3" )
    end

    return true
end

local IRONSIGHT_TIME = 0.25

/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------*/
function SWEP:GetViewModelPosition( pos , ang )
    if ( !self.IronSightsPos ) then return pos , ang end
    local bIron = self:GetNWBool( "Ironsights" )

    if ( bIron != self.bLastIron ) then
        self.bLastIron = bIron
        self.fIronTime = CurTime( )

        if ( bIron ) then
            self.SwayScale = 0.3
            self.BobScale = 0.1
        else
            self.SwayScale = 1.0
            self.BobScale = 1.0
        end
    end

    local fIronTime = self.fIronTime || 0
    if ( !bIron && fIronTime < CurTime( ) - IRONSIGHT_TIME ) then return pos , ang end
    local Mul = 1.0

    if ( fIronTime > CurTime( ) - IRONSIGHT_TIME ) then
        Mul = math.Clamp( ( CurTime( ) - fIronTime ) / IRONSIGHT_TIME , 0 , 1 )

        if ( !bIron ) then
            Mul = 1 - Mul
        end
    end

    local Offset = self.IronSightsPos

    if ( self.IronSightsAng ) then
        ang = ang * 1
        ang:RotateAroundAxis( ang:Right( ) , self.IronSightsAng.x * Mul )
        ang:RotateAroundAxis( ang:Up( ) , self.IronSightsAng.y * Mul )
        ang:RotateAroundAxis( ang:Forward( ) , self.IronSightsAng.z * Mul )
    end

    local Right = ang:Right( )
    local Up = ang:Up( )
    local Forward = ang:Forward( )
    pos = pos + Offset.x * Right * Mul
    pos = pos + Offset.y * Forward * Mul
    pos = pos + Offset.z * Up * Mul

    return pos , ang
end