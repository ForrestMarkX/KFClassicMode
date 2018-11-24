Class UI_MidGameMenu extends KFGUI_FloatingWindow;

struct FPageInfo
{
    var class<KFGUI_Base> PageClass;
    var string Caption,Hint;
};
var KFGUI_SwitchMenuBar PageSwitcher;
var() array<FPageInfo> Pages;

var KFGUI_Button SkipTraderButton,SpectateButton,SuicideButton,SettingsButton,MapvoteButton,GearButton;

var transient KFGUI_Button PrevButton;
var transient int NumButtons,NumButtonRows;
var transient bool bInitSpectate,bOldSpectate;

var KFPlayerReplicationInfo KFPRI;

function InitMenu()
{
    local int i;
    local KFGUI_Button B;

    PageSwitcher = KFGUI_SwitchMenuBar(FindComponentID('Pager'));
    Super(KFGUI_Page).InitMenu();
    
    SettingsButton = AddMenuButton('Settings',"Settings","Enter the game settings");
    MapvoteButton = AddMenuButton('Mapvote',"Map Voting","Show mapvote menu");
    SkipTraderButton = AddMenuButton('SkipTrader',"Skip Trader","Vote to skip the trader");
    //GearButton = AddMenuButton('Gear',"Gear","");
    SpectateButton = AddMenuButton('Spectate',"","");
    SuicideButton = AddMenuButton('Suicide', "Suicide", "Causes you to have a sudden heart attack");
    AddMenuButton('Profile',"Profile","Show your Steam Profile");
    AddMenuButton('Disconnect',"Disconnect","Disconnect from this server");
    AddMenuButton('Close',"Close","Close this menu");
    
    for( i=0; i<Pages.Length; ++i )
    {
        PageSwitcher.AddPage(Pages[i].PageClass,Pages[i].Caption,Pages[i].Hint,B).InitMenu();
    }
}

function Timer()
{
    local PlayerReplicationInfo PRI;
    
    PRI = GetPlayer().PlayerReplicationInfo;
    if( PRI==None )
        return;
        
    if( KFPlayerController(GetPlayer()).IsBossCameraMode() )
    {
        DoClose();
        return;
    }

    if( !bInitSpectate || bOldSpectate!=PRI.bOnlySpectator )
    {
        bInitSpectate = true;
        bOldSpectate = PRI.bOnlySpectator;
        SpectateButton.ButtonText = (bOldSpectate ? "Join" : "Spectate");
        SpectateButton.ChangeToolTip(bOldSpectate ? "Click to become an active player" : "Click to become a spectator");
    }
}

function ShowMenu()
{
    Super.ShowMenu();

    if( GetPlayer().WorldInfo.GRI!=None )
        WindowTitle = GetPlayer().WorldInfo.GRI.ServerName;
        
    if( GetPlayer().Pawn==None || !GetPlayer().Pawn.IsAliveAndWell() )
    {
        SuicideButton.SetDisabled( true );
        SkipTraderButton.SetDisabled( true );
        MapvoteButton.SetDisabled( true );
        SpectateButton.SetDisabled( true );
        
        //GearButton.SetDisabled( ClassicPlayerController(GetPlayer()).LobbyMenu != None );
    }
    else
    {
        SuicideButton.SetDisabled( false );
        SkipTraderButton.SetDisabled( false );
        MapvoteButton.SetDisabled( false );
        SpectateButton.SetDisabled( false );
        
        //GearButton.SetDisabled( true );
    }
    
    //GearButton.SetDisabled( true );
    SettingsButton.SetDisabled( ClassicPlayerController(GetPlayer()).LobbyMenu != None );
        
    PlayMenuSound(MN_DropdownChange);
    
    // Update spectate button info text.
    Timer();
    SetTimer(0.5,true);
}

function ButtonClicked( KFGUI_Button Sender )
{
    local KFGUI_Page T;
    local KFGameReplicationInfo KFGRI;
    local KFPlayerReplicationInfo PRI;
    
    switch( Sender.ID )
    {
    case 'Gear':
    case 'Settings':
        Owner.OpenMenu(ClassicPlayerController(GetPlayer()).FlashUIClass);
        KFPlayerController(GetPlayer()).MyGFxManager.OpenMenu(Sender.ID == 'Settings' ? UI_OptionsSelection : UI_Gear);
        break;
    case 'Mapvote':
        OpenUpMapvote();
        break;
    case 'SkipTrader':
        PRI = KFPlayerReplicationInfo(KFPlayerController(GetPlayer()).PlayerReplicationInfo);
        KFGRI = KFGameReplicationInfo(GetPlayer().WorldInfo.GRI);
        if (KFGRI != None)
        {
            if (KFGRI.bMatchHasBegun)
            {
                if (KFGRI.bTraderIsOpen && PRI.bHasSpawnedIn)
                {
                    PRI.RequestSkiptTrader(PRI);
                }
            }
        }
        
        break;
    case 'Spectate':
        ClassicPlayerController(GetPlayer()).ChangeSpectateMode(!bOldSpectate);
        break;
    case 'Suicide':
        GetPlayer().ConsoleCommand("Suicide");
        break;
    case 'Profile':
        OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem()).ShowProfileUI(0,,KFPRI.UniqueId);
        break;
    case 'Disconnect':
        T = Owner.OpenMenu(class'UI_NotifyDisconnect');
        UI_NotifyDisconnect(T).MessageTo();
        break;
    }
    
    DoClose();
}

final function OpenUpMapvote()
{
    local xVotingReplication R;
    
    foreach GetPlayer().DynamicActors(class'KFClassicMode.xVotingReplication',R)
        R.ClientOpenMapvote();
}

final function KFGUI_Button AddMenuButton( name ButtonID, string Text, optional string ToolTipStr )
{
    local KFGUI_Button B;
    
    B = new (Self) class'KFGUI_Button';
    B.ButtonText = Text;
    B.ToolTip = ToolTipStr;
    B.OnClickLeft = ButtonClicked;
    B.OnClickRight = ButtonClicked;
    B.ID = ButtonID;
    B.XPosition = 0.05+NumButtons*0.1;
    B.XSize = 0.099;
    B.YPosition = 0.92+NumButtonRows*0.04;
    B.YSize = 0.0399;

    PrevButton = B;
    if( ++NumButtons>8 )
    {
        ++NumButtonRows;
        NumButtons = 0;
    }
    
    AddComponent(B);
    return B;
}

defaultproperties
{
    WindowTitle="Killing Floor 2 - Classic Mode"
    XPosition=0.2
    YPosition=0.1
    XSize=0.6
    YSize=0.8
    
    bAlwaysTop=true
    bOnlyThisFocus=true
    
    Pages.Add((PageClass=Class'UIP_PerkSelection',Caption="Perks",Hint="Select your perk"))
    Pages.Add((PageClass=Class'UIP_Settings',Caption="Settings",Hint="Show additional Classic Mode settings"))
    Pages.Add((PageClass=Class'UIP_ColorSettings',Caption="Colors",Hint="Settings to adjust the hud colors"))

    Begin Object Class=KFGUI_SwitchMenuBar Name=MultiPager
        ID="Pager"
        XPosition=0.015
        YPosition=0.04
        XSize=0.975
        YSize=0.8
        BorderWidth=0.05
        ButtonAxisSize=0.08
    End Object
    
    Components.Add(MultiPager)
}