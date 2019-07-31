class ClassicPawn_ZedGorefast_Default extends KFPawn_ZedGorefast implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

DefaultProperties
{
    ElitePawnClass.Empty
    ElitePawnClass.Add(class'ClassicPawn_ZedGorefastDualBlade_Default')
}
