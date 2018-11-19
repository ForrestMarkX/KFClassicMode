class ClassicWeap_Shotgun_AA12 extends KFWeap_Shotgun_AA12;

defaultproperties
{
    // Inventory
    InventorySize=10

    // DEFAULT_FIREMODE
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Bullet_Pellet'
    InstantHitDamage(DEFAULT_FIREMODE)=30.0

    // ALT_FIREMODE
    WeaponProjectiles(ALTFIRE_FIREMODE)=class'ClassicProj_Bullet_Pellet'
    InstantHitDamage(ALTFIRE_FIREMODE)=30.0

    // Shotgun
    NumPellets(DEFAULT_FIREMODE)=5
    NumPellets(ALTFIRE_FIREMODE)=5

    // Ammo
    SpareAmmoCapacity[0]=60
    InitialSpareMags[0]=3
}