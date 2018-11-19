class ClassicProj_Rocket_RPG7 extends KFProj_Rocket_RPG7;

defaultproperties
{
    Speed=5200
    MaxSpeed=6000
    LifeSpan=+10
    GravityScale=.25
    MomentumTransfer=125000.0

    // explosion
    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=950
        DamageRadius=500
        DamageFalloffExponent=2.2
    End Object
}
