class ClassicWeap_Rifle_Winchester1894 extends KFWeap_Rifle_Winchester1894;

defaultproperties
{
	// Inventory / Grouping
	InventorySize=6
	GroupPriority=85
	
   	AssociatedPerkClasses(1)=class'KFPerk_Sharpshooter'
	
	// Ammo
	MagazineCapacity[0]=10
	SpareAmmoCapacity[0]=70
	InitialSpareMags[0]=3

	// Recoil
	RecoilRate=0.1

	// DEFAULT_FIREMODE
	InstantHitDamage(DEFAULT_FIREMODE)=140
	FireInterval(DEFAULT_FIREMODE)=0.9
}
