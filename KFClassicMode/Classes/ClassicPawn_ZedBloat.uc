class ClassicPawn_ZedBloat extends KFPawn_ZedBloat implements(KFZEDInterface);

`include(ClassicMonster.uci);

simulated function PostBeginPlay()
{
    Super(KFPawn_Monster).PostBeginPlay();
}

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
    local KFCharacterInfoBase SeasonalArch;
    
    SeasonalArch = GetSeasonalCharacterArch();
    if( SeasonalArch == None )
        SeasonalArch = Info;
        
    Super.SetCharacterArch(SeasonalArch, bForce);
}

function SpawnPukeMine( vector SpawnLocation, rotator SpawnRotation );
function SpawnPukeMinesOnDeath();

DefaultProperties
{
    DifficultySettings=class'ClassicDifficulty_Bloat'
    
    Begin Object Class=KFSpecialMoveHandler Name=SpecialMoveHandler_1
        SpecialMoveClasses(SM_MeleeAttack)       =class'KFGame.KFSM_MeleeAttack'
        SpecialMoveClasses(SM_MeleeAttackDoor)   =class'KFSM_DoorMeleeAttack'
        SpecialMoveClasses(SM_GrappleAttack)     =class'KFGame.KFSM_GrappleCombined'
        SpecialMoveClasses(SM_DeathAnim)         =class'KFSM_DeathAnim'
        SpecialMoveClasses(SM_Stunned)           =class'KFSM_Stunned'
        SpecialMoveClasses(SM_Taunt)             =class'KFGame.KFSM_Zed_Taunt'
        SpecialMoveClasses(SM_WalkingTaunt)      =class'KFGame.KFSM_Zed_WalkingTaunt'
        SpecialMoveClasses(SM_BossTheatrics)     =class'KFGame.KFSM_Zed_Boss_Theatrics'
    End Object
    SpecialMoveHandler=SpecialMoveHandler_1
    
    DefaultMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Bloat_Archetype'
    SummerMonsterArch=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Bloat_Archetype'
    WinterMonsterArch=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Bloat_Archetype'
    FallMonsterArch=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Bloat_Archetype'
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=75, DmgScale=1.1, SkinID=1)
    
    Begin Object Name=MeleeHelper_0
        MomentumTransfer=30000.f
    End Object

    HeadlessBleedOutTime=6.f
    
    GroundSpeed=143.625f
    SprintSpeed=143.625f    

    Health=525
}
