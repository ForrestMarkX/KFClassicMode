class MenuPlayerInput extends ClassicPlayerInput within MenuPlayerController;

function bool FilterButtonInput(int ControllerId, Name Key, EInputEvent Event, float AmountDepressed, bool bGamepad)
{
    if( !Outer.bPendingTravel )
        return Super.FilterButtonInput(ControllerId,Key, Event, AmountDepressed, bGamepad);
        
    if ( Event==IE_Pressed && (Key == 'Escape' || Key == 'XboxTypeS_Start') )
    {
        Outer.AbortConnection();
        return true;
    }
    return false;
}

defaultproperties
{
    OnReceivedNativeInputKey=FilterButtonInput
}