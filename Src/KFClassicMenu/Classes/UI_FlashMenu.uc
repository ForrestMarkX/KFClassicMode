class UI_FlashMenu extends UI_FlashLobby;

function DoClose()
{
    local ClassicPlayerController PC;
    
    Super.DoClose();
    
    Owner.bForceEngineCursor = false;
    
    PC = ClassicPlayerController(GetPlayer());
    PC.MyGFxManager.CloseMenus(true);
    PC.MyGFxManager.SetMovieCanReceiveInput(false);
    
    PC.OpenLobbyMenu();
}

defaultproperties
{
}