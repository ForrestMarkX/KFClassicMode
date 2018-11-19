class ClassicPawn_ZedBloat extends KFPawn_ZedBloat implements(KFZEDInterface);

`include(ClassicMonster.uci);

simulated function PostBeginPlay()
{
    Super(KFPawn_Monster).PostBeginPlay();
}

function SpawnPukeMine( vector SpawnLocation, rotator SpawnRotation );
function SpawnPukeMinesOnDeath();

DefaultProperties
{
    DifficultySettings=class'ClassicDifficulty_Bloat'
    ControllerClass=class'ClassicAIController_ZedBloat'
    PawnAnimInfo=KFPawnAnimInfo'KFClassicMode_Assets.ZEDs.Bloat_AnimGroup'
    
    Begin Object Class=ClassicAfflictionManager Name=Afflictions_0
        FireFullyCharredDuration=2.5
        FireCharPercentThreshhold=0.25
    End Object
    AfflictionHandler=Afflictions_0
    
    Begin Object Name=SpecialMoveHandler_0
        SpecialMoveClasses(SM_MeleeAttack)=class'ClassicSM_MeleeAttack'
        SpecialMoveClasses(SM_Stumble)=None
        SpecialMoveClasses(SM_Evade)=None
        SpecialMoveClasses(SM_Evade_Fear)=None
        SpecialMoveClasses(SM_Block)=None
    End Object
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=75, DmgScale=1.1, SkinID=1)
    
    DamageTypeModifiers.Empty
    
    Begin Object Name=MeleeHelper_0
        MomentumTransfer=30000.f
    End Object

    HeadlessBleedOutTime=6.f
    
    GroundSpeed=143.625f
    SprintSpeed=143.625f    

    Health=525
}
