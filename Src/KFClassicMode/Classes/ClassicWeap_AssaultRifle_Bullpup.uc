class ClassicWeap_AssaultRifle_Bullpup extends KFWeap_AssaultRifle_Bullpup;

defaultproperties
{
    // Ammo
    MagazineCapacity[0]=40
    SpareAmmoCapacity[0]=360
    InitialSpareMags[0]=3

    // Recoil
    RecoilRate=0.07

    // Inventory / Grouping
    GroupPriority=70

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.1
    InstantHitDamage(DEFAULT_FIREMODE)=26.0

    // ALT_FIREMODE
    FireInterval(ALTFIRE_FIREMODE)=+0.1
    InstantHitDamage(ALTFIRE_FIREMODE)=26.0
}
