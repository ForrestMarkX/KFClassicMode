class ClassicWeap_Shotgun_DoubleBarrel extends KFWeap_Shotgun_DoubleBarrel;

defaultproperties
{
	// Inventory
	InventorySize=10
	GroupPriority=60

	// DEFAULT_FIREMODE
	WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Bullet_Pellet'
	InstantHitDamage(DEFAULT_FIREMODE)=50.0
	NumPellets(DEFAULT_FIREMODE)=10
	
	// ALT_FIREMODE
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'ClassicProj_Bullet_Pellet'
	InstantHitDamage(ALTFIRE_FIREMODE)=50.0
	NumPellets(ALTFIRE_FIREMODE)=20
	
	DoubleBarrelKickMomentum=5
	
	// Ammo
	AmmoPickupScale[0]=5.0
	
	RecoilRate=0.07
}