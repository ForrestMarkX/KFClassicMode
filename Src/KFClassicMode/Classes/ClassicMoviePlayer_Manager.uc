class ClassicMoviePlayer_Manager extends KFGFxMoviePlayer_Manager;

var ClassicMenu_Gear EGearMenu;

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local PlayerController PC;

    switch ( WidgetName )
    {
    case 'gearMenu':
        PC = GetPC();
        if( PC.PlayerReplicationInfo.bReadyToPlay && PC.WorldInfo.GRI.bMatchHasBegun )
            return true;
        if (EGearMenu == none)
        {
            EGearMenu = ClassicMenu_Gear(Widget);
            EGearMenu.InitializeMenu(self);
        }
        OnMenuOpen( WidgetPath, EGearMenu );
        return true;
    }
    
    return Super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

function StatsInitialized()
{
    bStatsInitialized = true;
}

function LaunchMenus( optional bool bForceSkipLobby )
{
    Super.LaunchMenus(true);
    
    CloseMenus(true);
    SetHUDVisiblity(false);
    SetMovieCanReceiveInput(false);
}

function ConditionalPauseGame(bool bPause);

defaultproperties
{
    WidgetBindings.Remove((WidgetName="gearMenu",WidgetClass=class'KFGFxMenu_Gear'))
    WidgetBindings.Add((WidgetName="gearMenu",WidgetClass=class'ClassicMenu_Gear'))    
}