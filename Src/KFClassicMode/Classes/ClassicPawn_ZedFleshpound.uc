class ClassicPawn_ZedFleshpound extends KFPawn_ZedFleshpound implements(KFZEDInterface);

`define OVERRIDECHARACTERARCHFUNC true
`include(ClassicMonster.uci);

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
    local KFCharacterInfoBase CharacterInfo;
    
    CharacterInfo = class'ClassicZEDHelper'.static.GetCharacterArch(self, Info);
    CharacterInfo.AnimSets.AddItem(AnimSet'ZED_Fleshpound_ANIM.Mini_Anim_Master');
    
    Super.SetCharacterArch(CharacterInfo, bForce);
    
    if( SoundGroupArch.EntranceSound != None )
        SoundGroupArch.EntranceSound = None;
}

DefaultProperties
{
    PawnAnimInfo=KFPawnAnimInfo'KFClassicMode_Assets.ZEDs.Fleshpound_AnimGroup'
    ControllerClass=class'ClassicAIController_ZedFleshpound'
    DifficultySettings=class'ClassicDifficulty_Fleshpound'
    
    Begin Object Name=MeleeHelper_0
        MomentumTransfer=15000.f
    End Object
    
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
    
    HeadlessBleedOutTime=7.f
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=700, DmgScale=1.1, SkinID=1)
}