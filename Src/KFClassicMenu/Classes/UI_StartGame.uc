Class UI_StartGame extends UI_BaseMenuBackgrounds;

var UIP_GameInfo GameInfo;
var UIP_Mutators MutatorInfo;

function InitMenu()
{
    Pages[0].Caption = class'KFGFxServerBrowser_ServerDetails'.default.ServerInfoString;
    Pages[1].Caption = class'KFGFxServerBrowser_ServerDetails'.default.MutatorsString;
    
    Super.InitMenu();
    
    AddMenuButton('Play',class'KFCommon_LocalizedStrings'.default.StartOfflineGameString,"Start the game.");
    AddMenuButton('Spectate',class'KFGFxServerBrowser_ServerDetails'.default.SpectateGameString,"Start and spectate the game.");
    AddMenuButton('Back',class'KFGFxWidget_ButtonPrompt'.default.CancelString,"Return to the main menu.");
}

function SetupPageItem(KFGUI_Base P)
{
    if( UIP_GameInfo(P) != None && GameInfo == None )
    {
        GameInfo = UIP_GameInfo(P);
        GameInfo.StartGame = self;
    }
    else if( UIP_Mutators(P) != None && MutatorInfo == None )
    {
        MutatorInfo = UIP_Mutators(P);
        MutatorInfo.StartGame = self;
    }
    Super.SetupPageItem(P);
}

function ButtonClicked( KFGUI_Button Sender )
{
    local string CommandURL, MapName, Options;
    
    CommandURL = GameInfo.BuildStartGameURL();
    MapName = GameInfo.MapsFrame.TranslateOptionsIntoURL();
    Options = Mid(CommandURL, Len(MapName));
    
    switch( Sender.ID )
    {
    case 'Listen':
        PC.ConsoleCommand("Open "$CommandURL$"?Listen");
        break;
    case 'Spectate':
        CommandURL $= "?SpectatorOnly=1";
    case 'Play':
        PC.TransitionMap = MapName;
        PC.TransitionGame = PC.WorldInfo.Game.static.ParseOption(Options, "Game");
        
        PC.MyGFxManager.Close();
        PC.MyGFxManager = None;
        
        PC.DelayedTravel(CommandURL);
        DoClose();
        break;
    case 'Back':
        PC.OpenLobbyMenu();
        DoClose();
        break;
    }
}

defaultproperties
{
    Pages.Add((PageClass=Class'UIP_GameInfo',Hint="Setup the game to be started."))
    Pages.Add((PageClass=Class'UIP_Mutators',Hint="Select mutators to add to the game."))
}