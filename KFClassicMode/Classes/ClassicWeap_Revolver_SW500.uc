class ClassicWeap_Revolver_SW500 extends KFWeap_Revolver_SW500;

defaultproperties
{
    // Ammo
    MagazineCapacity[0]=6
    SpareAmmoCapacity[0]=122
    InitialSpareMags[0]=10
    AmmoPickupScale[0]=3.0

    // Recoil
    RecoilRate=0.07

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.15
    InstantHitDamage(DEFAULT_FIREMODE)=105.0
    Spread(DEFAULT_FIREMODE)=0.009
    
    // Inventory
    GroupPriority=105
    
    AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'

    DualClass=class'ClassicWeap_Revolver_DualSW500'
    
    Begin Object Class=KFSkeletalMeshComponent Name=BulletMeshComp5
        SkeletalMesh=SkeletalMesh'WEP_1P_SW_500_MESH.Wep_1stP_SW_500_Bullet'
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        BlockRigidBody=false
        bAcceptsStaticDecals=false
        bAcceptsDecals=false
        CastShadow=false
        bUseAsOccluder=false
        DepthPriorityGroup=SDPG_Foreground // First person only
    End Object
    Components.Add(BulletMeshComp5)
    BulletMeshComponents.Add(BulletMeshComp5)
}
