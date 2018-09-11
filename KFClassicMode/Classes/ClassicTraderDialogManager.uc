class ClassicTraderDialogManager extends KFTraderDialogManager;

simulated function PlayDialog( int EventID, Controller C, bool bInterrupt = false )
{
    local KFPawn_Human KFPH;

    if( WorldInfo.NetMode == NM_DedicatedServer )
        return;

    if (C == none)
        return;

    if( !C.IsLocalController() )
        return;

    if( !bEnabled || TraderVoiceGroupClass == none )
        return;

    if( EventID < 0 || EventID >= 274 )
        return;

    if( C.Pawn == none || !C.Pawn.IsAliveAndWell() )
        return;
        
    if( ActiveEventInfo.AudioCue != none && !bInterrupt )
        return;

    if( DialogIsCoolingDown(EventID) )
        return;

    if (!ShouldDialogPlay(EventID))
        return;

    KFPH = KFPawn_Human( C.Pawn );
    if( KFPH != none )
    {
        if (bInterrupt)
        {
            KFPH.StopTraderDialog();
        }

        ActiveEventInfo = TraderVoiceGroupClass.default.DialogEvents[ EventID ];
        KFPH.PlayTraderDialog( ActiveEventInfo.AudioCue );
        SetTimer( ActiveEventInfo.AudioCue.Duration, false, nameof(EndOfDialogTimer) );
    }
}

defaultproperties
{
}
