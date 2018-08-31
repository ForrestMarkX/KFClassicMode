class ClassicPawn_ZedHusk extends KFPawn_ZedHusk implements(KFZEDInterface);

`include(ClassicMonster.uci);

function PossessedBy( Controller C, bool bVehicleTransition )
{
	Super(KFPawn_Monster).PossessedBy( C, bVehicleTransition );
}

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
	local KFCharacterInfoBase SeasonalArch;
	local AnimTree ClassicAT;
	
	SeasonalArch = GetSeasonalCharacterArch();
	if( SeasonalArch == None )
		SeasonalArch = Info;
		
	ClassicAT = AnimTree(DynamicLoadObject("KFClassicMode_Assets.ZEDs.AT_Husk_Classic", class'AnimTree'));
	if( ClassicAT != None )
		SeasonalArch.AnimTreeTemplate = ClassicAT;
		
	Super.SetCharacterArch(SeasonalArch, bForce);
}

function ApplySpecialZoneHealthMod(float HealthMod)
{
	Super(KFPawn_Monster).ApplySpecialZoneHealthMod(HealthMod);
}

DefaultProperties
{
	DifficultySettings=class'ClassicDifficulty_Husk'
	
	Begin Object Class=KFSpecialMoveHandler Name=SpecialMoveHandler_1
		SpecialMoveClasses(SM_MeleeAttack)		 =class'KFGame.KFSM_MeleeAttack'
		SpecialMoveClasses(SM_MeleeAttackDoor)	 =class'KFSM_DoorMeleeAttack'
		SpecialMoveClasses(SM_GrappleAttack)     =class'KFGame.KFSM_GrappleCombined'
		SpecialMoveClasses(SM_DeathAnim)		 =class'KFSM_DeathAnim'
		SpecialMoveClasses(SM_Stunned)			 =class'KFSM_Stunned'
		SpecialMoveClasses(SM_Taunt)			 =class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_WalkingTaunt)		 =class'KFGame.KFSM_Zed_WalkingTaunt'
        SpecialMoveClasses(SM_BossTheatrics)	 =class'KFGame.KFSM_Zed_Boss_Theatrics'
		SpecialMoveClasses(SM_StandAndShootAttack)= class'KFSM_Husk_FireBallAttack'
	End Object
	SpecialMoveHandler=SpecialMoveHandler_1
	
	DefaultMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Husk_Archetype'
	SummerMonsterArch=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Husk_Archetype'
	XmasMonsterArch=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Husk_Archetype'
	
    Health=600.f
	
	HeadlessBleedOutTime=6.f
	
	GroundSpeed=220.225f
	SprintSpeed=220.225f
	
	HitZones.Empty
	HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=200, DmgScale=1.1, SkinID=1)
	
	ElitePawnClass.Empty
}
