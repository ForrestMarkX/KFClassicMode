class ClassicPawn_ZedBloatKing_Default extends KFPawn_ZedBloatKing implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`define OVERRIDEHEADEXPLODEFUNC true
`define OVERRIDEDISMEMBERMENTFUNC true
`include(ClassicMonster.uci);
`include(ClassicMonsterBoss.uci);

defaultproperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_BloatKing_Archetype'
}