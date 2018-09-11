class ClassicWeap_Pistol_DualDeagle extends KFWeap_Pistol_DualDeagle;

defaultproperties
{
    // Ammo
    MagazineCapacity[0]=16
    SpareAmmoCapacity[0]=176
    InitialSpareMags[0]=3

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.13
    InstantHitDamage(DEFAULT_FIREMODE)=115.0

    // ALTFIRE_FIREMODE
    FireInterval(ALTFIRE_FIREMODE)=+0.13
    InstantHitDamage(ALTFIRE_FIREMODE)=115.0

    // Inventory
    GroupPriority=125
    
    SingleClass=class'ClassicWeap_Pistol_Deagle'
    
    AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'
}
