class ClassicPawn_ZedScrake extends KFPawn_ZedScrake implements(KFZEDInterface);

`include(ClassicMonster.uci);

simulated event PostBeginPlay()
{
	local KFGameReplicationInfo KFGRI;
	
	Super(BaseAIPawn).PostBeginPlay();

	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		Mesh.bPauseAnims = true;
	}

	// Set our (Network: ALL) difficulty-based settings
	KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
	if( KFGRI != none )
	{
		SetRallySettings( DifficultySettings.static.GetRallySettings(self, KFGRI) );
		SetZedTimeSpeedScale( DifficultySettings.static.GetZedTimeSpeedScale(self, KFGRI) );
	}
	
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		ChainsawIdleAkComponent.PlayEvent( PlayChainsawIdleAkEvent, true, true );
		CreateExhaustFx();
	}
}

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
	local KFCharacterInfoBase SeasonalArch;
	
	SeasonalArch = GetSeasonalCharacterArch();
	if( SeasonalArch == None )
		SeasonalArch = Info;
		
	Super.SetCharacterArch(SeasonalArch, bForce);
}

defaultproperties
{
	DifficultySettings=class'ClassicDifficulty_Scrake'
	
	Begin Object Class=KFSpecialMoveHandler Name=SpecialMoveHandler_1
		SpecialMoveClasses(SM_MeleeAttack)		 =class'KFGame.KFSM_MeleeAttack'
		SpecialMoveClasses(SM_MeleeAttackDoor)	 =class'KFSM_DoorMeleeAttack'
		SpecialMoveClasses(SM_GrappleAttack)     =class'KFGame.KFSM_GrappleCombined'
		SpecialMoveClasses(SM_DeathAnim)		 =class'KFSM_DeathAnim'
		SpecialMoveClasses(SM_Stunned)			 =class'KFSM_Stunned'
		SpecialMoveClasses(SM_Taunt)			 =class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_WalkingTaunt)		 =class'KFGame.KFSM_Zed_WalkingTaunt'
        SpecialMoveClasses(SM_BossTheatrics)	 =class'KFGame.KFSM_Zed_Boss_Theatrics'
	End Object
	SpecialMoveHandler=SpecialMoveHandler_1
	
	DefaultMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Scrake_Archetype'
	SummerMonsterArch=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Scrake_Archetype'
	XmasMonsterArch=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Scrake_Archetype'
	
    Health=1000
	
	GroundSpeed=162.775f
	SprintSpeed=569.7125f
	
	HeadlessBleedOutTime=6.f
	
	RageHealthThresholdNormal=0.5
    RageHealthThresholdHard=0.5
    RageHealthThresholdSuicidal=0.5
    RageHealthThresholdHellOnEarth=0.75
	
	HitZones.Empty=Head, Limb=BP_Head,
	HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=650, DmgScale=1.1, SkinID=1)
	
	Begin Object Name=MeleeHelper_0
		BaseDamage=20.f
		MomentumTransfer=-45000.f
	End Object
}
