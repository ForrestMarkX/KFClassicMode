class ClassicPawn_ZedPatriarch extends KFPawn_ZedPatriarch implements(KFZEDInterface);

`include(ClassicMonster.uci);

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
    local KFCharacterInfoBase SeasonalArch;
    
    SeasonalArch = GetSeasonalCharacterArch();
    if( SeasonalArch == None )
        SeasonalArch = Info;
        
    Super.SetCharacterArch(SeasonalArch, bForce);
}

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
    
    GroundSpeed=229.8f
    SprintSpeed=574.5f
    
    DifficultySettings=class'ClassicDifficulty_Patriarch'
    MissileProjectileClass=class'ClassicProj_Missile_Patriarch'
    
    Begin Object Class=KFSpecialMoveHandler Name=SpecialMoveHandler_1
        SpecialMoveClasses(SM_MeleeAttack)         =class'KFGame.KFSM_MeleeAttack'
        SpecialMoveClasses(SM_MeleeAttackDoor)     =class'KFSM_DoorMeleeAttack'
        SpecialMoveClasses(SM_GrappleAttack)     =class'KFSM_Patriarch_Grapple'
        SpecialMoveClasses(SM_DeathAnim)         =class'KFSM_DeathAnim'
        SpecialMoveClasses(SM_Stunned)             =class'KFSM_Stunned'
        SpecialMoveClasses(SM_Taunt)             =class'KFSM_Patriarch_Taunt'
        SpecialMoveClasses(SM_WalkingTaunt)         =class'KFGame.KFSM_Zed_WalkingTaunt'
        SpecialMoveClasses(SM_BossTheatrics)     =class'KFGame.KFSM_Zed_Boss_Theatrics'
        SpecialMoveClasses(SM_Heal)                 =class'KFSM_Patriarch_Heal'
        SpecialMoveClasses(SM_HoseWeaponAttack)  =class'KFSM_Patriarch_MinigunBarrage'
        SpecialMoveClasses(SM_StandAndShootAttack)=class'ClassicSM_Patriarch_MissileAttack'
    End Object
    SpecialMoveHandler=SpecialMoveHandler_1
    
    DefaultMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Patriarch_Archetype'
    SummerMonsterArch=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Patriarch_Archetype'
    WinterMonsterArch=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Patriarch_Archetype'
    FallMonsterArch=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Patriarch_Archetype'
    
    HitZones.Empty
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=head, Limb=BP_Head, GoreHealth=MaxInt, DmgScale=1.1, SkinID=1)
}