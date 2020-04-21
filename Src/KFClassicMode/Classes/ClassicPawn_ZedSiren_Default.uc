class ClassicPawn_ZedSiren_Default extends KFPawn_ZedSiren implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

defaultproperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Siren_Archetype'
}
