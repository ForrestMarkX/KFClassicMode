class ClassicWeap_Pistol_Deagle extends KFWeap_Pistol_Deagle;

defaultproperties
{
	// Ammo
	MagazineCapacity[0]=8
	SpareAmmoCapacity[0]=88
	InitialSpareMags[0]=5

	// DEFAULT_FIREMODE
	FireInterval(DEFAULT_FIREMODE)=+0.25
	InstantHitDamage(DEFAULT_FIREMODE)=115.0

	// Inventory
	GroupPriority=100

	DualClass=class'ClassicWeap_Pistol_DualDeagle'
	
	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'
}
