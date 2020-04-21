class ClassicPawn_ZedGorefast extends KFPawn_ZedGorefast implements(KFZEDInterface);

`include(ClassicMonster.uci);

DefaultProperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Gorefast_Archetype'
    
    Begin Object Name=MeleeHelper_0
        BaseDamage=15.f
        MomentumTransfer=5000.f
    End Object
    
    PawnAnimInfo=KFPawnAnimInfo'KFClassicMode_Assets.ZEDs.Gorefast_AnimGroup'
    DifficultySettings=class'ClassicDifficulty_Gorefast'
    
    Health=250.f
    
    GroundSpeed=229.8f
    SprintSpeed=430.875f
    
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
    
    ElitePawnClass.Empty
    DamageTypeModifiers.Empty
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=50, DmgScale=1.1, SkinID=1)
}
