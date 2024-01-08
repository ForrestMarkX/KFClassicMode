Class UIP_ServerList extends KFGUI_MultiComponent
    config(UI);

var KFGUI_ColumnList CurrentServers, PlayerInfo;
var KFGUI_RightClickMenu ServerRightClick;
var UI_ServerBrowser ServerBrowser;
var KFGUI_ComponentList FiltersBox;
var KFGUI_Frame FiltersFrame;
var KFGUI_ComboBox PingBox, DifficultyBox, LengthBox, GameModeBox, MapsBox;
var KFGUI_TextLable PingLabel, DifficultyLabel, LengthLabel, GameModeLabel, MapsLabel, NameLabel;
var KFGUI_EditBox ServerNameBox;

var class<KFGFxServerBrowser_Filters> Filters;

var int FakePlayerIndex, LastServerCount, SelectedServerIndex;
var array<string> ServerDifficultyIcons, OfficialMaps;
var string PasswordIcon, VACIcon, StatsIcon;
var array<int> PingFilter;
var ESteamMatchmakingType SearchType;

var globalconfig string SavedServerName;
var globalconfig bool bNoPassword, bNoMutators, bNotFull, bNotEmpty, bUsesStats, bCustom, bDedicated, bVAC_Secure, bInLobby, bInProgress, bOnlyStockMaps, bOnlyCustomMaps, bLimitServerResults;
var globalconfig byte SavedGameModeIndex, SavedMapIndex, SavedDifficultyIndex, SavedLengthIndex, SavedPingIndex;

var transient string TransitionMap, TransitionGame, AnyString;
var transient array<string> DifficultyStrings, LengthStrings, GameModeStrings, MapStrings;

var transient bool bJoinAsSpectator, bOnlyCopyIP;
var transient string ServerPassword;
var transient OnlineSubsystem OnlineSub;
var transient OnlineGameInterface GameInterface;
var transient KFDataStore_OnlineGameSearch SearchDataStore;

var transient int LastSearchIndex;

var transient enum EQueryCompletionAction
{
    QUERYACTION_None,
    QUERYACTION_Default,
    QUERYACTION_CloseScene,
    QUERYACTION_JoinServer,
    QUERYACTION_RefreshAll,
} QueryCompletionAction;

var MenuPlayerController PC;

function InitMenu()
{
    local DataStoreClient DSClient;
    local int i;
    
    Super.InitMenu();
    
    AnyString = class'KFCommon_LocalizedStrings'.default.NoPreferenceString;
    OfficialMaps = class'KFGFxMenu_StartGame'.default.StockMaps;
    
    PC = MenuPlayerController(GetPlayer());
    CurrentServers = KFGUI_ColumnList(FindComponentID('CurrentServers'));
    PlayerInfo = KFGUI_ColumnList(FindComponentID('PlayerInfo'));
    ServerBrowser = UI_ServerBrowser(ParentComponent.ParentComponent);
    
    CurrentServers.Columns[1].Text = class'KFGFxMenu_ServerBrowser'.default.NameString;
    CurrentServers.Columns[2].Text = class'KFGFxMenu_ServerBrowser'.default.GameModeString;
    CurrentServers.Columns[3].Text = class'KFGFxMenu_ServerBrowser'.default.MapString;
    CurrentServers.Columns[4].Text = class'KFGFxMenu_ServerBrowser'.default.PlayersString;
    CurrentServers.Columns[5].Text = class'KFGFxMenu_ServerBrowser'.default.WaveString;
    CurrentServers.Columns[6].Text = class'KFGFxMenu_ServerBrowser'.default.PingString;
    
    FiltersFrame = KFGUI_Frame(FindComponentID('FiltersFrame'));
    FiltersFrame.AddComponent(FiltersBox);
    FiltersFrame.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];
    FiltersFrame.WindowTitle = class'KFGFxMenu_ServerBrowser'.default.FiltersString;
    
    DSClient = class'UIInteraction'.static.GetDataStoreClient();
    if( DSClient != None )
        SearchDataStore = KFDataStore_OnlineGameSearch(DSClient.FindDataStore('KFGameSearch'));
    
    OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
    GameInterface = OnlineSub.GameInterface;
    
    ServerRightClick.OnSelectedItem = ClickedRow;
    
    AddCheckBox(Filters.default.NotEmptyString,"Do not display empty servers.",'bNoEmpty',bNotEmpty);
    AddCheckBox(Filters.default.NotFullString,"Do not display full servers.",'bNoFull',bNotFull);
    AddCheckBox(Filters.default.NoPasswordString,"Do not display passworded servers.",'bNoPassword',bNoPassword);
    AddCheckBox(Filters.default.NoRankedCustomString,"Do not display custom servers.",'bNoCustom',bCustom);
    AddCheckBox(Localize("KFGFxServerBrowser_Filters", "NoStatsEnabledString", "KFGame"),"Do not display ranked servers.",'bNoRanked',!bUsesStats);
    AddCheckBox(Filters.default.InLobbyString,"Only display servers that are in the lobby.",'bInLobby',bInLobby);
    AddCheckBox(Filters.default.InProgressString,"Only display servers that are in progress.",'bInProgress',bInProgress);
    AddCheckBox(Filters.default.OnlyStockMapsString,"Only display servers using stock maps.",'bOnlyStock',bOnlyStockMaps);
    AddCheckBox(Filters.default.OnlyCustomMapsString,"Only display servers using custom maps.",'bOnlyCustom',bOnlyCustomMaps);
    
    PingBox = AddComboBox(class'KFGFxMenu_ServerBrowser'.default.PingString,"Do not show servers with a ping higher than this.",'PingSetting',PingLabel);
    PingBox.Values.AddItem(AnyString);
    for( i=0; i<class'KFGFxMenu_ServerBrowser'.default.PingOptionStrings.Length; i++ )
    {
        PingBox.Values.AddItem(class'KFGFxMenu_ServerBrowser'.default.PingOptionStrings[i]);
    }  
    
    DifficultyStrings = class'KFCommon_LocalizedStrings'.static.GetDifficultyStringsArray();
    DifficultyBox = AddComboBox(class'KFGFxMenu_ServerBrowser'.default.DifficultyString,"Only show servers using this difficulty.",'DifficultySetting',DifficultyLabel);
    DifficultyBox.Values.AddItem(AnyString);
    for( i=0; i<DifficultyStrings.Length; i++ )
    {
        DifficultyBox.Values.AddItem(DifficultyStrings[i]);
    }
    
    LengthStrings = class'KFCommon_LocalizedStrings'.static.GetLengthStringsArray();
    LengthBox = AddComboBox(class'KFGFxMenu_ServerBrowser'.default.LengthString,"Only show servers using this game length.",'LengthSetting',LengthLabel);
    LengthBox.Values.AddItem(AnyString);
    for( i=0; i<LengthStrings.Length; i++ )
    {
        LengthBox.Values.AddItem(LengthStrings[i]);
    }
    
    GameModeStrings = class'KFCommon_LocalizedStrings'.static.GetGameModeStringsArray();
    GameModeBox = AddComboBox(class'KFGFxMenu_ServerBrowser'.default.GameModeString,"Only show servers using this game mode.",'GamemodeSetting',GameModeLabel);
    GameModeBox.Values.AddItem(AnyString);
    for( i=0; i<GameModeStrings.Length; i++ )
    {
        GameModeBox.Values.AddItem(GameModeStrings[i]);
    }
    
    class'KFGFxMenu_StartGame'.static.GetMapList(MapStrings, SavedGameModeIndex, true);
    MapsBox = AddComboBox(class'KFGFxMenu_ServerBrowser'.default.MapString,"Only show servers using this map.",'MapSetting',MapsLabel);
    MapsBox.Values.AddItem(AnyString);
    for( i=0; i<MapStrings.Length; i++ )
    {
        MapsBox.Values.AddItem(MapStrings[i]);
    }
    
    ServerNameBox = AddEditBox(class'KFGFxMenu_ServerBrowser'.default.NameString,"Only show servers using this name.",'NameSetting',NameLabel);
    ServerNameBox.SetText(SavedServerName, true);
}

function ShowMenu()
{
    Super.ShowMenu();
    
    GameInterface.SetMatchmakingTypeMode(SearchType);
    RefreshList();
    PlayerInfo.EmptyList();
    
    if (SavedDifficultyIndex >= class'KFGameInfo'.default.GameModes[GetUsableGameMode(SavedGameModeIndex)].DifficultyLevels)
        SavedDifficultyIndex = 255;
    
    if (SavedLengthIndex >= class'KFGameInfo'.default.GameModes[GetUsableGameMode(SavedGameModeIndex)].Lengths)
        SavedLengthIndex = 255;
    
    if (SavedGameModeIndex >= class'KFGameInfo'.default.GameModes.Length)
        SavedGameModeIndex = 255;
    
    if( SavedGameModeIndex == 255 )
        GameModeBox.SetValue(AnyString);
    else GameModeBox.SetValue(GameModeStrings[SavedGameModeIndex]); 
    
    if (SavedMapIndex >= class'KFGameInfo'.default.GameModes.Length)
        SavedMapIndex = 255;
    
    if( SavedDifficultyIndex == 255 )
        DifficultyBox.SetValue(AnyString);
    else DifficultyBox.SetValue(DifficultyStrings[SavedDifficultyIndex]);  

    if( SavedMapIndex == 255 )
        MapsBox.SetValue(AnyString);
    else MapsBox.SetValue(MapStrings[SavedMapIndex]);     
    
    if( SavedLengthIndex == 255 )
        LengthBox.SetValue(AnyString);
    else LengthBox.SetValue(LengthStrings[SavedLengthIndex]); 
    
    if( SavedPingIndex == 255 )
        PingBox.SetValue(AnyString);
    else PingBox.SetValue(class'KFGFxMenu_ServerBrowser'.default.PingOptionStrings[SavedPingIndex]);

    SaveConfig();    
}

function int GetUsableGameMode(int ModeIndex)
{
    if (ModeIndex >= class'KFGameInfo'.default.GameModes.Length || ModeIndex < 0)
    {
        return 0;
    }
    else
    {
        return ModeIndex;
    }
}

function RefreshList()
{
    ServerBrowser.NumServers.SetText("Servers Recieved: 0");
    CancelQuery(QUERYACTION_RefreshAll);
    KFOnlineGameSearch(SearchDataStore.GetCurrentGameSearch()).MaxSearchResults = MaxInt;
}

function OnCancelSearchComplete( bool bWasSuccessful )
{
    local EQueryCompletionAction CurrentAction;    
    
    GameInterface.ClearCancelFindOnlineGamesCompleteDelegate(OnCancelSearchComplete);

    CurrentAction = QueryCompletionAction;
    QueryCompletionAction = QUERYACTION_None;
    
    LastSearchIndex = 0;

    switch ( CurrentAction )
    {
    case QUERYACTION_CloseScene:
        CurrentServers.EmptyList();
        break;
    case QUERYACTION_RefreshAll:
        CurrentServers.EmptyList();
        SubmitServerListQuery(FakePlayerIndex);
        break;
    }
}

function CancelQuery( optional EQueryCompletionAction DesiredCancelAction=QUERYACTION_Default )
{
    if ( QueryCompletionAction == QUERYACTION_None )
    {
        QueryCompletionAction = DesiredCancelAction;
        if ( SearchDataStore.GetActiveGameSearch() != None )
        {
            if( class'WorldInfo'.static.IsConsoleBuild() )
            {
                class'GameEngine'.static.GetPlayfabInterface().CancelGameSearch();
                OnCancelSearchComplete(true);
            }
            else
            {
                GameInterface.AddCancelFindOnlineGamesCompleteDelegate(OnCancelSearchComplete);
                GameInterface.CancelFindOnlineGames();
            }
        }
        else if ( SearchDataStore.GetCurrentGameSearch().Results.Length > 0 || QueryCompletionAction == QUERYACTION_RefreshAll )
        {
            OnCancelSearchComplete(true);
        }
        else
        {
            QueryCompletionAction = QUERYACTION_None;
        }
    }
}

function BuildServerFilters(OnlineGameSearch Search)
{
    local string GametagSearch, MapName;
    local int Mode;

    Search.ClearServerFilters();

    Search.AddServerFilter("version_match", string(class'KFGameEngine'.static.GetKFGameVersion()));
    
    // Does nothing?
    Search.TestAddServerFilter( bNotFull, "notfull");
    Search.TestAddServerFilter( bNotEmpty, "hasplayers");

    if (!class'WorldInfo'.static.IsConsoleBuild())
    {
        Search.TestAddServerFilter( bDedicated, "dedicated");
        Search.TestAddServerFilter( bVAC_Secure, "secure");
    }

    if (bInProgress && !bInLobby)
        Search.TestAddBoolGametagFilter(GametagSearch, bInProgress, 'bInProgress', 1);
    else if (bInLobby)
        Search.TestAddBoolGametagFilter(GametagSearch, bInLobby, 'bInProgress', 0);

    if (!class'WorldInfo'.static.IsConsoleBuild())
        Search.TestAddBoolGametagFilter(GametagSearch, bNoPassword, 'bRequiresPassword', 0);

    Mode = SavedGameModeIndex;
    if (Mode >= 0 && Mode < 255)
        Search.AddGametagFilter(GametagSearch, 'Mode', string(Mode));
        
    MapName = GetSelectedMap();
    if (MapName != "")
        Search.AddServerFilter("map", MapName);
    
    if (bCustom && !class'WorldInfo'.static.IsConsoleBuild())
        Search.TestAddBoolGametagFilter(GametagSearch, bCustom, 'bCustom', 0);

    if (Len(GametagSearch) > 0)
        Search.AddServerFilter("gametagsand", GametagSearch);
    if (Search.MasterServerSearchKeys.Length > 1)
        Search.AddServerFilter("and", string(Search.MasterServerSearchKeys.Length), 0);
}

function string GetSelectedMap()
{
    local array<string> MapList;
    class'KFGFxMenu_StartGame'.static.GetMapList(MapList, SavedGameModeIndex);
    if( SavedMapIndex >= MapList.Length )
        return "";
    return MapList[SavedMapIndex];
}

function bool ShouldServerBeFiltered(KFOnlineGameSettings Settings)
{
    local int i, MapIndex, NumPlayers;
    local bool bNoPatternFound;
    
    for (i = 0; i < OfficialMaps.Length; i++)
    {
        if( Settings.MapName ~= OfficialMaps[i] )
        {
            MapIndex = i;
            break;
        }
        else MapIndex = INDEX_NONE;
    }
    
    if( bOnlyStockMaps && MapIndex == INDEX_NONE )
        return true;
    else if( bOnlyCustomMaps && MapIndex != INDEX_NONE )
        return true;

    NumPlayers = Settings.NumPublicConnections-Settings.NumOpenPublicConnections-Settings.NumSpectators;
    if( (bNotFull && NumPlayers >= Settings.NumPublicConnections) || (bNotEmpty && NumPlayers <= 0) || Settings.PingInMs > PingFilter[SavedPingIndex] || (SavedDifficultyIndex != 255 && Settings.Difficulty != SavedDifficultyIndex) || (SavedLengthIndex != 255 && GetWaveFilter(SavedLengthIndex, Settings.NumWaves)) || (!bUsesStats && Settings.bUsesStats) )
        return true;
        
    if( SavedServerName != "" )
    {
        bNoPatternFound = InStr(Caps(Owner.CurrentStyle.Trim(Settings.OwningPlayerName)), Caps(SavedServerName)) == INDEX_NONE;
        if( bNoPatternFound )
            return true;
    }
        
    return false;
}

function SubmitServerListQuery(int PlayerIndex)
{
    BuildServerFilters(SearchDataStore.GetCurrentGameSearch());
    
    GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
    if( !SearchDataStore.SubmitGameSearch(class'UIInteraction'.static.GetPlayerControllerId(PlayerIndex), false) )
        GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
}

function OnFindOnlineGamesCompleteDelegate(bool bWasSuccessful)
{
    local bool bSearchCompleted;
    local OnlineGameSearch Search;

    Search = SearchDataStore.GetActiveGameSearch();
    bSearchCompleted = Search == None || Search.Results.Length == LastServerCount;
    if( !bSearchCompleted )
    {
        if( Search.Results.Length > 0 )
            SetTimer(PC.WorldInfo.DeltaSeconds*4.f, false, nameof(UpdateListDataProvider));
        LastServerCount = Search.Results.Length;
    }
    else
    {
        GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
        LastServerCount = -1;
    }
}

function bool GetWaveFilter(int Index, int MaxWaves)
{
    switch(Index)
    {
        case 1:
            return MaxWaves == 4;
        case 2:
            return MaxWaves == 7;
        case 3:
            return MaxWaves >= 10;
    }
}

function UpdateListDataProvider()
{
    local KFOnlineGameSettings TempOnlineGamesSettings;
    local int i, NumPlayers;
    local string CurrentWave, Ping, ServerFlags, GamemodeInfo;
    local KFOnlineGameSearch LatestGameSearch;

    LatestGameSearch = KFOnlineGameSearch(SearchDataStore.GetActiveGameSearch());
    if( LatestGameSearch != None )
    {
        for( i=LastSearchIndex; i<LatestGameSearch.Results.Length; i++ )
        {
            TempOnlineGamesSettings = KFOnlineGameSettings(LatestGameSearch.Results[i].GameSettings);
            if( ShouldServerBeFiltered(TempOnlineGamesSettings) )
                continue;
                
            CurrentWave = TempOnlineGamesSettings.CurrentWave$(IsEndlessModeIndex(TempOnlineGamesSettings.Mode, TempOnlineGamesSettings.NumWaves) ? "" : ("/"$TempOnlineGamesSettings.NumWaves));
            NumPlayers = TempOnlineGamesSettings.NumPublicConnections-TempOnlineGamesSettings.NumOpenPublicConnections-TempOnlineGamesSettings.NumSpectators;
            
            if( TempOnlineGamesSettings.PingInMs >= 200 )
                Ping = "\\cG";
            else if( TempOnlineGamesSettings.PingInMs >= 150 )
                Ping = "\\cF";
            else Ping = "\\cD";
            
            Ping $= (TempOnlineGamesSettings.PingInMs < 0) ? ("-") : (string(TempOnlineGamesSettings.PingInMs)) $ "\\cC";
            
            ServerFlags = "<Icon>"$GetDifficultyIcon(TempOnlineGamesSettings.Difficulty)$"</Icon>";
            if( TempOnlineGamesSettings.bRequiresPassword )
                ServerFlags $= "<Icon>"$PasswordIcon$"</Icon>";
            if( TempOnlineGamesSettings.bAntiCheatProtected )
                ServerFlags $= "<Icon>"$VACIcon$"</Icon>";
            if( TempOnlineGamesSettings.bUsesStats )
                ServerFlags $= "<Icon>"$StatsIcon$"</Icon>";
                
            GamemodeInfo = class'KFCommon_LocalizedStrings'.static.GetGameModeString(TempOnlineGamesSettings.Mode);
            if( GamemodeInfo == class'KFCommon_LocalizedStrings'.default.NoPreferenceString )
                GamemodeInfo = "Custom";
            
            CurrentServers.AddLine(ServerFlags$"\n"$Owner.CurrentStyle.Trim(TempOnlineGamesSettings.OwningPlayerName)$"\n"$GamemodeInfo$"\n"$TempOnlineGamesSettings.MapName$"\n"$NumPlayers$"/"$TempOnlineGamesSettings.NumPublicConnections$"\n"$CurrentWave$"\n"$Ping,i,
            MakeSortStr(TempOnlineGamesSettings.Difficulty)$"\n"$TempOnlineGamesSettings.OwningPlayerName$"\n"$GamemodeInfo$"\n"$TempOnlineGamesSettings.MapName$"\n"$MakeSortStr(NumPlayers)$"\n"$MakeSortStr(TempOnlineGamesSettings.CurrentWave)$"\n"$MakeSortStr(TempOnlineGamesSettings.PingInMs));
            
            ServerBrowser.NumServers.SetText("Servers Recieved:"@CurrentServers.ListCount);
        }
        
        LastSearchIndex = LatestGameSearch.Results.Length;
    }
}

function string GetDifficultyIcon(byte Diff)
{
    if( Diff < ServerDifficultyIcons.Length )
        return ServerDifficultyIcons[Diff];
    
    return ServerDifficultyIcons[ServerDifficultyIcons.Length-1];
}

function bool IsEndlessModeIndex(int ModeIndex, optional byte NumWaves)
{
    return ModeIndex == 3 || NumWaves >= 254;
}

function SelectedServer(KFGUI_ListItem Item, int Row, bool bRight, bool bDblClick)
{
    if( Item == None )
        return;
        
    SelectedServerIndex = Item.Value;

    if( bRight )
    {
        ServerRightClick.ItemRows[3].Text = IsSelectedServerFavorited(SelectedServerIndex) ? "Remove from favorites" : "Add to favorites";
        ServerRightClick.OpenMenu(Self);
    }
    else if( bDblClick )
    {
        JoinServer(SelectedServerIndex,,false);
    }
    else 
    {
        if (SearchDataStore.FindServerPlayerList(SelectedServerIndex))
            GameInterface.AddGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
        else GameInterface.ClearGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
    }
}

function OnGetPlayerListComplete(OnlineGameSettings Settings, bool Success)
{
    UpdatePlayerInfo();
}

function UpdatePlayerInfo()
{
    local OnlineGameSettings Settings;
    local int i;
    
    Settings = GetServerDetails(SelectedServerIndex);
    PlayerInfo.EmptyList();
    for (i = 0; i < Settings.PlayersInGame.Length; ++i)
    {
        PlayerInfo.AddLine(Settings.PlayersInGame[i].PlayerName$"\n"$Owner.CurrentStyle.GetTimeString(Settings.PlayersInGame[i].TimePlayed)$"\n$"$class'KFScoreBoard'.static.GetNiceSize(Settings.PlayersInGame[i].Score),i,
        Settings.PlayersInGame[i].PlayerName$"\n"$MakeSortStr(Settings.PlayersInGame[i].TimePlayed)$"\n"$MakeSortStr(Settings.PlayersInGame[i].Score));
    }
}

function JoinServer(optional int SearchResultIndex = -1, optional string WithPassword = "", optional bool JoinAsSpectator = false)
{
    local KFOnlineGameSearch GameSearch;
    local KFOnlineGameSettings ServerSettings;
    local OnlineGameSearchResult SearchResult;
    local string GamemodeInfo;
    local UIR_EnterPassword Password;

    GameSearch = KFOnlineGameSearch(SearchDataStore.GetCurrentGameSearch());
    if( SearchResultIndex >= 0 && SearchResultIndex < GameSearch.Results.Length ) 
        SearchResult = GameSearch.Results[SearchResultIndex];
    else return;
    
    SelectedServerIndex = SearchResultIndex;

    ServerSettings = KFOnlineGameSettings(SearchResult.GameSettings);
    if(ServerSettings == None) 
        return;
        
    if( ServerSettings.bRequiresPassword && WithPassword == "" )
    {
        Password = UIR_EnterPassword(Owner.OpenMenu(class'UIR_EnterPassword'));
        Password.ServerListOwner = Self;
        Password.SearchIndex = SearchResultIndex;
        Password.JoinAsSpectator = JoinAsSpectator;
        return;
    }
        
    GamemodeInfo = class'KFCommon_LocalizedStrings'.static.GetGameModeString(ServerSettings.Mode);
    if( GamemodeInfo == class'KFCommon_LocalizedStrings'.default.NoPreferenceString )
        GamemodeInfo = "Custom";
        
    TransitionMap = ServerSettings.MapName;
    TransitionGame = GamemodeInfo;

    ServerPassword = WithPassword;
    bJoinAsSpectator = JoinAsSpectator;
    ProcessJoin(SearchResult);
}

function ServerConnect(string URL)
{
    if( bOnlyCopyIP )
    {
        bOnlyCopyIP = false;
        PC.CopyToClipboard(URL);
        return;
    }
    
    ClearDelegates();

    PC.TransitionMap = TransitionMap;
    PC.TransitionGame = TransitionGame;
    
    PC.MyGFxManager.Close();
    PC.MyGFxManager = None;
    
    PC.DelayedTravel(URL);
    
    ServerBrowser.DoClose();
}

function JoinGameURL()
{
    local string URL;

    URL = BuildJoinURL();

    KFGameEngine(Class'Engine'.static.GetEngine()).OnHandshakeComplete = OnHandshakeComplete;

    ServerConnect(URL);
    ServerPassword = "";
}

function string BuildJoinURL()
{
    local string ConnectURL;

    ConnectURL = KFGameViewportClient(LocalPlayer(PC.Player).ViewPortClient).LastConnectionAttemptAddress;

    if ( ServerPassword != "" )
    {
        ConnectURL $= "?Password=" $ ServerPassword;
        OnlineSub.GetLobbyInterface().SetServerPassword(ServerPassword);
    }
    else
    {
        OnlineSub.GetLobbyInterface().SetServerPassword("");
    }

    if(bJoinAsSpectator)
    {
        ConnectURL $= "?SpectatorOnly=1";
    }
    ConnectURL $= OnlineSub.GetLobbyInterface().GetLobbyURLString();
    return ConnectURL;
}

function bool OnHandshakeComplete(bool bSuccess, string Error, out int SuppressPasswordRetry)
{
    KFGameEngine(Class'Engine'.static.GetEngine()).OnHandshakeComplete = None;
    if (bSuccess)
    {
        OnlineSub.GetLobbyInterface().LobbyJoinServer(KFGameViewportClient(LocalPlayer(PC.Player).ViewPortClient).LastConnectionAttemptAddress);
    }
    SuppressPasswordRetry = 1;

    return false;
}

function ProcessJoin(OnlineGameSearchResult SearchResult)
{
    if ( GameInterface != None )
    {
        if (SearchResult.GameSettings != None)
        {
            GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);

            if (OnlineGameInterfaceImpl(GameInterface).GetGameSearch() != none)
                GameInterface.DestroyOnlineGame('Game');

            GameInterface.JoinOnlineGame(0, 'Game', SearchResult);
        }
        else OnJoinGameComplete('Game', false);
    }
    else
    {
        ServerPassword = "";
        bJoinAsSpectator = false;
    }
}

function OnJoinGameComplete(name SessionName, bool bSuccessful)
{
    local string URL;

    if (GameInterface != None)
    {
        if (bSuccessful)
        {
            if (GameInterface.GetResolvedConnectString(SessionName, URL))
            {
                KFGameViewportClient(LocalPlayer(PC.Player).ViewPortClient).LastConnectionAttemptAddress = URL;
                JoinGameURL();
            }
        }

        GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
    }

    ServerPassword = "";
}

function KFOnlineGameSettings GetServerDetails(int ServerIndex)
{
    local KFOnlineGameSearch GameSearch;
    local KFOnlineGameSettings KFOGS;

    GameSearch = KFOnlineGameSearch(SearchDataStore.GetCurrentGameSearch());

    if(GameSearch != none)
    {
        KFOGS = KFOnlineGameSettings(GameSearch.Results[ServerIndex].GameSettings);
    }
    return KFOGS;
}

function bool IsSelectedServerFavorited(int ServerSearchIndex)
{
    return GameInterface.IsSearchResultInFavoritesList(ServerSearchIndex);
}

function bool SetSelectedServerFavorited(bool bFavorited)
{
    if (!bFavorited)
    {
        return GameInterface.AddSearchResultToFavorites(SelectedServerIndex);
    }
    else
    {
        return GameInterface.RemoveSearchResultFromFavorites(SelectedServerIndex);
    }
}

function ClickedRow( int RowNum )
{
    switch(RowNum)
    {
        case 0:
            JoinServer(SelectedServerIndex,,false);
            break;
        case 1:
            JoinServer(SelectedServerIndex,,true);
            break;
        case 3:
            SetSelectedServerFavorited(IsSelectedServerFavorited(SelectedServerIndex));
            break;
        case 4:
            bOnlyCopyIP = true;
            JoinServer(SelectedServerIndex,,false);
            break;
    }
}

final function KFGUI_CheckBox AddCheckBox(string Cap, string TT, name IDN, bool bDefault)
{
    local KFGUI_CheckBox CB;
    
    CB = KFGUI_CheckBox(FiltersBox.AddListComponent(class'KFGUI_CheckBox'));
    CB.LableString = Cap;
    CB.ToolTip = TT;
    CB.bChecked = bDefault;
    CB.InitMenu();
    CB.ID = IDN;
    CB.OnCheckChange = CheckChange;
    return CB;
}

final function KFGUI_ComboBox AddComboBox(string Cap, string TT, name IDN, out KFGUI_TextLable Label)
{
    local KFGUI_ComboBox CB;
    local KFGUI_MultiComponent MC;
    
    MC = KFGUI_MultiComponent(FiltersBox.AddListComponent(class'KFGUI_MultiComponent'));
    MC.InitMenu();
    MC.XSize = 0.95;
    
    Label = new(MC) class'KFGUI_TextLable';
    Label.SetText(Cap);
    Label.XSize = 0.60;
    Label.FontScale = 1;
    Label.AlignY = 1;
    MC.AddComponent(Label);
    
    CB = new(MC) class'KFGUI_ComboBox';
    CB.XPosition = 0.775;
    CB.XSize = 0.225;
    CB.ToolTip = TT;
    CB.ID = IDN;
    CB.OnComboChanged = OnComboChanged;
    MC.AddComponent(CB);

    return CB;
}

final function KFGUI_EditBox AddEditBox(string Cap, string TT, name IDN, out KFGUI_TextLable Label)
{
    local KFGUI_EditBox EB;
    local KFGUI_MultiComponent MC;
    
    MC = KFGUI_MultiComponent(FiltersBox.AddListComponent(class'KFGUI_MultiComponent'));
    MC.InitMenu();
    MC.XSize = 0.95;
    
    Label = new(MC) class'KFGUI_TextLable';
    Label.SetText(Cap);
    Label.XSize = 0.60;
    Label.FontScale = 1;
    Label.AlignY = 1;
    MC.AddComponent(Label);
    
    EB = new(MC) class'KFGUI_EditBox';
    EB.YPosition = 0.25;
    EB.XPosition = 0.725;
    EB.XSize = 0.275;
    EB.YSize = 0.5;
    EB.ToolTip = TT;
    EB.ID = IDN;
    EB.OnTextFinished = OnTextEntered;
    EB.OnChange = OnTextChanged;
    EB.bNoClearOnEnter = true;
    EB.bDrawBackground = true;
    MC.AddComponent(EB);

    return EB;
}

function OnTextChanged(KFGUI_EditBox Sender)
{
    switch(Sender.ID)
    {
        case 'NameSetting':
            SavedServerName = Sender.GetText();
            break;
    }
    
    SaveConfig();
}

function OnTextEntered(KFGUI_EditBox Sender, string S);

function OnComboChanged(KFGUI_ComboBox Sender)
{
    local int SavedIndex;
    
    SavedIndex = Sender.SelectedIndex-1;
    switch(Sender.ID)
    {
        case 'PingSetting':
            if( SavedIndex == -1 )
                SavedPingIndex = 255;
            else SavedPingIndex = SavedIndex;
            break;        
        case 'DifficultySetting':
            if( SavedIndex == -1 )
                SavedDifficultyIndex = 255;
            else SavedDifficultyIndex = SavedIndex;
            break;        
        case 'LengthSetting':
            if( SavedIndex == -1 )
                SavedLengthIndex = 255;
            else SavedLengthIndex = SavedIndex;
            break;        
        case 'GamemodeSetting':
            if( SavedIndex == -1 )
                SavedGameModeIndex = 255;
            else SavedGameModeIndex = SavedIndex;       
        case 'MapSetting':
            if( SavedIndex == -1 )
                SavedMapIndex = 255;
            else SavedMapIndex = SavedIndex;
            break;
    }
    
    SaveConfig();
}

function CheckChange( KFGUI_CheckBox Sender )
{
    switch( Sender.ID )
    {
        case 'bNoEmpty':
            bNotEmpty = Sender.bChecked;
            break;
        case 'bNoFull':
            bNotFull = Sender.bChecked;
            break;
        case 'bNoPassword':
            bNoPassword = Sender.bChecked;
            break;
        case 'bNoCustom':
            bCustom = Sender.bChecked;
            break;        
        case 'bNoRanked':
            bUsesStats = !Sender.bChecked;
            break;
        case 'bOnlyStock':
            bOnlyStockMaps = Sender.bChecked;
            break;
        case 'bOnlyCustom':
            bOnlyCustomMaps = Sender.bChecked;
            break;        
        case 'bInProgress':
            bInProgress = Sender.bChecked;
            break;       
        case 'bInLobby':
            bInLobby = Sender.bChecked;
            break;
    }
    
    SaveConfig();
}

function CloseMenu()
{
    Super.CloseMenu();
    
    CancelQuery(QUERYACTION_CloseScene);
    ClearDelegates();
}

function ClearDelegates()
{
    KFGameEngine(Class'Engine'.static.GetEngine()).OnHandshakeComplete = None;

    GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
    GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
    GameInterface.ClearCancelFindOnlineGamesCompleteDelegate(OnCancelSearchComplete);
    GameInterface.ClearGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
}

defaultproperties
{
    LastServerCount=-1
    FakePlayerIndex=0
    SearchType=SMT_Internet
    Filters=class'KFGFxServerBrowser_Filters'
    
    PingFilter.Add(50)
    PingFilter.Add(100)
    PingFilter.Add(150)
    PingFilter.Add(200)
    PingFilter(255)=9999
    
    ServerDifficultyIcons.Add("KFClassicMenu_Assets.Easy")
    ServerDifficultyIcons.Add("KFClassicMenu_Assets.Normal")
    ServerDifficultyIcons.Add("KFClassicMenu_Assets.Hard")
    ServerDifficultyIcons.Add("KFClassicMenu_Assets.HellOnEarth")
    
    PasswordIcon="KFClassicMenu_Assets.passworded"
    VACIcon="KFClassicMenu_Assets.VAC_Servericon"
    StatsIcon="KFClassicMenu_Assets.Stats"
    
    Begin Object Class=KFGUI_RightClickMenu Name=ServerRClicker
        ItemRows.Add((Text="Join"))
        ItemRows.Add((Text="Join as Spectator"))
        ItemRows.Add((bSplitter=true))
        ItemRows.Add((Text="Add to favorites"))
        ItemRows.Add((Text="Copy IP"))
    End Object
    ServerRightClick=ServerRClicker
    
    Begin Object Class=KFGUI_ColumnList Name=PlayerInfo
        bHideScrollbar=true
        XPosition=0.505
        YPosition=0.57
        YSize=0.5
        XSize=0.5
        ID="PlayerInfo"
        Columns.Add((Text="NAME",Width=0.5))
        Columns.Add((Text="TIME",Width=0.25))
        Columns.Add((Text="SCORE",Width=0.25))
    End Object
    Components.Add(PlayerInfo)
    
    Begin Object Class=KFGUI_ColumnList Name=CurrentServers
        bHideScrollbar=true
        YSize=0.56
        XPosition=0.005
        ID="CurrentServers"
        Columns.Add((Text="",Width=0.05,bOnlyTextures=true))
        Columns.Add((Width=0.5))
        Columns.Add((Width=0.075))
        Columns.Add((Width=0.175))
        Columns.Add((Width=0.075))
        Columns.Add((Width=0.075))
        Columns.Add((Width=0.075))
        OnSelectedRow=SelectedServer
    End Object
    Components.Add(CurrentServers)
    
    Begin Object Class=KFGUI_Frame Name=FiltersFrame
        XPosition=0.005
        YPosition=0.57
        YSize=0.5
        XSize=0.475
        EdgeSize(2)=-20
        ID="FiltersFrame"
    End Object    
    Components.Add(FiltersFrame)
    
    Begin Object Class=KFGUI_ComponentList Name=FiltersBox
        XPosition=0
        YPosition=0
        YSize=0.96
        XSize=1
        ID="FiltersBox"
        ListItemsPerPage=8
    End Object
    FiltersBox=FiltersBox
}