class ClassicWeap_SMG_Mac10 extends KFWeap_SMG_Mac10;

defaultproperties
{
    // Inventory
    GroupPriority=75

    // Ammo
    MagazineCapacity[0]=30
    SpareAmmoCapacity[0]=270

    // Recoil
    RecoilRate=0.05

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+.052
    Spread(DEFAULT_FIREMODE)=0.013
    InstantHitDamage(DEFAULT_FIREMODE)=30

    // ALT_FIREMODE
    FireInterval(ALTFIRE_FIREMODE)=+.052
    InstantHitDamage(ALTFIRE_FIREMODE)=30
    Spread(ALTFIRE_FIREMODE)=0.013
    
    AssociatedPerkClasses(1) = class'KFPerk_Firebug'
}
