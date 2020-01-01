Class UI_MainMenu extends KFGUI_Page
    config(UI);

var MenuPlayerController PC;
var KFGUI_List MenuParty;
var KFGUI_Button SoloGame, MultiplayerGame, Gear, Perks, Settings, InventoryB, Vault, Exit, DailyInfo, SeasonalInfo;
var Texture ItemBoxTexture, ItemBarTexture;
var array<KFPlayerReplicationInfo> KFPRIArray;
var KFGameReplicationInfo KFGRI;

var MapImageDownloader ImageDownloader;
var int ImageCount;
var array<string> MapList;

var config string MapImageURL;
var config int iConfigVer;

function InitMenu()
{
    local array<string> StockMaps;
    local int i, j;
    
    Super.InitMenu();
    
    PC = MenuPlayerController(GetPlayer());
    PC.MainMenu = self;
    
    MenuParty = KFGUI_List(FindComponentID('MenuParty'));
    MenuParty.OnDrawItem = DrawPlayerEntry;
    
    SoloGame = KFGUI_Button(FindComponentID('SoloGame'));
    MultiplayerGame = KFGUI_Button(FindComponentID('MultiplayerGame'));
    Gear = KFGUI_Button(FindComponentID('Gear'));
    Perks = KFGUI_Button(FindComponentID('Perks'));
    Settings = KFGUI_Button(FindComponentID('Settings'));
    InventoryB = KFGUI_Button(FindComponentID('Inventory'));
    Vault = KFGUI_Button(FindComponentID('Vault'));
    Exit = KFGUI_Button(FindComponentID('Exit'));
    DailyInfo = KFGUI_Button(FindComponentID('DailyInfo'));
    SeasonalInfo = KFGUI_Button(FindComponentID('SeasonalInfo'));
    
    if( class'KFGameEngine'.static.GetSeasonalEventId() == SEI_None )
        SeasonalInfo.SetVisibility(false);
    
    SoloGame.ButtonText = class'KFGFxWidget_MenuBar'.default.SoloString;
    MultiplayerGame.ButtonText = class'KFGFxWidget_MenuBar'.default.ServerBrowserString;
    Gear.ButtonText = class'KFGFxWidget_MenuBar'.default.MenuStrings[2];
    Perks.ButtonText = class'KFGFxWidget_MenuBar'.default.MenuStrings[1];
    Settings.ButtonText = class'KFGFxWidget_MenuBar'.default.MenuStrings[6];
    InventoryB.ButtonText = class'KFGFxWidget_MenuBar'.default.MenuStrings[4];
    Vault.ButtonText = class'KFGFxWidget_MenuBar'.default.MenuStrings[3];
    Exit.ButtonText = class'KFGFxWidget_MenuBar'.default.MenuStrings[7];
    DailyInfo.ButtonText = class'KFMission_LocalizedStrings'.default.DailyObjectiveString;
    SeasonalInfo.ButtonText = class'KFMission_LocalizedStrings'.default.SeasonalString;
    
    ItemBoxTexture = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_NORMAL];
    ItemBarTexture = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_NORMAL];
    
    class'KFGFxMenu_StartGame'.static.GetMapList(MapList);
    StockMaps = class'KFGFxMenu_StartGame'.default.StockMaps;
    for (i = 0; i < StockMaps.Length; i++)
    {
        for (j = 0; j < MapList.Length; j++)
        {
            if( StockMaps[i] ~= MapList[j] )
                MapList.RemoveItem(MapList[j]);
        }
    }
    
    if( iConfigVer <= 0 )
        MapImageURL = "http://us-fastdl.hellsgamers.com/killingfloor/MapImages/<Map>.png";
    SaveConfig();
    
    for (i = 0; i < MapList.Length; i++)
    {
        GenerateMapSummaryEntries(MapList[i]);
    }
    
    if( MapImageURL != "" )
        StartMapImageDownload();
}

function ShowMenu()
{
    Super.ShowMenu();
    
    Timer();
    SetTimer(0.01,true);
}

// Generate KFMapSummary for map objects
function GenerateMapSummaryEntries(string MapName)
{
    local KFMapSummary MapSummary;
    local array<string> Names;
    local int i;
    local bool bFoundConfig;
    local string S;
    
    GetPerObjectConfigSections(class'KFMapSummary', Names);
    for (i = 0; i < Names.Length; i++)
    {
        if( InStr(Names[i], MapName) != INDEX_NONE )
        {
            bFoundConfig = true;
            break;
        }
    }
    
    if( !bFoundConfig )
    {
        S = Localize("MapInfo", "UIPath", MapName);
        if( InStr(S, "MapInfo.UIPath?") != INDEX_NONE )
            S = "UI_MapPreview_TEX.UI_MapPreview_Placeholder";
        
        MapSummary = New(None, MapName) class'KFMapSummary';
        MapSummary.MapName = MapName;
        MapSummary.ScreenshotPathName = S;
        MapSummary.SaveConfig();
    }
}

function StartMapImageDownload()
{
    if( MapList.Length > 0 )
    {
        ImageCount = 0;
        CreateAndStartDownloader();
    }
}

function CreateAndStartDownloader()
{
    if( ImageCount >= MapList.Length )
        return;
        
    if( class'MS_HUD'.static.GetMapImage(MapList[ImageCount]).Name != 'UI_MapPreview_Placeholder' )
    {
        MapList.RemoveItem(MapList[ImageCount]);
        if( MapList.Length <= 0 )
            return;
    }

	if( ImageDownloader == None )
		ImageDownloader = new(Self) class'MapImageDownloader';
		
    ImageDownloader.MapName = MapList[ImageCount];
    ImageDownloader.DownloadImageFromURL(Repl(MapImageURL, "<Map>", MapList[ImageCount]), ImageDownloadComplete);
}

function ImageDownloadComplete(bool bWasSuccessful)
{
    local FMapImageInfo ImageInfo;
    
    if( bWasSuccessful )
    {
        ImageInfo.MapName = ImageDownloader.MapName;
        ImageInfo.Image = ImageDownloader.TheTexture;
        PC.MapImages.AddItem(ImageInfo);
        
        ImageCount++;
        CreateAndStartDownloader();
    }
    else
    {
        MapList.RemoveItem(ImageDownloader.MapName);
        if( MapList.Length > 0 )
            CreateAndStartDownloader();
    }
}

function Timer()
{
    local KFPlayerReplicationInfo PRI;
    local int i;
    
    if( KFGRI == None )
    {
        KFGRI = KFGameReplicationInfo(GetPlayer().WorldInfo.GRI);
        return;
    }
    
    KFPRIArray.Length = 0;
    for( i=0; i<KFGRI.PRIArray.Length; ++i )
    {
        PRI = KFPlayerReplicationInfo(KFGRI.PRIArray[i]);
        if( PRI==None || PRI.bIsInactive )
            continue;
            
        KFPRIArray.AddItem(PRI);
    }
    MenuParty.ChangeListSize(KFPRIArray.Length);
}

function DrawPlayerEntry( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local float FontScalar, TextYOffset, XL, YL, AvatarXPos, AvatarYPos, ImageBorder;
    local KFPlayerReplicationInfo PRI;
    
    if( KFPRIArray.Length <= 0 )
        return;
    
    PRI = KFPRIArray[Index];
    if( PRI == None )
        return;
    
    YOffset *= 1.05;
    ImageBorder = Owner.CurrentStyle.ScreenScale(6);
    
    C.Font = Owner.CurrentStyle.PickFont(FontScalar);
    FontScalar += 0.2;
    
    if( bFocus )
    {
        C.SetDrawColor(0, 255, 0, 255);
    }
    else
    {
        C.SetDrawColor(255, 255, 255, 255);
    }
    
    C.SetPos(Height,YOffset);
    C.DrawTileStretched(ItemBarTexture,Width-(Height * 2.5),Height,0,0,ItemBarTexture.GetSurfaceWidth(),ItemBarTexture.GetSurfaceHeight());
    
    C.SetDrawColor(255, 255, 255, 255);
    
    C.SetPos(0.f,YOffset);
    C.DrawTileStretched(ItemBoxTexture,Height,Height,0,0,ItemBoxTexture.GetSurfaceWidth(),ItemBoxTexture.GetSurfaceHeight());
    
    C.TextSize("ABC", XL, YL, FontScalar, FontScalar);
    TextYOffset = YOffset + (Height / 2) - (YL / 1.75f);
    
    if( PRI.Avatar != None )
    {
        if( PRI.Avatar == class'KFScoreBoard'.default.DefaultAvatar )
            class'KFScoreBoard'.static.CheckAvatar(PRI, PC);
            
        AvatarXPos = Height-(ImageBorder*2);
        AvatarYPos = Height-(ImageBorder*2);
        
        C.SetPos((Height / 2) - (AvatarXPos / 2), YOffset + (Height / 2) - (AvatarYPos / 2));
        C.DrawRect(AvatarXPos, AvatarYPos, PRI.Avatar);
    } 
    else
    {
        if( !PRI.bBot )
            class'KFScoreBoard'.static.CheckAvatar(PRI, PC);
    }
    
    C.SetPos(Height + (ImageBorder*2), TextYOffset);
    C.DrawText(PRI.PlayerName,, FontScalar, FontScalar);
}

function bool DrawMenuButtons(Canvas C, KFGUI_Button B)
{
    local Color Clr, OutlineClr;
    
    if( B.bDisabled )
        Clr = MakeColor(0, 0, 0, 220);
    else if( B.bPressedDown )
        Clr = MakeColor(5, 5, 5, 220);
    else if( B.bFocused )
        Clr = MakeColor(65, 65, 65, 220);
    else Clr = MakeColor(15, 15, 15, 220);
    
    OutlineClr = Owner.HUDOwner.DefaultHudOutlineColor;
    OutlineClr.A = Clr.A;

    C.DrawColor = Clr;
    C.SetPos(Owner.HUDOwner.ScaledBorderSize*2, 0.f);
    Owner.CurrentStyle.DrawWhiteBox(B.CompPos[2]-(Owner.HUDOwner.ScaledBorderSize*4), B.CompPos[3]);

    Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, 0.f, 0.f, Owner.HUDOwner.ScaledBorderSize*2, B.CompPos[3], OutlineClr, true, false, true, false);
    Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, B.CompPos[2]-(Owner.HUDOwner.ScaledBorderSize*2), 0.f, Owner.HUDOwner.ScaledBorderSize*2, B.CompPos[3], OutlineClr, false, true, false, true);

    return true;
}

function ButtonClicked( KFGUI_Button Sender )
{
    local EUIIndex UIIndex;
    
    UIIndex = UI_IIS;
    switch( Sender.ID )
    {
    case 'SoloGame':
        Owner.OpenMenu(PC.StartMenuClass);
        break;
    case 'MultiplayerGame':
        Owner.OpenMenu(PC.ServerBrowserClass);
        break;
    case 'Gear':
        UIIndex = UI_Gear;
        break;
    case 'Settings':
        UIIndex = UI_OptionsSelection;
        break;
    case 'Perks':
        UIIndex = UI_Perks;
        break;
    case 'Inventory':
        UIIndex = UI_Inventory;
        break;
    case 'Vault':
        UIIndex = UI_Dosh_Vault;
        break;
    case 'Exit':
        Owner.OpenMenu(class'UI_NotifyQuit');
        return;
    case 'DailyInfo':
        Owner.OpenMenu(class'UIR_DailyInfo');
        return;    
    case 'SeasonalInfo':
        Owner.OpenMenu(class'UIR_SeasonalInfo');
        return;
    }
    
    if( UIIndex != UI_IIS )
    {
        PC.MyGFxManager.OpenMenu(UIIndex);
        Owner.OpenMenu(PC.FlashUIClass);
    }
    
    DoClose();
}

function UserPressedEsc();

defaultproperties
{
    bNoBackground=true
    
    Begin Object class=KFGUI_Button Name=DailyInfo
        ID="DailyInfo"
        XSize=0.275
        YSize=0.025
        XPosition=0.375
        YPosition=0.8225
        FontScale=2
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(DailyInfo)       
    
    Begin Object class=KFGUI_Button Name=SeasonalInfo
        ID="SeasonalInfo"
        XSize=0.275
        YSize=0.025
        XPosition=0.375
        YPosition=0.795
        FontScale=2
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(SeasonalInfo)   
    
    Begin Object Class=UIR_WeeklyInfo Name=WeeklyFrame
        XSize=0.275
        YSize=0.15
        XPosition=0.375
        YPosition=0.85
        ID="WeeklyFrame"
    End Object
    Components.Add(WeeklyFrame)    
    
    Begin Object Class=KFGUI_List Name=MenuParty
        XSize=0.3
        YSize=0.25
        XPosition=0.725
        YPosition=0.25
        ID="MenuParty"
        ListItemsPerPage=6
    End Object
    Components.Add(MenuParty)
    
    Begin Object class=KFGUI_Image Name=KFLogo
        ID="KFLogo"
        YPosition=0.025
        XPosition=0.03
        XSize=0.5
        YSize=0.45
        bAlignCenter=true
        Image=Texture2D'KFClassicMenu_Assets.KFStart'
    End Object
    Components.Add(KFLogo)
    
    Begin Object class=KFGUI_Button Name=SoloGame
        ID="SoloGame"
        YPosition=0.35
        XPosition=0.05
        XSize=0.15
        YSize=0.035
        FontScale=2
        ToolTip="Solo Game"
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(SoloGame)   
    
    Begin Object class=KFGUI_Button Name=MultiplayerGame
        ID="MultiplayerGame"
        YPosition=0.386
        XPosition=0.05
        XSize=0.15
        YSize=0.035
        FontScale=2
        ToolTip="Opens browser to search for servers."
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(MultiplayerGame)
    
    Begin Object class=KFGUI_Button Name=Gear
        ID="Gear"
        YPosition=0.458
        XPosition=0.05
        XSize=0.15
        YSize=0.035
        FontScale=2
        ToolTip="Opens the Gear menu."
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(Gear)
    
    Begin Object class=KFGUI_Button Name=Perks
        ID="Perks"
        YPosition=0.494
        XPosition=0.05
        XSize=0.15
        YSize=0.035
        FontScale=2
        ToolTip="Opens the Perks menu."
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(Perks)
    
    Begin Object class=KFGUI_Button Name=Settings
        ID="Settings"
        YPosition=0.53
        XPosition=0.05
        XSize=0.15
        YSize=0.035
        FontScale=2
        ToolTip="Opens the Settings menu."
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(Settings)
    
    Begin Object class=KFGUI_Button Name=Inventory
        ID="Inventory"
        YPosition=0.602
        XPosition=0.05
        XSize=0.15
        YSize=0.035
        FontScale=2
        ToolTip="Opens the Inventory menu."
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(Inventory)
    
    Begin Object class=KFGUI_Button Name=Vault
        ID="Vault"
        YPosition=0.638
        XPosition=0.05
        XSize=0.15
        YSize=0.035
        FontScale=2
        ToolTip="Opens the Dosh Vault menu."
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(Vault)
    
    Begin Object class=KFGUI_Button Name=Exit
        ID="Exit"
        YPosition=0.71
        XPosition=0.05
        XSize=0.15
        YSize=0.035
        FontScale=2
        ToolTip="Exits the game."
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
        DrawOverride=DrawMenuButtons
        TextColor=(R=255,G=255,B=255,A=255)
    End Object
    Components.Add(Exit)
}