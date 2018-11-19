class ClassicWeap_GrenadeLauncher_M32 extends KFWeap_GrenadeLauncher_M32;

defaultproperties
{
    // Ammo
    MagazineCapacity[0]=6
    SpareAmmoCapacity[0]=36
    InitialSpareMags[0]=2
    AmmoPickupScale[0]=1.0
    
    // Inventory
    InventorySize=7
    GroupPriority=210

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.33
}
