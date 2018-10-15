class ClassicPawn_ZedClot_Alpha extends KFPawn_ZedClot_Alpha implements(KFZEDInterface);

`include(ClassicMonster.uci);

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
    local KFCharacterInfoBase SeasonalArch;
    
    SeasonalArch = GetSeasonalCharacterArch();
    if( SeasonalArch == None )
        SeasonalArch = Info;
        
    Super.SetCharacterArch(SeasonalArch, bForce);
}

DefaultProperties
{
    DifficultySettings=class'ClassicDifficulty_ClotAlpha'
    
    Begin Object Class=KFSpecialMoveHandler Name=SpecialMoveHandler_1
        SpecialMoveClasses(SM_MeleeAttack)       =class'KFGame.KFSM_MeleeAttack'
        SpecialMoveClasses(SM_MeleeAttackDoor)   =class'KFSM_DoorMeleeAttack'
        SpecialMoveClasses(SM_GrappleAttack)     =class'KFGame.KFSM_GrappleCombined'
        SpecialMoveClasses(SM_DeathAnim)         =class'KFSM_DeathAnim'
        SpecialMoveClasses(SM_Stunned)           =class'KFSM_Stunned'
        SpecialMoveClasses(SM_Taunt)             =class'KFGame.KFSM_Zed_Taunt'
        SpecialMoveClasses(SM_WalkingTaunt)      =class'KFGame.KFSM_Zed_WalkingTaunt'
        SpecialMoveClasses(SM_BossTheatrics)     =class'KFGame.KFSM_Zed_Boss_Theatrics'
        SpecialMoveClasses(SM_Emerge)            =class'KFSM_Emerge'
        SpecialMoveClasses(SM_GorgeZedVictim)    =class'KFGameContent.KFSM_GorgeVictim'
    End Object
    SpecialMoveHandler=SpecialMoveHandler_1
    
    DefaultMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Clot_Alpha_Archetype'
    SummerMonsterArch=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Clot_Slasher_Archetype'
    WinterMonsterArch=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Clot_Alpha_Archetype'
    FallMonsterArch=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Clot_Alpha_Archetype'
    
    Health=130
    
    GroundSpeed=201.075f
    SprintSpeed=201.075f
    
    ElitePawnClass.Empty
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=25, DmgScale=1.1, SkinID=1)
}
