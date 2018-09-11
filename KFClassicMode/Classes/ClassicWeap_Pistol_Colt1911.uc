class ClassicWeap_Pistol_Colt1911 extends KFWeap_Pistol_Colt1911;

defaultproperties
{
    // Ammo
    MagazineCapacity[0]=12
    SpareAmmoCapacity[0]=132
    InitialSpareMags[0]=5
    AmmoPickupScale[0]=2.0

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.18
    InstantHitDamage(DEFAULT_FIREMODE)=80.0
    Spread(DEFAULT_FIREMODE)=0.01

    // Inventory
    InventorySize=2
    GroupPriority=65

    DualClass=class'ClassicWeap_Pistol_DualColt1911'
    
    AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'
}
