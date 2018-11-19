class ClassicPawn_ZedHusk extends KFPawn_ZedHusk implements(KFZEDInterface);

var AnimTree AnimTreeReplacment;

`define OVERRIDECHARACTERARCHFUNC true
`include(ClassicMonster.uci);

function PossessedBy( Controller C, bool bVehicleTransition )
{
    Super(KFPawn_Monster).PossessedBy( C, bVehicleTransition );
}

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
    local KFCharacterInfoBase CharacterInfo;
    
    CharacterInfo = class'ClassicZEDHelper'.static.GetCharacterArch(self, Info);
    if( AnimTreeReplacment != None )
        CharacterInfo.AnimTreeTemplate = AnimTreeReplacment;
    
    Super.SetCharacterArch(CharacterInfo, bForce);
    
    if( SoundGroupArch.EntranceSound != None )
        SoundGroupArch.EntranceSound = None;
}

function ApplySpecialZoneHealthMod(float HealthMod)
{
    Super(KFPawn_Monster).ApplySpecialZoneHealthMod(HealthMod);
}

DefaultProperties
{
    DifficultySettings=class'ClassicDifficulty_Husk'
    AnimTreeReplacment=AnimTree'KFClassicMode_Assets.ZEDs.AT_Husk_Classic'
    
    Begin Object Class=ClassicAfflictionManager Name=Afflictions_0
        FireFullyCharredDuration=2.5
        FireCharPercentThreshhold=0.25
    End Object
    AfflictionHandler=Afflictions_0
    
    Begin Object Name=SpecialMoveHandler_0
        SpecialMoveClasses(SM_StandAndShootAttack)=class'ClassicSM_Husk_FireBallAttack'
        SpecialMoveClasses(SM_Stumble)=None
        SpecialMoveClasses(SM_Evade)=None
        SpecialMoveClasses(SM_Evade_Fear)=None
        SpecialMoveClasses(SM_Block)=None
        SpecialMoveClasses(SM_HoseWeaponAttack)=None
        SpecialMoveClasses(SM_Suicide)=None
    End Object
    
    Health=600.f
    
    HeadlessBleedOutTime=6.f
    
    GroundSpeed=220.225f
    SprintSpeed=220.225f
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=200, DmgScale=1.1, SkinID=1)
    
    ElitePawnClass.Empty
    
    DamageTypeModifiers.Empty
    DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', DamageScale=(0.5)))
}
