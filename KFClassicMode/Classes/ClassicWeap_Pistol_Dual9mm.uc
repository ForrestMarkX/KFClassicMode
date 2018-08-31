class ClassicWeap_Pistol_Dual9mm extends KFWeap_Pistol_Dual9mm;

defaultproperties
{
	// Ammo
	SpareAmmoCapacity[0]=450
	InitialSpareMags[0]=7
	
	// DEFAULT_FIREMODE
	FireInterval(DEFAULT_FIREMODE)=+0.1
	InstantHitDamage(DEFAULT_FIREMODE)=35.0
	
	// ALTFIRE_FIREMODE
	FireInterval(ALTFIRE_FIREMODE)=+0.1
	InstantHitDamage(ALTFIRE_FIREMODE)=35.0
	
	// Inventory
	InventorySize=4
	GroupPriority=65
	
	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'
	
	SingleClass=class'KFClassicMode.ClassicWeap_Pistol_9mm'
}
