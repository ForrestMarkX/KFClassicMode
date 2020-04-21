class ClassicPawn_ZedStalker extends KFPawn_ZedStalker implements(KFZEDInterface);

`define OVERRIDEHEADEXPLODEFUNC true
`include(ClassicMonster.uci);

simulated function PlayHeadAsplode()
{
	local KFGoreManager GoreManager;
	local name BoneName;
    
	if( bIsCloaking )
		SetCloaked(false);
	bCanCloak = false;
    
	if (IsAliveAndWell())
		return;

	if( HitZones[HZI_Head].bPlayedInjury )
		return;

	if ( (bTearOff || bPlayedDeath) && TimeOfDeath > 0 && `TimeSince(TimeOfDeath) > 0.75 )
		return;

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager != none && GoreManager.AllowHeadless() )
	{
		if( !bIsGoreMesh && !bDisableHeadless )
		{
			SwitchToGoreMesh();
		}
	}

	if( bIsGoreMesh && GoreManager != none )
	{
        BoneName = HitZones[HZI_Head].BoneName;
		GoreManager.CrushBone( self, BoneName );
        SoundGroupArch.PlayHeadPopSounds( self, mesh.GetBoneLocation(BoneName) );
		HitZones[HZI_Head].bPlayedInjury = true;
	}

	SpawnHeadShotEffect(KFPlayerReplicationInfo(HitFxInfo.DamagerPRI));
}

DefaultProperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Stalker_Archetype'
    
    DifficultySettings=class'ClassicDifficulty_Stalker'
    PawnAnimInfo=KFPawnAnimInfo'KFClassicMode_Assets.ZEDs.Stalker_AnimGroup'
    
    Begin Object Name=MeleeHelper_0
        MomentumTransfer=5000.f
    End Object
    
    Health=100
    
    GroundSpeed=287.25f
    SprintSpeed=287.25f
    
    Begin Object Class=ClassicAfflictionManager Name=Afflictions_0
        FireFullyCharredDuration=2.5
        FireCharPercentThreshhold=0.25
    End Object
    AfflictionHandler=Afflictions_0
    
    Begin Object Name=SpecialMoveHandler_0
        SpecialMoveClasses(SM_Stumble)=None
        SpecialMoveClasses(SM_Evade)=None
        SpecialMoveClasses(SM_Evade_Fear)=None
        SpecialMoveClasses(SM_Block)=None
    End Object
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=25, DmgScale=1.1, SkinID=1)
    
    ElitePawnClass.Empty
    DamageTypeModifiers.Empty
}
