class ClassicWeap_AssaultRifle_FNFal extends KFWeap_AssaultRifle_FNFal;

defaultproperties
{
    // Ammo
    MagazineCapacity[0]=20
    SpareAmmoCapacity[0]=300
    InitialSpareMags[0]=5

    //Recoil
    RecoilRate=0.08
    
    // Inventory
    InventorySize=6
    GroupPriority=180

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.0857
    Spread(DEFAULT_FIREMODE)=0.0085
    InstantHitDamage(DEFAULT_FIREMODE)=65.0

    // ALTFIRE_FIREMODE
    FireInterval(ALTFIRE_FIREMODE)=+0.0857
    Spread(ALTFIRE_FIREMODE)=0.0085
    InstantHitDamage(ALTFIRE_FIREMODE)=65.0

    AssociatedPerkClasses(0)=class'KFPerk_Commando'
}
