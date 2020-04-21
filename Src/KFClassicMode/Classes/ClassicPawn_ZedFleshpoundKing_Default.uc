class ClassicPawn_ZedFleshpoundKing_Default extends KFPawn_ZedFleshpoundKing 
    implements(KFZEDBossInterface);

`define OVERRIDEHEADEXPLODEFUNC true
`define OVERRIDEDISMEMBERMENTFUNC true
`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);
`include(ClassicMonsterBoss.uci);

simulated function float GetShieldHealthPercent()
{
    return LastShieldHealthPct;
}

simulated function ParticleSystemComponent GetShieldPSC()
{
    return InvulnerableShieldPSC;
}

DefaultProperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_FleshpoundKing_Archetype'
}