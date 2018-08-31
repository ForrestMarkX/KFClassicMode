class ClassicWeap_Rifle_M14EBR extends KFWeap_Rifle_M14EBR;

defaultproperties
{
	// Inventory / Grouping
	InventorySize=8
	GroupPriority=165
	
	// Ammo
	SpareAmmoCapacity[0]=140

	// Recoil
	RecoilRate=0.085

	// DEFAULT_FIREMODE
	FireInterval(DEFAULT_FIREMODE)=0.25
	Spread(DEFAULT_FIREMODE)=0.005
}
