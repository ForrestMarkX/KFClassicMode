class ClassicPawn_ZedDAR_EMP_Default extends KFPawn_ZedDAR_EMP implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

defaultproperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_DAR_EMP_Archetype'
}
