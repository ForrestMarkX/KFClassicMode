class ClassicPawn_ZedGorefast_Default extends KFPawn_ZedGorefast implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

DefaultProperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Gorefast_Archetype'
    
    ElitePawnClass.Empty
    ElitePawnClass.Add(class'ClassicPawn_ZedGorefastDualBlade_Default')
}
