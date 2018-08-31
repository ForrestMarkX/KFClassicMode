class ClassicWeap_SMG_P90 extends KFWeap_SMG_P90;

defaultproperties
{
	// Inventory
	InventorySize=6
	GroupPriority=130

	// Recoil
	RecoilRate=0.065

	// DEFAULT_FIREMODE
	FireInterval(DEFAULT_FIREMODE)=+.075
	Spread(DEFAULT_FIREMODE)=0.008
	InstantHitDamage(DEFAULT_FIREMODE)=30

	// ALT_FIREMODE
	FireInterval(ALTFIRE_FIREMODE)=+0.1
	Spread(ALTFIRE_FIREMODE)=0.008
	InstantHitDamage(ALTFIRE_FIREMODE)=35
	
	AssociatedPerkClasses(0)=class'KFPerk_Commando'
}
