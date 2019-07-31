class ClassicPawn_ZedFleshpoundKing_Default extends KFPawn_ZedFleshpoundKing 
    implements(KFZEDBossInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);
`include(ClassicMonsterBoss.uci);

simulated function float GetShieldHealthPercent()
{
    return ByteToFloat(ShieldHealthPctByte);
}

simulated function ParticleSystemComponent GetShieldPSC()
{
    return InvulnerableShieldPSC;
}

DefaultProperties
{
}