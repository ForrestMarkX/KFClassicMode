class ClassicPawn_ZedHans_Default extends KFPawn_ZedHans 
    implements(KFZEDBossInterface);

`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);
`include(ClassicMonsterBoss.uci);

function PossessedBy( Controller C, bool bVehicleTransition )
{
    local KFEventHelper Helper;
    
    Super.PossessedBy( C, bVehicleTransition );
    
    Helper = class'KFEventHelper'.static.FindEventHelper(WorldInfo);
    if( Helper != None )
    {
        ExplosiveGrenadeClass = SeasonalExplosiveGrenadeClasses[Helper.GetSeasonalID()];
        NerveGasGrenadeClass = SeasonalNerveGasGrenadeClasses[Helper.GetSeasonalID()];
        SmokeGrenadeClass = SeasonalSmokeGrenadeClasses[Helper.GetSeasonalID()];
    }
}

simulated function float GetShieldHealthPercent()
{
    return LastShieldHealthPct;
}

simulated function ParticleSystemComponent GetShieldPSC()
{
    return InvulnerableShieldPSC;
}

DefaultProperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Hans_Archetype'
}
