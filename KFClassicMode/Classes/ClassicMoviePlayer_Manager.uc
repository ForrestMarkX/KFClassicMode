class ClassicMoviePlayer_Manager extends KFGFxMoviePlayer_Manager;

var ClassicMenu_Gear EGearMenu;

function ClientRecieveNewTeam()
{
    if(bMenusOpen)
    {
        if(CurrentMenu != None && CurrentMenu == GearMenu)
        {
            OpenMenu(UI_Start);
        }
        UpdateMenuBar();
    }
}

function bool ToggleMenus()
{
    if (!bMenusOpen || HUD.bShowHUD)
    {
        ManagerObject.SetBool("bOpenedInGame",true);
        if (CurrentMenuIndex >= MenuSWFPaths.length)
        {
            LaunchMenus();
        }

        // set the timer to mark when the menu is completely open and we can close the menu down
        bCanCloseMenu = false;
        `TimerHelper.SetTimer( 0.5, false, nameof(AllowCloseMenu), self );
        `TimerHelper.SetTimer( 0.15, false, nameof(PlayOpeningSound), self );//Delay due to pause
    }
    else if(bCanCloseMenu) //check to make sure
    {
        if(GetPC().WorldInfo.GRI.bMatchIsOver && !bAfterLobby)
        {
            return false; // we are still in the lobby and the game has not proceeded to a point where we can use the esc key
        }

        if (CurrentMenu != TraderMenu)
        {
            PlaySoundFromTheme('MAINMENU_CLOSE', 'UI');
        }

        CloseMenus();
    }

    return false;
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local bool Ret;
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
    default:
        Ret = Super.WidgetInitialized(WidgetName, WidgetPath, Widget);
        
        if( KFGFxWidget_PartyInGame_Versus(PartyWidget) != None )
        {
            KFGFxWidget_PartyInGame_Versus(PartyWidget).SwitchTeamsButton.SetVisible(false);
        }
        
        return Ret;
    }
}

function OneSecondLoop()
{
    HideFlashButtons();
    Super.OneSecondLoop();
    HideFlashButtons();
}

function HideFlashButtons()
{
    local ASDisplayInfo DI;
    local KFGFxWidget_PartyInGame_Versus PartyMenu;
    
    PartyMenu = KFGFxWidget_PartyInGame_Versus(PartyWidget);
    if( PartyMenu != None )
    {
        if( PartyMenu.SwitchTeamsButton != None )
        {
            DI = PartyMenu.SwitchTeamsButton.GetDisplayInfo();
            DI.Visible = false;
            PartyMenu.SwitchTeamsButton.SetDisplayInfo(DI);
        }
    }
    
    if( StartMenu != None && StartMenu.MissionObjectiveContainer != None )
    {
        if( StartMenu.MissionObjectiveContainer != None )
        {
            DI = StartMenu.MissionObjectiveContainer.GetDisplayInfo();
            DI.Visible = false;
            StartMenu.MissionObjectiveContainer.SetDisplayInfo(DI);
        }
    }
}

function UpdateBackgroundMovie()
{
    local bool bWasPlaying;
    local TextureMovie NewBackgroundMovie;
    if(CurrentBackgroundMovie != None)
    {
        bWasPlaying = !CurrentBackgroundMovie.Stopped;
    }

    NewBackgroundMovie = GetBackgroundMovie();
    if(bWasPlaying)
    {
        //Stop the old one if we're no longer needing it
        if (CurrentBackgroundMovie != NewBackgroundMovie)
        {
            if (CurrentBackgroundMovie != None)
            {
                CurrentBackgroundMovie.Stop();
            }
        }
        NewBackgroundMovie.Play();
    }
    else
    {
        if(CurrentBackgroundMovie != None)
        {
            CurrentBackgroundMovie.Stop();
        }

        NewBackgroundMovie.Stop();
    }
    CurrentBackgroundMovie = NewBackgroundMovie;
    SetExternalTexture("background", CurrentBackgroundMovie, true);
    SetExternalTexture("IIS_BG", IISMovie, true);
}

function TextureMovie GetBackgroundMovie()
{
    return BackgroundMovies[0];
}

function OnClose()
{
    CloseMenus();
    if (CurrentBackgroundMovie != None && !CurrentBackgroundMovie.Stopped)
    {
        CurrentBackgroundMovie.Stop();
    }
}

function StatsInitialized()
{
    if( IISMenu != none )
    {
        IISMenu.bStatsRead = true;
    }

    bStatsInitialized = true;
}

function LaunchMenus( optional bool bForceSkipLobby )
{
    Super.LaunchMenus(true);
    
    CloseMenus(true);
    SetHUDVisiblity(false);
    SetMovieCanReceiveInput(false);
}

function PlaySoundFromTheme(name EventName, optional name SoundTheme)
{
    if( EventName == 'TraderTime_Countdown' )
        return;
        
    Super.PlaySoundFromTheme(EventName, SoundTheme);
}

function ConditionalPauseGame(bool bPause);

defaultproperties
{
    InGamePartyWidgetClass=class'ClassicWidget_PartyInGame'
    
    WidgetPaths.Remove("../UI_Widgets/PartyWidget_SWF.swf")
    WidgetPaths.Add("../UI_Widgets/VersusLobbyWidget_SWF.swf")
    
    WidgetBindings.Remove((WidgetName="startMenu",WidgetClass=class'KFGFxMenu_StartGame'))
    WidgetBindings.Add((WidgetName="startMenu",WidgetClass=class'ClassicMenu_StartGame'))
    
    WidgetBindings.Remove((WidgetName="PerksMenu",WidgetClass=class'KFGFxMenu_Perks'))
    WidgetBindings.Add((WidgetName="PerksMenu",WidgetClass=class'ClassicMenu_Perks'))
    
    WidgetBindings.Remove((WidgetName="gearMenu",WidgetClass=class'KFGFxMenu_Gear'))
    WidgetBindings.Add((WidgetName="gearMenu",WidgetClass=class'ClassicMenu_Gear'))    
    
    WidgetBindings.Remove((WidgetName="postGameMenu",WidgetClass=class'KFGFxMenu_PostGameReport'))
    WidgetBindings.Add((WidgetName="postGameMenu",WidgetClass=class'ClassicMenu_PostGameReport'))
    
    WidgetBindings.Remove((WidgetName="traderMenu",WidgetClass=class'KFGFxMenu_Trader'))
    WidgetBindings.Add((WidgetName="traderMenu",WidgetClass=class'ClassicMenu_Trader'))
    
    WidgetBindings.Remove((WidgetName="MenuBarWidget",WidgetClass=class'KFGFxWidget_MenuBar'))
    WidgetBindings.Add((WidgetName="MenuBarWidget",WidgetClass=class'KFGFxWidget_MenuBarVersus'))
}
