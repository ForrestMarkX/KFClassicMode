class ClassicPawn_ZedStalker_Default extends KFPawn_ZedStalker implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

DefaultProperties
{
    ElitePawnClass.Empty
    ElitePawnClass.Add(class'ClassicPawn_ZedDAR_EMP_Default')
    ElitePawnClass.Add(class'ClassicPawn_ZedDAR_Laser_Default')
    ElitePawnClass.Add(class'ClassicPawn_ZedDAR_Rocket_Default')
}
