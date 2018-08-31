class ClassicWeap_Shotgun_MB500 extends KFWeap_Shotgun_MB500;

defaultproperties
{
	// Inventory
	InventorySize=8
	GroupPriority=35

	// DEFAULT_FIREMODE
	WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Bullet_Pellet'
	InstantHitDamage(DEFAULT_FIREMODE)=35.0
	
	// Shotgun
	NumPellets(DEFAULT_FIREMODE)=7
	
	// Ammo
	MagazineCapacity[0]=8
	SpareAmmoCapacity[0]=40
	InitialSpareMags[0]=3
}