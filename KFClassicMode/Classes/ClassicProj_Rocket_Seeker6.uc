class ClassicProj_Rocket_Seeker6 extends KFProj_BallisticExplosive;

var private KFPawn LockedTarget;
var const float SeekStrength;

replication
{
    if( bNetInitial )
        LockedTarget;
}

function SetLockedTarget( KFPawn NewTarget )
{
    LockedTarget = NewTarget;
}

simulated event Tick( float DeltaTime )
{
    local vector TargetImpactPos, DirToTarget;

    super.Tick( DeltaTime );

    if( !bHasExploded
        && LockedTarget != none
        && Physics == PHYS_Projectile
        && Velocity != vect(0,0,0)
        && LockedTarget.IsAliveAndWell()
        && `TimeSince(CreationTime) > 0.03f )
    {
        TargetImpactPos = class'ClassicWeap_RocketLauncher_Seeker6'.static.GetLockedTargetLoc( LockedTarget );

        Speed = VSize( Velocity );
        DirToTarget = Normal( TargetImpactPos - Location );
        Velocity = Normal( Velocity + (DirToTarget * (SeekStrength * DeltaTime)) ) * Speed;

        SetRotation( rotator(Velocity) );
    }
}

defaultproperties
{
    Physics=PHYS_Projectile
    Speed=4000
    MaxSpeed=4000
    TossZ=0
    GravityScale=0.8
    MomentumTransfer=50000.0f
    ArmDistSquared=110000.0f
    SeekStrength=928000.0f
    bWarnAIWhenFired=true
    ProjFlightTemplate=ParticleSystem'WEP_SeekerSix_EMIT.FX_SeekerSix_Projectile'
    ProjFlightTemplateZedTime=ParticleSystem'WEP_SeekerSix_EMIT.FX_SeekerSix_Projectile_ZED_TIME'
    ProjDudTemplate=ParticleSystem'WEP_SeekerSix_EMIT.FX_SeekerSix_Projectile_Dud'
    GrenadeBounceEffectInfo=KFImpactEffectInfo'WEP_RPG7_ARCH.RPG7_Projectile_Impacts'
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
    AmbientSoundPlayEvent=AkEvent'WW_WEP_Seeker_6.Play_WEP_Seeker_6_Projectile'
    AmbientSoundStopEvent=AkEvent'WW_WEP_Seeker_6.Stop_WEP_Seeker_6_Projectile'
    AltExploEffects=KFImpactEffectInfo'WEP_SeekerSix_ARCH.FX_SeekerSix_Explosion_Concussive_force'
    
    Begin Object Class=PointLightComponent Name=ExplosionPointLight
        LightColor=(R=252,G=218,B=171,A=255)
        Brightness=4.f
        Radius=2000.f
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=False
        bCastPerObjectShadows=false
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=150
        DamageRadius=150
        DamageFalloffExponent=2
        DamageDelay=0.f
        MyDamageType=class'KFDT_Explosive_Seeker6'
        KnockDownStrength=0
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'WEP_SeekerSix_ARCH.FX_SeekerSix_Explosion'
        ExplosionSound=AkEvent'WW_WEP_Seeker_6.Play_WEP_Seeker_6_Explosion'
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2
        CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Seeker6'
        CamShakeInnerRadius=180
        CamShakeOuterRadius=500
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    ExplosionTemplate=ExploTemplate0
}
