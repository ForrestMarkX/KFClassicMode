class ClassicWeap_Pistol_DualFlare extends KFWeap_Pistol_DualFlare;

simulated function RepositionUsedBullets( int FirstIndex, int UsedStartIdx, int UsedEndIdx )
{
    if( BulletMeshComponents.Length>0 )
    {
        Super.RepositionUsedBullets(FirstIndex, UsedStartIdx, Clamp(UsedEndIdx, 0, UsedStartIdx));
    }
}

defaultproperties
{
    // Ammo
    SpareAmmoCapacity[0]=360

    // Recoil
    RecoilRate=0.07

    // DEFAULT_FIREMODE
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_FlareGun'
    FireInterval(DEFAULT_FIREMODE)=+0.2
    InstantHitDamage(DEFAULT_FIREMODE)=100.0
    Spread(DEFAULT_FIREMODE)=0.017500

    // ALTFIRE_FIREMODE
    WeaponProjectiles(ALTFIRE_FIREMODE)=class'ClassicProj_FlareGun'
    FireInterval(ALTFIRE_FIREMODE)=+0.2
    InstantHitDamage(ALTFIRE_FIREMODE)=100.0
    Spread(ALTFIRE_FIREMODE)=0.017500
    
    // Inventory
    InventorySize=4
    GroupPriority=120
    
    bHasFlashlight=True
    
    SingleClass=class'ClassicWeap_Pistol_Flare'
    
       AssociatedPerkClasses(1)=class'KFPerk_Firebug'
}
