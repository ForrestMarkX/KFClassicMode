Class MenuPlayerController extends ClassicPlayerController;

var class<KFGUI_Page> MainMenuClass, ServerBrowserClass, StartMenuClass, SettingsMenuClass;
var UI_MainMenu MainMenu;

var transient bool bPendingTravel, bDelayedTravel;
var transient MS_PendingData TravelData;
var byte ConnectionCounter;
var bool bConnectionFailed;
var transient string TransitionMap, TransitionGame, PendingURL;
var int MessageCount;
var UIR_Popup PopupMenu;

struct FMapImageInfo
{
    var string MapName;
    var Texture2D Image;
};
var array<FMapImageInfo> MapImages;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    TravelData = class'KFClassicMode.MS_PC'.Default.TravelData;
    PerkList = class'KFPlayerController'.default.PerkList;
}

simulated function HandleNetworkError( bool bConnectionLost )
{
    if( !bPendingTravel )
    {
        Super.HandleNetworkError(bConnectionLost);
        return;
    }
    
    ConsoleCommand("Open KFMainMenu");
}

final function DelayedTravel(string URL)
{
    bPendingTravel = true;
    bDelayedTravel = true;
    
    MenuInterface(myHUD).MapDescriptionBox.SetVisibility(true);
    MenuInterface(myHUD).MapDescriptionBox.SetText(MenuInterface(myHUD).GetMapDescription(TransitionMap));
    
    PendingURL = URL;
    MenuInterface(myHUD).ShowProgressMsg("Connecting to "$GetIPFromURL(URL));

    SetTimer(1.25f, false, 'ConnectToServer');
}

function ConnectToServer()
{
    TravelData.PendingURL = PendingURL;
    bDelayedTravel = false;
    PendingURL = "";
}

final function AbortConnection()
{
    if( bConnectionFailed )
        HandleNetworkError(false);
    else
    {
        ShowConnectionProgressPopup(PMT_ConnectionFailure,"Connection aborted","User aborted connection...",true);
        ConsoleCommand("Open KFMainMenu");
    }
}

function PlayerTick( float DeltaTime )
{
    if( !bPendingTravel )
    {
        Super.PlayerTick(DeltaTime);
        return;
    }
    
    if( !bDelayedTravel && ConnectionCounter<3 && ++ConnectionCounter==3 )
    {
        if( TravelData.PendingURL!="" )
        {
            MenuInterface(myHUD).ShowProgressMsg("Connecting to "$GetIPFromURL(TravelData.PendingURL));
            ConsoleCommand("Open "$TravelData.PendingURL);
        }

        // Reset all cached data.
        TravelData.Reset();
    }
    PlayerInput.PlayerInput(DeltaTime);
}

static final function string GetIPFromURL(string URL)
{
    local int Index;
    
    Index = InStr(URL, "?");
    if( Index != INDEX_NONE )
        URL = Left(URL, Index);
        
    return URL;
}

reliable client event bool ShowConnectionProgressPopup( EProgressMessageType ProgressType, string ProgressTitle, string ProgressDescription, bool SuppressPasswordRetry = false)
{
	local KFGameEngine KFGEngine;
	local KFGameViewportClient KFGVPC;
	local string CachedTitle, CachedMessage;
    
    if( !bPendingTravel )
    {
        KFGVPC = KFGameViewportClient(LocalPlayer(Player).ViewportClient);
        if( KFGVPC != none && KFGVPC.ErrorTitle != "" )
            KFGVPC.GetErrorMessage(CachedTitle, CachedMessage);
        else
        {
            CachedTitle = ProgressTitle;
            CachedMessage = ProgressDescription;
        }
        
        `Print(CachedTitle);

        switch(ProgressType)
        {
            case    PMT_ConnectionFailure :
            case    PMT_PeerConnectionFailure :
                PopupMenu = UIR_Popup(GUIController.OpenMenu(class'UIR_Popup'));
                DestroyOnlineGame();
                KFGEngine = KFGameEngine( Class'KFGameEngine'.static.GetEngine() );
                if( KFGEngine != none )
                {
                    switch (KFGEngine.LastConnectionError)
                    {
                        case CE_WrongPassword:
                            PopupMenu.WindowTitle = CachedTitle;
                            PopupMenu.InfoLabel.SetText(CachedMessage);
                            KFGEngine.LastConnectionError = CE_None;
                            return true;
                        default:
                            PopupMenu.WindowTitle = CachedTitle;
                            PopupMenu.InfoLabel.SetText(CachedMessage);
                            KFGEngine.LastConnectionError = CE_None;
                            return true;
                    }
                }
            break;
        }

        return false;
    }
        
    if( bConnectionFailed )
        return false;
        
    switch(ProgressType)
    {
    case PMT_ConnectionFailure:
    case PMT_PeerConnectionFailure:
        bConnectionFailed = true;
        MenuInterface(myHUD).ShowProgressMsg("Connection Error: "$ProgressTitle$"|"$ProgressDescription$"|Disconnecting...",true);
        SetTimer(4,false,'HandleNetworkError');
        return true;
    case PMT_DownloadProgress:
    case PMT_AdminMessage:
        MenuInterface(myHUD).ShowProgressMsg(ProgressTitle$"|"$ProgressDescription);
        return true;
    }
    return false;
}

function OpenLobbyMenu()
{
    GUIController.OpenMenu(MainMenuClass);
}

simulated function CancelConnection();

defaultproperties
{
    InputClass=class'KFClassicMenu.MenuPlayerInput'
    
    MainMenuClass=class'KFClassicMenu.UI_MainMenu'
    StartMenuClass=class'KFClassicMenu.UI_StartGame'
    ServerBrowserClass=class'KFClassicMenu.UI_ServerBrowser'
    SettingsMenuClass=class'KFClassicMenu.UI_SettingsMenu'
    FlashUIClass=class'KFClassicMenu.UI_FlashMenu'
    LobbyMenuClass=None
}