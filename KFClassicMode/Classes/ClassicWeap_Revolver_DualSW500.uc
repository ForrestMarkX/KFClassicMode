class ClassicWeap_Revolver_DualSW500 extends KFWeap_Revolver_DualSW500;

defaultproperties
{
	SingleClass=class'ClassicWeap_Revolver_SW500'
	
	// Ammo
	MagazineCapacity[0]=12
	SpareAmmoCapacity[0]=244
	InitialSpareMags[0]=5

	// Recoil
	RecoilRate=0.07

	// DEFAULT_FIREMODE
	FireInterval(DEFAULT_FIREMODE)=+0.075
	InstantHitDamage(DEFAULT_FIREMODE)=105.0
	Spread(DEFAULT_FIREMODE)=0.009

	// ALTFIRE_FIREMODE
	FireInterval(ALTFIRE_FIREMODE)=+0.075
	InstantHitDamage(ALTFIRE_FIREMODE)=105.0
	Spread(ALTFIRE_FIREMODE)=0.009
	
	// Inventory
	GroupPriority=120
	
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

	Begin Object Class=KFSkeletalMeshComponent Name=BulletMeshComp5_L
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
	Components.Add(BulletMeshComp5_L)
	BulletMeshComponents.Add(BulletMeshComp5_L)
	
	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'
}

