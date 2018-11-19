class ClassicWeap_AssaultRifle_Thompson extends KFWeap_AssaultRifle_Thompson;

defaultproperties
{
    // Ammo
    MagazineCapacity[0]=30
    SpareAmmoCapacity[0]=270
    InitialSpareMags[0]=4

    //Recoil
    RecoilRate=0.08
    
    // Inventory
    InventorySize=5
    GroupPriority=120

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.09
    Spread(ALTFIRE_FIREMODE)=0.01
    InstantHitDamage(DEFAULT_FIREMODE)=40.0

    // ALTFIRE_FIREMODE
    FireInterval(ALTFIRE_FIREMODE)=+0.09
    InstantHitDamage(ALTFIRE_FIREMODE)=40.0
    Spread(DEFAULT_FIREMODE)=0.01
    
    AssociatedPerkClasses(0)=class'KFPerk_Commando'
}
