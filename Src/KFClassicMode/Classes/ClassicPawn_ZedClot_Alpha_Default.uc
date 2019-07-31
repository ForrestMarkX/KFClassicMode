class ClassicPawn_ZedClot_Alpha_Default extends KFPawn_ZedClot_Alpha implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

DefaultProperties
{
    ElitePawnClass.Empty
    ElitePawnClass.Add(class'ClassicPawn_ZedClot_AlphaKing_Default')
}
