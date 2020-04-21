class ClassicPawn_ZedPatriarch_Default extends KFPawn_ZedPatriarch implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);
`include(ClassicMonsterBoss.uci);

defaultproperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Patriarch_Archetype'
}