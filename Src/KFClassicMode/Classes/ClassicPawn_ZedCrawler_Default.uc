class ClassicPawn_ZedCrawler_Default extends KFPawn_ZedCrawler implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

defaultproperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Crawler_Archetype'
    
    ElitePawnClass.Empty
    ElitePawnClass.Add(class'ClassicPawn_ZedCrawlerKing_Default')
}
