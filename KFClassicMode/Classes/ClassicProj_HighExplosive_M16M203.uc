class ClassicProj_HighExplosive_M16M203 extends KFProj_HighExplosive_M16M203;

defaultproperties
{
    Speed=8000
    MaxSpeed=8000
    TerminalVelocity=8000
    LifeSpan=+10.0f

    // explosion
    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=350
        DamageRadius=375
        DamageFalloffExponent=1.5
    End Object
}
