class ClassicWeap_Pistol_9mm extends KFWeap_Pistol_9mm;

defaultproperties
{
	// Ammo
	SpareAmmoCapacity[0]=225
	InitialSpareMags[0]=7
	AmmoPickupScale[0]=2.0

	// DEFAULT_FIREMODE
	FireInterval(DEFAULT_FIREMODE)=+0.175
	InstantHitDamage(DEFAULT_FIREMODE)=35.0

	// Inventory
	GroupPriority=60

	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'
	DualClass=class'KFClassicMode.ClassicWeap_Pistol_Dual9mm'
}
