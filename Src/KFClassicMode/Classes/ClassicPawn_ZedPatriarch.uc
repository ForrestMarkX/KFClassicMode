class ClassicPawn_ZedPatriarch extends KFPawn_ZedPatriarch implements(KFZEDInterface);

`include(ClassicMonster.uci);
`include(ClassicMonsterBoss.uci);

simulated event UpdateSpottedStatus()
{
    local bool bOldSpottedByLP;
    local KFPlayerController LocalPC;
    local KFPerk LocalPerk;
    local float DistanceSq, Range;

    if( WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }

    bOldSpottedByLP = bIsCloakingSpottedByLP;
    bIsCloakingSpottedByLP = false;

    LocalPC = KFPlayerController(GetALocalPlayerController());
    if( LocalPC != none )
    {
        LocalPerk = LocalPC.GetPerk();
    }

    if ( LocalPC != none && LocalPC.Pawn != None && LocalPC.Pawn.IsAliveAndWell() && LocalPerk != none &&
         LocalPerk.bCanSeeCloakedZeds && `TimeSince( LastRenderTime ) < 1.f )
    {
        DistanceSq = VSizeSq(LocalPC.Pawn.Location - Location);
        Range = LocalPerk.GetCloakDetectionRange();

        if ( DistanceSq < Square(Range) )
        {
            bIsCloakingSpottedByLP = true;
            CallOutCloaking();
        }
    }

    if ( !bIsCloakingSpottedByTeam )
    {
        if ( bIsCloakingSpottedByLP != bOldSpottedByLP )
        {
            UpdateGameplayMICParams();
        }
    }
}

simulated function CallOutCloaking( optional KFPlayerController CallOutController )
{
    if( WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }
    
    bIsCloakingSpottedByTeam = true;
    UpdateGameplayMICParams();
    SetTimer(2.f, false, nameof(CallOutCloakingExpired));
}

simulated function CallOutCloakingExpired()
{
    if( WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }
    
    bIsCloakingSpottedByTeam = false;
    UpdateGameplayMICParams();
}

simulated function SetFleeAndHealMode( bool bNewFleeAndHealStatus )
{
    Controller.bGodMode = bNewFleeAndHealStatus;
    SetCollision(!bNewFleeAndHealStatus);
    
    Super.SetFleeAndHealMode(bNewFleeAndHealStatus);
}

defaultproperties
{
    Begin Object Name=MeleeHelper_0
        BaseDamage=75.f
        MomentumTransfer=80000.f
    End Object
    
    Health=4000
    SprintSpeed=574.5f
    
    DifficultySettings=class'ClassicDifficulty_Patriarch'
    ControllerClass=class'ClassicAIController_ZedPatriarch'
    MissileProjectileClass=class'ClassicProj_Missile_Patriarch'
    PawnAnimInfo=KFPawnAnimInfo'KFClassicMode_Assets.ZEDs.Patriarch_AnimGroup'
    
    Begin Object Class=ClassicAfflictionManager Name=Afflictions_0
        FireFullyCharredDuration=2.5
        FireCharPercentThreshhold=0.25
    End Object
    AfflictionHandler=Afflictions_0
    
    Begin Object Name=SpecialMoveHandler_0
        SpecialMoveClasses(SM_MeleeAttack)=class'ClassicSM_MeleeAttack'
        SpecialMoveClasses(SM_StandAndShootAttack)=class'ClassicSM_Patriarch_MissileAttack'
        SpecialMoveClasses(SM_Stumble)=None
        SpecialMoveClasses(SM_Evade)=None
        SpecialMoveClasses(SM_Evade_Fear)=None
        SpecialMoveClasses(SM_Block)=None
        SpecialMoveClasses(SM_GrappleAttack)=None
        SpecialMoveClasses(SM_SonicAttack)=None
    End Object
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=head, Limb=BP_Head, GoreHealth=MaxInt, DmgScale=1.1, SkinID=1)
    
    DamageTypeModifiers.Empty
}