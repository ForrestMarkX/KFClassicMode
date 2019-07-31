class ClassicWeap_SMG_Kriss extends KFWeap_MedicBase;

simulated function name GetWeaponFireAnim(byte FireModeNum)
{
    return Super(KFWeapon).GetWeaponFireAnim(FireModeNum);
}

static simulated event EFilterTypeUI GetTraderFilter()
{
    return FT_SMG;
}

defaultproperties
{
    // Healing charge
    HealAmount=15
    HealFullRechargeSeconds=18
    
    // Inventory
    InventorySize=3
    GroupPriority=120
    WeaponSelectTexture=Texture2D'WEP_UI_KRISS_TEX.UI_WeaponSelect_KRISS'

    // FOV
    MeshFOV=86
    MeshIronSightFOV=45
    PlayerIronSightFOV=75

    // Zooming/Position
    IronSightPosition=(X=15.f,Y=0.f,Z=0.0f)
    PlayerViewOffset=(X=20.f,Y=9.5f,Z=-3.0f)

    // Content
    PackageKey="Kriss"
    FirstPersonMeshName="wep_1p_kriss_mesh.Wep_1stP_KRISS_Rig"
    FirstPersonAnimSetNames(0)="wep_1p_kriss_anim.wep_1p_kriss_anim"
    PickupMeshName="wep_3p_kriss_mesh.Wep_KRISS_Pickup"
    AttachmentArchetypeName="KFClassicMode_Assets.Kriss.Wep_KRISS_3P"
    MuzzleFlashTemplateName="wep_kriss_arch.Wep_KRISS_MuzzleFlash"

    // Ammo
    MagazineCapacity[0]=25
    SpareAmmoCapacity[0]=325
    InitialSpareMags[0]=6
    bCanBeReloaded=true
    bReloadFromMagazine=true

    // Recoil
    maxRecoilPitch=50
    minRecoilPitch=40
    maxRecoilYaw=80
    minRecoilYaw=-80
    RecoilRate=0.06
    RecoilMaxYawLimit=500
    RecoilMinYawLimit=65035
    RecoilMaxPitchLimit=900
    RecoilMinPitchLimit=65035
    RecoilISMaxYawLimit=100
    RecoilISMinYawLimit=65435
    RecoilISMaxPitchLimit=375
    RecoilISMinPitchLimit=65460
    IronSightMeshFOVCompensationScale=1.85
    WalkingRecoilModifier=1.1
    JoggingRecoilModifier=1.2

    // DEFAULT_FIREMODE
    FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
    FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
    WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
    WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
    InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Kriss'
    FireInterval(DEFAULT_FIREMODE)=+.063 // 1200 RPM
    Spread(DEFAULT_FIREMODE)=0.015
    InstantHitDamage(DEFAULT_FIREMODE)=35.0 //33
    FireOffset=(X=30,Y=4.5,Z=-5)

    // ALTFIRE_FIREMODE
    AmmoCost(ALTFIRE_FIREMODE)=20

    // BASH_FIREMODE
    InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Kriss'
    InstantHitDamage(BASH_FIREMODE)=26
    
    //@todo: add akevents when we have them
    WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_KRISS.Play_KRISS_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_KRISS.Play_KRISS_Fire_1P_Loop')
    WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_KRISS.Play_KRISS_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_KRISS.Play_KRISS_Fire_1P_Single')
    WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'
    WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_DryFire'
    
    // Advanced (High RPM) Fire Effects
    bLoopingFireAnim(DEFAULT_FIREMODE)=true
    bLoopingFireSnd(DEFAULT_FIREMODE)=true
    WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_KRISS.Play_KRISS_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_KRISS.Play_KRISS_Fire_1P_EndLoop')
    SingleFireSoundIndex=ALTFIRE_FIREMODE

    // Attachments
    bHasIronSights=true
    bHasFlashlight=true

    AssociatedPerkClasses(0)=class'KFPerk_FieldMedic'
}
