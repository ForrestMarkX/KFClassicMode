class ClassicProj_Missile_Patriarch extends KFProj_Missile_Patriarch;

simulated function PostBeginPlay()
{
    if (WorldInfo.Game != none)
    {
        if( WorldInfo.Game.NumPlayers == 1 )
        {
            if( WorldInfo.Game.GameDifficulty < 1 )
            {
                Damage = default.Damage * 0.25;
            }
            else if( WorldInfo.Game.GameDifficulty < 2 )
            {
                Damage = default.Damage * 0.375;
            }
            else if( WorldInfo.Game.GameDifficulty < 3 )
            {
                Damage = default.Damage * 1.15;
            }
            else // Hardest difficulty
            {
                Damage = default.Damage * 1.3;
            }
        }
        else
        {
            if( WorldInfo.Game.GameDifficulty < 1 )
            {
                Damage = default.Damage * 0.375;
            }
            else if( WorldInfo.Game.GameDifficulty < 2 )
            {
                Damage = default.Damage * 1.0;
            }
            else if( WorldInfo.Game.GameDifficulty < 3 )
            {
                Damage = default.Damage * 1.15;
            }
            else // Hardest difficulty
            {
                Damage = default.Damage * 1.3;
            }
        }
    }

    super.PostBeginPlay();
}

defaultproperties
{
    ProjFlightTemplate=ParticleSystem'WEP_RPG7_EMIT.FX_RPG7_Projectile'
    ProjFlightTemplateZedTime=ParticleSystem'WEP_RPG7_EMIT.FX_RPG7_Projectile_ZED_TIME'
    
    Speed=11700
    MaxSpeed=11700
    
    // Grenade explosion light
    Begin Object Name=ExplosionPointLight
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

    // explosion
    Begin Object Name=ExploTemplate0
        Damage=950
        DamageRadius=500
        DamageFalloffExponent=2.f
        DamageDelay=0.f

        // Damage Effects
        MyDamageType=class'KFDT_Explosive_PatMissile'
        KnockDownStrength=0
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'WEP_RPG7_ARCH.RPG7_Explosion'
        ExplosionSound=AkEvent'WW_WEP_SA_RPG7.Play_WEP_SA_RPG7_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=200
        CamShakeOuterRadius=900
        CamShakeFalloff=1.5f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
}