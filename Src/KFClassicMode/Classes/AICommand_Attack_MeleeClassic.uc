class AICommand_Attack_MeleeClassic extends AICommand_Attack_Melee;

function ClearTimeout()
{
    Super.ClearTimeout();
    ClearTimer('MeleeFinished',Self);
}

function MeleeFinished()
{
    KFPawn_Monster(Pawn).StopLookingAtPawn();
    
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
            SetTimer(FMax(WorldInfo.TimeSeconds-KFZEDAIInterface(Outer).GetMeleeFinishTime(),0.01),false,'MeleeFinished',Self);
            
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
                if( KFPawn(AttackTarget) != None )
                    KFPawn_Monster(Pawn).LookAtPawn(KFPawn(AttackTarget));
                    
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