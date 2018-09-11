class ClassicWeap_Shotgun_M4 extends KFWeap_Shotgun_M4;

defaultproperties
{
    // Ineventory
    InventorySize=8
    GroupPriority=70

    // DEFAULT_FIREMODE
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Bullet_Pellet'
    InstantHitDamage(DEFAULT_FIREMODE)=35.0
    FireInterval(DEFAULT_FIREMODE)=0.2
    
    // Shotgun
    NumPellets(DEFAULT_FIREMODE)=7

    // Ammo
    MagazineCapacity[0]=6
    SpareAmmoCapacity[0]=42
    InitialSpareMags[0]=4

    // Recoil
    RecoilRate=0.05
}