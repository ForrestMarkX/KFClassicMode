class ClassicPawn_ZedHusk_Default extends KFPawn_ZedHusk implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

DefaultProperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Husk_Archetype'
    
    ElitePawnClass.Empty
    ElitePawnClass.Add(class'ClassicPawn_ZedDAR_EMP_Default')
    ElitePawnClass.Add(class'ClassicPawn_ZedDAR_Laser_Default')
    ElitePawnClass.Add(class'ClassicPawn_ZedDAR_Rocket_Default')
}
