class ClassicWeap_Shotgun_Nailgun extends KFWeap_Shotgun_Nailgun;

defaultproperties
{
    // Inventory
    InventorySize=8

    // DEFAULT_FIREMODE
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Nail_Nailgun'
    InstantHitDamage(DEFAULT_FIREMODE)=35
    FireInterval(DEFAULT_FIREMODE)=0.5
    
    // Shotgun
    NumPellets(DEFAULT_FIREMODE)=7

    // ALT_FIREMODE
    WeaponProjectiles(ALTFIRE_FIREMODE)=class'ClassicProj_Nail_Nailgun'
    InstantHitDamage(ALTFIRE_FIREMODE)=35
    FireInterval(ALTFIRE_FIREMODE)=0.5
    
    // Shotgun
    NumPellets(ALTFIRE_FIREMODE)=1

    // Recoil
    RecoilRate=0.05

    AssociatedPerkClasses(0)=class'KFPerk_Support'
}