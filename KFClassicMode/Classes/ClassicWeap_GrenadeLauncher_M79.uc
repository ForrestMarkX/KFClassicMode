class ClassicWeap_GrenadeLauncher_M79 extends KFWeap_GrenadeLauncher_M79;

defaultproperties
{
    // Inventory
    GroupPriority=162
    InventorySize=4
    
    // Ammo
    SpareAmmoCapacity[0]=25
    InitialSpareMags[0]=11
    AmmoPickupScale[0]=3.0

    // DEFAULT_FIREMODE
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_HighExplosive_M79'
    InstantHitDamage(DEFAULT_FIREMODE)=350.0
}
