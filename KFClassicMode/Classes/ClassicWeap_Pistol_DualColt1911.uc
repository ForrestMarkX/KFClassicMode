class ClassicWeap_Pistol_DualColt1911 extends KFWeap_Pistol_DualColt1911;

defaultproperties
{
	SingleClass=class'ClassicWeap_Pistol_Colt1911'
	
	// Ammo
	MagazineCapacity[0]=24
	SpareAmmoCapacity[0]=264
	InitialSpareMags[0]=3

	// DEFAULT_FIREMODE
	FireInterval(DEFAULT_FIREMODE)=+0.12
	InstantHitDamage(DEFAULT_FIREMODE)=80.0
	Spread(DEFAULT_FIREMODE)=0.01

	// ALTFIRE_FIREMODE
	FireInterval(ALTFIRE_FIREMODE)=+0.12
	InstantHitDamage(ALTFIRE_FIREMODE)=80.0
	Spread(ALTFIRE_FIREMODE)=0.01

	// Inventory
	InventorySize=4
	GroupPriority=90
	
	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'
}
