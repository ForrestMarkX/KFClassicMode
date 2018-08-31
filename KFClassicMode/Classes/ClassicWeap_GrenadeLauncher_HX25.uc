class ClassicWeap_GrenadeLauncher_HX25 extends KFWeap_GrenadeLauncher_HX25;

defaultproperties
{
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Explosive_HX25'
	NumPellets(DEFAULT_FIREMODE)=1
	
   	AssociatedPerkClasses(1)=class'KFPerk_Demolitionist'
}
