class ClassicWeap_RocketLauncher_RPG7 extends KFWeap_RocketLauncher_RPG7;

defaultproperties
{
    // Inventory
    InventorySize=13
    GroupPriority=195
    
    // Ammo
    SpareAmmoCapacity[0]=9
    InitialSpareMags[0]=5

    // DEFAULT_FIREMODE
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Rocket_RPG7'
    InstantHitDamage(DEFAULT_FIREMODE)=200.0
    Spread(DEFAULT_FIREMODE)=0.1
}
