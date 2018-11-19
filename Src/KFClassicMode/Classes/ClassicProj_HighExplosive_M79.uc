class ClassicProj_HighExplosive_M79 extends KFProj_HighExplosive_M79;

defaultproperties
{
    Physics=PHYS_Falling
    Speed=8000
    MaxSpeed=8000
    TerminalVelocity=8000
    GravityScale=.25
    MomentumTransfer=75000.0
    ArmDistSquared=90000
    LifeSpan=+10.0f

    // explosion
    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=200
        DamageRadius=400
        DamageFalloffExponent=1.8
    End Object
}

