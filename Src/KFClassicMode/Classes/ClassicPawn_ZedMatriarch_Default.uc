class ClassicPawn_ZedMatriarch_Default extends KFPawn_ZedMatriarch 
    implements(KFZEDBossInterface);

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
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Matriarch_Archetype'
}
