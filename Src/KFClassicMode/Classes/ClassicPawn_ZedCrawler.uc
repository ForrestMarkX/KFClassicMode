class ClassicPawn_ZedCrawler extends KFPawn_ZedCrawler implements(KFZEDInterface);

`include(ClassicMonster.uci);

defaultproperties
{
    bKnockdownWhenJumpedOn=false
    
    Begin Object Name=MeleeHelper_0
        BaseDamage=6.f
        MomentumTransfer=5000.f
    End Object
    
    PawnAnimInfo=KFPawnAnimInfo'KFClassicMode_Assets.ZEDs.Crawler_AnimGroup'
    DifficultySettings=class'ClassicDifficulty_Crawler'
    
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
    
    Health=70
    
    GroundSpeed=268.1f
    SprintSpeed=268.1f
    
    ElitePawnClass.Empty
    DamageTypeModifiers.Empty
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=25, DmgScale=1.1, SkinID=1)
}
