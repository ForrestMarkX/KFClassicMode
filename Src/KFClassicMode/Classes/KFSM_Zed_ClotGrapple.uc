class KFSM_Zed_ClotGrapple extends KFSM_GrappleCombined;

function PlayGrabAnim()
{
    GrabCheckTime = KFSkeletalMeshComponent(PawnOwner.Mesh).GetAnimInterruptTime(GrabStartAnimName);

    // On the server start a timer to check collision
    if ( PawnOwner.Role == ROLE_Authority )
    {
        if ( GrabCheckTime <= 0 )
        {
            `warn("Failed to play" @ GrabStartAnimName @ "on special move" @ Self @ "on Pawn" @ PawnOwner);
            PawnOwner.SetTimer(0.25f, FALSE, nameof(AbortSpecialMove), Self);
            return;
        }

        PawnOwner.SetTimer(GrabCheckTime, FALSE, nameof(CheckGrapple), Self);
    }

    PlaySpecialMoveAnim(GrabStartAnimName, EAS_UpperBody, 0.33f, 0.33f, 1.f);

    if ( bUseRootMotion )
    {
        EnableRootMotion();
    }
}

defaultproperties
{
    bDisableMovement=false
}