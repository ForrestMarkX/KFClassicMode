class ClassicPawn_ZedClot_Alpha extends KFPawn_ZedClot_Alpha implements(KFZEDInterface);

`define OVERRIDEMOVEMENTFUNC true
`include(ClassicMonster.uci);

simulated function ZeroMovementVariables();

DefaultProperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Clot_Alpha_Archetype'
    
    DifficultySettings=class'ClassicDifficulty_ClotAlpha'
    ControllerClass=class'ClassicAIController_ZedClot_Alpha'
    PawnAnimInfo=KFPawnAnimInfo'KFClassicMode_Assets.ZEDs.AlphaClot_AnimGroup'
    
    Begin Object Class=ClassicAfflictionManager Name=Afflictions_0
        FireFullyCharredDuration=2.5
        FireCharPercentThreshhold=0.25
    End Object
    AfflictionHandler=Afflictions_0
    
    Begin Object Name=SpecialMoveHandler_0
        SpecialMoveClasses(SM_MeleeAttack)=class'ClassicSM_MeleeAttack'
        SpecialMoveClasses(SM_GrappleAttack)=class'KFSM_Zed_ClotGrapple'
        SpecialMoveClasses(SM_Stumble)=None
        SpecialMoveClasses(SM_Evade)=None
        SpecialMoveClasses(SM_Evade_Fear)=None
        SpecialMoveClasses(SM_Block)=None
        SpecialMoveClasses(SM_Rally)=None
    End Object
    
    Health=130
    
    GroundSpeed=201.075f
    SprintSpeed=201.075f
    
    ElitePawnClass.Empty
    DamageTypeModifiers.Empty
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=25, DmgScale=1.1, SkinID=1)
}
