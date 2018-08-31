class ClassicWeap_Shotgun_HZ12 extends KFWeap_Shotgun_HZ12;

defaultproperties
{
	// Inventory
	InventorySize=6
	GroupPriority=100

	// DEFAULT_FIREMODE
	WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Bullet_Pellet'
	InstantHitDamage(DEFAULT_FIREMODE)=19.5
	FireInterval(DEFAULT_FIREMODE)=0.082
	
	// Shotgun
	NumPellets(DEFAULT_FIREMODE)=12

	// Ammo
	MagazineCapacity[0]=12
	SpareAmmoCapacity[0]=36
	InitialSpareMags[0]=2

	// Recoil
	RecoilRate=0.05
}
