class ClassicWeap_AssaultRifle_M16M203 extends KFWeap_AssaultRifle_M16M203;

function SetOriginalValuesFromPickup( KFWeapon PickedUpWeapon )
{
	local ClassicWeap_AssaultRifle_M16M203 Weap;

	Super.SetOriginalValuesFromPickup(PickedUpWeapon);

	if(Role == ROLE_Authority && !Instigator.IsLocallyControlled())
	{
		Weap = ClassicWeap_AssaultRifle_M16M203(PickedUpWeapon);
		ServerTotalAltAmmo = Weap.ServerTotalAltAmmo;
		SpareAmmoCount[1] = ServerTotalAltAmmo - AmmoCount[1];
	}
	else
	{
		SpareAmmoCount[1] = PickedUpWeapon.SpareAmmoCount[1];
	}
}

defaultproperties
{
	// Ammo
	InitialSpareMags[0]=4
	InitialSpareMags[1]=5
	SpareAmmoCapacity[1]=11

    // Inventory / Grouping
	GroupPriority=190
	
   	AssociatedPerkClasses(1)=class'KFPerk_Demolitionist'

	// DEFAULT_FIREMODE
	Spread(DEFAULT_FIREMODE)=0.015

	// ALT_FIREMODE
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'ClassicProj_HighExplosive_M16M203'
	InstantHitDamage(ALTFIRE_FIREMODE)=350.0
	Spread(ALTFIRE_FIREMODE)=0.015
}
