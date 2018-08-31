class ClassicWeap_AssaultRifle_AK12 extends KFWeap_AssaultRifle_AK12;

defaultproperties
{
	// Ammo
	SpareAmmoCapacity[0]=270

	// Recoil
	RecoilRate=0.07

	// Inventory / Grouping
	GroupPriority=95

	// DEFAULT_FIREMODE
	FireInterval(DEFAULT_FIREMODE)=+0.109
	Spread(DEFAULT_FIREMODE)=0.015
	InstantHitDamage(DEFAULT_FIREMODE)=45.0

	// ALT_FIREMODE
	FireInterval(ALTFIRE_FIREMODE)=+0.06
	InstantHitDamage(ALTFIRE_FIREMODE)=45.0
	Spread(ALTFIRE_FIREMODE)=0.015
	BurstAmount=3
}
