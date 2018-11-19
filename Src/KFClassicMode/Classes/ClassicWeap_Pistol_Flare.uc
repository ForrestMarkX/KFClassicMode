class ClassicWeap_Pistol_Flare extends KFWeap_Pistol_Flare;

simulated function ClassicResetCylinder( KFWeap_PistolBase Wpn )
{
    local int i, UsedStartIdx, UsedEndIdx;

    Wpn.SetCylinderRotation( Wpn.CylinderRotInfo,0 );
    Wpn.ResetCylinderInfo( Wpn.CylinderRotInfo );
    
    if( Wpn.AmmoCount[Wpn.DEFAULT_FIREMODE]==0 )
        return;
    
    if( Wpn.BulletMeshComponents.Length>0 )
    {
        Wpn.BulletMeshComponents[0].SetSkeletalMesh( Wpn.UnusedBulletMeshTemplate );
        UsedStartIdx = Wpn.BulletMeshComponents.Length - 1;
        UsedEndIdx = Clamp( UsedStartIdx - (Wpn.MagazineCapacity[Wpn.DEFAULT_FIREMODE] - Wpn.AmmoCount[Wpn.DEFAULT_FIREMODE]),0,UsedStartIdx );
        
        for( i=UsedStartIdx; i>UsedEndIdx; i-- )
        {
            if( Wpn.BulletMeshComponents[i]!=None )
            {
                Wpn.BulletMeshComponents[i].SetSkeletalMesh( Wpn.UsedBulletMeshTemplate );
            }
        }
        
        for( i=UsedEndIdx; i>0; i-- )
        {
            if( Wpn.BulletMeshComponents[i]!=None )
            {
                Wpn.BulletMeshComponents[i].SetSkeletalMesh( Wpn.UnusedBulletMeshTemplate );
            }
        }
    }
}

simulated function ResetCylinder()
{
    ClassicResetCylinder(self);
}

defaultproperties
{
    // Ammo
    SpareAmmoCapacity[0]=122
    InitialSpareMags[0]=7
    AmmoPickupScale[0]=3.0

    // Recoil
    RecoilRate=0.07

    // DEFAULT_FIREMODE
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_FlareGun'
    FireInterval(DEFAULT_FIREMODE)=+0.4
    InstantHitDamage(DEFAULT_FIREMODE)=100.0
    Spread(DEFAULT_FIREMODE)=0.017500

    // Inventory
    GroupPriority=105
    
    bHasFlashlight=True
    
    DualClass=class'ClassicWeap_Pistol_DualFlare'
    
    AssociatedPerkClasses(1)=class'KFPerk_Firebug'
    AssociatedPerkClasses(2)=class'KFPerk_Firebug'
}
