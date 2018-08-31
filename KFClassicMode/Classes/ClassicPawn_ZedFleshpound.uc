class ClassicPawn_ZedFleshpound extends KFPawn_ZedFleshpound implements(KFZEDInterface);

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
}

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
	local KFCharacterInfoBase SeasonalArch;
	
	SeasonalArch = GetSeasonalCharacterArch();
	if( SeasonalArch == None )
		SeasonalArch = Info;
		
	SeasonalArch.AnimSets.AddItem(AnimSet'ZED_Fleshpound_ANIM.Mini_Anim_Master');
		
	Super.SetCharacterArch(SeasonalArch, bForce);
}

DefaultProperties
{
	ControllerClass=class'ClassicAIController_ZedFleshpound'
	DifficultySettings=class'ClassicDifficulty_Fleshpound'
	
	Begin Object Name=MeleeHelper_0
	    MomentumTransfer=15000.f
	End Object
	
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
	
	DefaultMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Fleshpound_Archetype'
	SummerMonsterArch=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Fleshpound_Archetype'
	XmasMonsterArch=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Fleshpound_Archetype'
	
	HeadlessBleedOutTime=7.f
	
	GroundSpeed=248.95f
	SprintSpeed=572.585f
	
	HitZones.Empty
	HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=700, DmgScale=1.1, SkinID=1)
}