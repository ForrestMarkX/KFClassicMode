class AICommand_Attack_GrabClassic extends AICommand_Attack_Grab;

function ClearTimeout()
{
    Super.ClearTimeout();
    ClearTimer('GrabFinished',Self);
}

function GrabFinished()
{
    Status = 'Success';
    PopCommand( self );
}

state Command_SpecialMove
{
    function bool ExecuteSpecialMove()
    {
        if( !Super.ExecuteSpecialMove() )
            return false;
            
        if( KFZEDAIInterface(Outer) != None )
            SetTimer(FMax(WorldInfo.TimeSeconds-KFZEDAIInterface(Outer).GetGrabFinishTime(),0.01),false,'GrabFinished',Self);
            
        return true;
    }

Begin:
    if( bWaitForLanding && MyKFPawn.Physics == PHYS_Falling )
        WaitForLanding();

    if( bUseDesiredRotationForMelee && !Pawn.ReachedDesiredRotation() )
        FinishRotation();

    /** Try to start the special move */
    if( ExecuteSpecialMove() )
    {
        /** Handle optional timeout in case the special move takes too long, gets stuck, etc. */
        SetTimer( TimeOutDelaySeconds, false, 'SpecialMoveTimeOut', self );
        if( KFZEDAIInterface(Outer) != None && KFZEDAIInterface(Outer).GetKeepMoving() )
        {
            while( AttackTarget!=None )
            {
                MoveToward(AttackTarget);
            }
        }
        AbortMovementCommands();
        MoveTimer = -1;
        Pawn.Acceleration = vect(0,0,0);
        Stop;
    }
    else
    {
Abort:
        Status = 'Failure';
        /** Handle optional delay after failure, won't execute more state code until delay is finished */
        Sleep( FailureSleepTimeSeconds );
    }

    /** Exit the command */
    PopCommand( self );
}

DefaultProperties
{
}