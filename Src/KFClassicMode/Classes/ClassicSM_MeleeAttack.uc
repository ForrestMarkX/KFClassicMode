class ClassicSM_MeleeAttack extends KFSM_MeleeAttack;

function UnpackSpecialMoveFlags()
{
    local byte AtkIndex, AtkVariant;

    AtkIndex = KFPOwner.SpecialMoveFlags & 15;
    AtkVariant = KFPOwner.SpecialMoveFlags >> 4;

    // setup next attack animation based on SpecialMoveFlags
    AnimName = KFPOwner.PawnAnimInfo.InitMeleeSpecialMove(self, AtkIndex, AtkVariant);
    
    if( !bUseRootMotion && KFPOwner.PawnAnimInfo.Attacks[AtkIndex].bPlayUpperBodyOnly )
        AnimStance = EAS_UpperBody;
    else AnimStance = EAS_FullBody;

    // for now all non-RootMotion are also interruptible
    bCanBeInterrupted = (bCanBeInterrupted || !bUseRootMotion);
    bDisableMovement = !KFZEDInterface(KFPOwner).AttackWhileMoving(AtkIndex, KFPOwner.PawnAnimInfo.GetStrikeFlags(AtkIndex));
}

function PlayAnimation()
{
    local float D, InterruptTime;
    
	if( AnimName == '' )
	{
		`warn( KFPOwner$" "$GetFuncName()$" "$self$" attempting special move attack but the AttackAnims array is empty!" );
		return;
	}

	if( bCanBeInterrupted )
	{
		InterruptTime = KFSkeletalMeshComponent(PawnOwner.Mesh).GetAnimInterruptTime(AnimName);
		PawnOwner.SetTimer(InterruptTime, false, nameof(InterruptCheckTimer), self);
	}

    D = PlaySpecialMoveAnim( AnimName, AnimStance, BlendInTime, BlendOutTime, KFPOwner.AttackSpeedModifier);
    if( KFZEDAIInterface(KFPOwner.Controller)!=None )
        KFZEDAIInterface(KFPOwner.Controller).SetMeleeFinishTime(KFPOwner.WorldInfo.TimeSeconds+D);
}

defaultproperties
{
	bUseHigherMeshSmoothingThreshold=false
    bDisableMovement=false
}