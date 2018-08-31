class ClassicWeap_SMG_HK_UMP extends KFWeap_SMG_HK_UMP;

defaultproperties
{
    // Inventory
    InventorySize=6
    GroupPriority=115
	
    // Ammo
    SpareAmmoCapacity[0]=270
    InitialSpareMags[0]=3

	// Recoil
    RecoilRate=0.07

    // DEFAULT_FIREMODE
    Spread(DEFAULT_FIREMODE)=0.009
    InstantHitDamage(DEFAULT_FIREMODE)=45

    // ALT_FIREMODE
    InstantHitDamage(ALTFIRE_FIREMODE)=45
    Spread(ALTFIRE_FIREMODE)=0.009
	
    AssociatedPerkClasses(0)=class'KFPerk_Commando'
}
