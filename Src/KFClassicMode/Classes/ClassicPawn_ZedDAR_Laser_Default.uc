class ClassicPawn_ZedDAR_Laser_Default extends KFPawn_ZedDAR_Laser implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

defaultproperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_DAR_Laser_Archetype'
}
