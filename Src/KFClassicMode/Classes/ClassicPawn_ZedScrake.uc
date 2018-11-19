class ClassicPawn_ZedScrake extends KFPawn_ZedScrake implements(KFZEDInterface);

`include(ClassicMonster.uci);

defaultproperties
{
    DifficultySettings=class'ClassicDifficulty_Scrake'
    ControllerClass=class'ClassicAIController_ZedScrake'
    PawnAnimInfo=KFPawnAnimInfo'KFClassicMode_Assets.ZEDs.Scrake_AnimGroup'
    
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
    
    DamageTypeModifiers.Empty
}
