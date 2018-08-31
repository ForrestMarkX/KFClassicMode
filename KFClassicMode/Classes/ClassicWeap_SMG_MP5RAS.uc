class ClassicWeap_SMG_MP5RAS extends KFWeap_MedicBase;

simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	return Super(KFWeapon).GetWeaponFireAnim(FireModeNum);
}

function CheckTargetLock();

defaultproperties
{
	// Healing charge
    HealAmount=15
	HealFullRechargeSeconds=12
	
	// Inventory
	InventorySize=3
	GroupPriority=80
	WeaponSelectTexture=Texture2D'WEP_UI_MP5RAS_TEX.UI_WeaponSelect_MP5RAS'

	// FOV
	MeshFOV=86
	MeshIronSightFOV=50
	PlayerIronSightFOV=75

	// Zooming/Position
	IronSightPosition=(X=10.f,Y=0,Z=0)
	PlayerViewOffset=(X=17.f,Y=8,Z=-4.0)

	// Content
	PackageKey="MP5RAS"
	FirstPersonMeshName="wep_1p_mp5ras_mesh.Wep_1stP_MP5RAS_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_mp5ras_anim.wep_1p_mp5ras_anim"
	PickupMeshName="wep_3p_mp5ras_mesh.Wep_MP5RAS_Pickup"
	AttachmentArchetypeName="KFClassicMode_Assets.MP5.Wep_MP5RAS_3P"
	MuzzleFlashTemplateName="wep_mp5ras_arch.Wep_MP5RAS_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=40
	SpareAmmoCapacity[0]=360
	InitialSpareMags[0]=4
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=60
	minRecoilPitch=40
	maxRecoilYaw=50
	minRecoilYaw=-50
	RecoilRate=0.06
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=550 //900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=1.6
	WalkingRecoilModifier=1.1
	JoggingRecoilModifier=1.2

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_MP5RAS'
	FireInterval(DEFAULT_FIREMODE)=+.075 // 900 RPM
	Spread(DEFAULT_FIREMODE)=0.01
	InstantHitDamage(DEFAULT_FIREMODE)=25 //22
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALTFIRE_FIREMODE
	AmmoCost(ALTFIRE_FIREMODE)=35

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_MP5RAS'
	InstantHitDamage(BASH_FIREMODE)=24.0
	
	//@todo: add akevents when we have them
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MP5.Play_MP5_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_MP5.Play_MP5_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MP5.Play_MP5_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_MP5.Play_MP5_Fire_1P_Single')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MP5.Play_MP5_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_MP5.Play_MP5_Fire_1P_EndLoop')
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	AssociatedPerkClasses(0)=class'KFPerk_FieldMedic'
}
