class ClassicPawn_ZedSiren extends KFPawn_ZedSiren implements(KFZEDInterface);

`include(ClassicMonster.uci);

defaultproperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Siren_Archetype'
    
    DifficultySettings=class'ClassicDifficulty_Siren'
    
    Health=300
    
    GroundSpeed=191.5f
    SprintSpeed=191.5f
    
    Begin Object Class=ClassicAfflictionManager Name=Afflictions_0
        FireFullyCharredDuration=2.5
        FireCharPercentThreshhold=0.25
    End Object
    AfflictionHandler=Afflictions_0
    
    Begin Object Name=SpecialMoveHandler_0
        SpecialMoveClasses(SM_SonicAttack)=class'ClassicSM_Siren_Scream'
        SpecialMoveClasses(SM_Stumble)=None
        SpecialMoveClasses(SM_Evade)=None
        SpecialMoveClasses(SM_Evade_Fear)=None
        SpecialMoveClasses(SM_Block)=None
    End Object
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=200, DmgScale=1.1, SkinID=1)
    
    DamageTypeModifiers.Empty
}
