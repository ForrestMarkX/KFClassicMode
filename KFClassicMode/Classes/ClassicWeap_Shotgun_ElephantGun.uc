class ClassicWeap_Shotgun_ElephantGun extends KFWeap_Shotgun_ElephantGun;

defaultproperties
{
	// Inventory
	InventorySize=16
	GroupPriority=110

	// DEFAULT_FIREMODE
	WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Bullet_Pellet'
	NumPellets(DEFAULT_FIREMODE)=10
	InstantHitDamage(DEFAULT_FIREMODE)=72.0

	// ALT_FIREMODE
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'ClassicProj_Bullet_Pellet'
	NumPellets(ALTFIRE_FIREMODE)=40
	InstantHitDamage(ALTFIRE_FIREMODE)=72.0
	
	DoubleBarrelKickMomentum=5

	// Recoil
	RecoilRate=0.05
}