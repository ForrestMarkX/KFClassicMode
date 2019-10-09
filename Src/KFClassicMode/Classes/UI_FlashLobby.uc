class UI_FlashLobby extends KFGUI_Page;

function ShowMenu()
{
    Super.ShowMenu();
    Owner.bForceEngineCursor = true;
    SetTimer(1.f, true, 'CheckFlashMenus');
}

function CheckFlashMenus()
{
    if( !KFPlayerController(GetPlayer()).MyGFxManager.bMenusActive )
        DoClose();
}

function ButtonClicked( KFGUI_Button Sender )
{
    DoClose();
}

function PreDraw()
{
    local KFGFxMoviePlayer_Manager MovieManager;
    
    Super.PreDraw();
    
    MovieManager = KFPlayerController(GetPlayer()).MyGFxManager;
    if( CaptureMouse() )
    {
        MovieManager.SetMovieCanReceiveInput(false);
    }
    else
    {
        MovieManager.SetMovieCanReceiveInput(true);
    }
}

function DoClose()
{
    local ClassicPlayerController PC;
    
    Super.DoClose();
    
    Owner.bForceEngineCursor = false;
    
    PC = ClassicPlayerController(GetPlayer());
    PC.MyGFxManager.CloseMenus(true);
    PC.MyGFxManager.SetMovieCanReceiveInput(false);
    
    if( !KFGameReplicationInfo(PC.WorldInfo.GRI).bMatchHasBegun )
    {
        PC.LobbyMenu.SetVisibility(true);
        PC.MyGFxManager.SetHUDVisiblity(false);
    }
    else
    {
        Owner.OpenMenu(PC.MidGameMenuClass);
        PC.MyGFxManager.SetHUDVisiblity(true);
    }
}

function bool ReceievedControllerInput(int ControllerId, name Key, EInputEvent Event)
{
    switch(Key)
    {
        case 'XboxTypeS_Start':
            if( Event == IE_Pressed )
                DoClose();
            return true;
    }
    
    return false;
}

defaultproperties
{
    bNoBackground=true
    
    XPosition=0.8
    YPosition=0.925
    XSize=0.156368
    YSize=0.06
    
    Begin Object Class=KFGUI_Button Name=CloseButton
        ButtonText="Close"
        Tooltip="Close the Flash UI"
        XPosition=0
        YPosition=0
        XSize=1
        YSize=1
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
    End Object
    Components.Add(CloseButton)
}