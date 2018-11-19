class ClassicWeap_AssaultRifle_MKB42 extends KFWeap_AssaultRifle_MKB42;

defaultproperties
{
    // Ammo
    MagazineCapacity[0]=30
    SpareAmmoCapacity[0]=300
    InitialSpareMags[0]=3

    //Recoil
    RecoilRate=0.07
    
    // Inventory
    InventorySize=6
    GroupPriority=115

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.1
    Spread(DEFAULT_FIREMODE)=0.009
    InstantHitDamage(DEFAULT_FIREMODE)=45.0

    // ALTFIRE_FIREMODE
    FireInterval(ALTFIRE_FIREMODE)=+0.1
    InstantHitDamage(ALTFIRE_FIREMODE)=45.0
    Spread(ALTFIRE_FIREMODE)=0.009
}
