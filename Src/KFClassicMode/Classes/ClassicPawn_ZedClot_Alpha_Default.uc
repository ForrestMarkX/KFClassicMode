class ClassicPawn_ZedClot_Alpha_Default extends KFPawn_ZedClot_Alpha implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

DefaultProperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Clot_Alpha_Archetype'
    
    ElitePawnClass.Empty
    ElitePawnClass.Add(class'ClassicPawn_ZedClot_AlphaKing_Default')
}
