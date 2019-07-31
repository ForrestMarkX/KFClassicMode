class ClassicPawn_ZedCrawler_Default extends KFPawn_ZedCrawler implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

defaultproperties
{
    ElitePawnClass.Empty
    ElitePawnClass.Add(class'ClassicPawn_ZedCrawlerKing_Default')
}
