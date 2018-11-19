class ClassicWeap_Bow_Crossbow extends KFWeap_Bow_Crossbow;

simulated function StopFire(byte FireModeNum)
{
    Super.StopFire(FireModeNum);
    ForceReload();
}

defaultproperties
{
    // Inventory
    InventorySize=9
    GroupPriority=140
    
    // Ammo
    SpareAmmoCapacity[0]=35
    InitialSpareMags[0]=11
    AmmoPickupScale[0]=6.0

    // DEFAULT_FIREMODE
    FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Bolt_Crossbow'
    InstantHitDamage(DEFAULT_FIREMODE)=300.0
    InstantHitDamageTypes(DEFAULT_FIREMODE)=class'ClassicDT_Piercing_Crossbow'
    FireInterval(DEFAULT_FIREMODE)=1.3
}
