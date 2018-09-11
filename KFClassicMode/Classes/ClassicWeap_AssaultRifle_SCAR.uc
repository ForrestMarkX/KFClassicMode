class ClassicWeap_AssaultRifle_SCAR extends KFWeap_AssaultRifle_SCAR;

defaultproperties
{
    // Ammo
    SpareAmmoCapacity[0]=280
    InitialSpareMags[0]=5

    // Recoil
    RecoilRate=0.07

    // Inventory
    GroupPriority=175

    // DEFAULT_FIREMODE
    Spread(DEFAULT_FIREMODE)=0.0075
    InstantHitDamage(DEFAULT_FIREMODE)=60.0

    // ALT_FIREMODE
    InstantHitDamage(ALTFIRE_FIREMODE)=60.0
    Spread(ALTFIRE_FIREMODE)=0.0075
}
