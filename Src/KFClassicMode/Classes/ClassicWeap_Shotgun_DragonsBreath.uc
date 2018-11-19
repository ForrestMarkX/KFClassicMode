class ClassicWeap_Shotgun_DragonsBreath extends KFWeap_Shotgun_DragonsBreath;

defaultproperties
{
    // Inventory
    InventorySize=8
    GroupPriority=142
    
    // DEFAULT_FIREMODE
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Bullet_DragonsBreath'
    InstantHitDamage(DEFAULT_FIREMODE)=18
    FireInterval(DEFAULT_FIREMODE)=0.965
    Spread(DEFAULT_FIREMODE)=0.1125
    NumPellets(DEFAULT_FIREMODE)=14
    
    // Ammo
    SpareAmmoCapacity[0]=42

    // Recoil
    RecoilRate=0.05
    
    AssociatedPerkClasses(1)=class'KFPerk_Firebug'
    
    ZoomInTime=0.25
    ZoomOutTime=0.25
    FastZoomOutTime=0.2
}