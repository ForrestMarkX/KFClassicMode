class ClassicWeap_Rifle_M99 extends KFWeap_Rifle_M99;

defaultproperties
{
	// Inventory / Grouping
	InventorySize=13
	GroupPriority=190
	
	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=24
	InitialSpareMags[0]=4

	// Recoil
	RecoilRate=0.1

	// DEFAULT_FIREMODE
	InstantHitDamage(DEFAULT_FIREMODE)=675
	Spread(DEFAULT_FIREMODE)=0.004

	// Fire Effects
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_M99.Play_WEP_M99_DryFire'
}
