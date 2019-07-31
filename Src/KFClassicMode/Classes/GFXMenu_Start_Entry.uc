class GFXMenu_Start_Entry extends KFGFxMenu_StartGame;

function OnOpen()
{
    Manager.CloseMenus(true);
    Manager.SetHUDVisiblity(false);
    Manager.SetMovieCanReceiveInput(false);
}

defaultproperties
{
}



