class MenuInterface extends KFHUDInterface;

var transient Texture2D MapIcon, BackgroundImage;
var MenuPlayerController MenuPlayerOwner;

var class<KFGUI_TextField> MapDescriptionClass;
var KFGUI_TextField MapDescriptionBox;

var config array<string> LoadingBackgrounds;

simulated function PostBeginPlay()
{
    local bool bSaveConfig;
    
    Super.PostBeginPlay();
    
    MenuPlayerOwner = MenuPlayerController(PlayerOwner);
    
    if( iConfigVersion <= 2 )
    {
        LoadingBackgrounds.AddItem("KFClassicMenu_Assets.LoadingScreen1");
        LoadingBackgrounds.AddItem("KFClassicMenu_Assets.LoadingScreen2");
        LoadingBackgrounds.AddItem("KFClassicMenu_Assets.LoadingScreen3");
        LoadingBackgrounds.AddItem("KFClassicMenu_Assets.LoadingScreen4");
        LoadingBackgrounds.AddItem("KFClassicMenu_Assets.LoadingScreen5");
        
        iConfigVersion++;
        bSaveConfig = true;
    }
    
    if( bSaveConfig )
        SaveConfig();
}

function LaunchHUDMenus()
{
    Super.LaunchHUDMenus();
    
    MapDescriptionBox = KFGUI_TextField(GUIController.InitializeHUDWidget(MapDescriptionClass));
    MapDescriptionBox.SetVisibility(false);
}

function PostRender()
{
    local float RatioW, MapYL, MapX, XL, YL, OriginalSc, Sc;
    local string S, MapName, Author;
    
    if( MenuPlayerOwner.bPendingTravel )
    {
        if( MapIcon == None )
            MapIcon = GetMapImage(MenuPlayerController(PlayerOwner).TransitionMap);
        if( BackgroundImage == None && LoadingBackgrounds.Length > 0 )
            BackgroundImage = Texture2D(DynamicLoadObject(LoadingBackgrounds[Rand(LoadingBackgrounds.Length)], class'Texture2D'));
        
        if( BackgroundImage != None )
        {
            Canvas.SetPos(0.f, -1.f);
            Canvas.DrawColor = WhiteColor;
            Canvas.DrawTile(BackgroundImage, Canvas.ClipX, Canvas.ClipY+1, 0, 0, 1024, 768);
        }
        
        if( MapIcon != None )
        {
            MapName = MenuPlayerOwner.TransitionMap;
            Author = GetMapAuthor(MapName);
            
            MapYL = Canvas.ClipY * 0.375;
            RatioW = MapIcon.GetSurfaceWidth() / (MapIcon.GetSurfaceHeight() / MapYL);
            
            MapX = Canvas.ClipX - RatioW - (ScaledBorderSize * 2);
            Canvas.SetPos(MapX, ScaledBorderSize * 2);
            Canvas.DrawColor = WhiteColor;
            Canvas.DrawRect(RatioW, MapYL, MapIcon);
            
            Canvas.Font = GUIStyle.PickFont(OriginalSc);
            Sc = OriginalSc+0.25f;
            
            S = GetMapName(MapName);
            if( Author != "" )
                S @= "by"@Author;
                
            Canvas.DrawColor = WhiteColor;
            Canvas.TextSize(S,XL,YL,Sc,Sc);
            Canvas.SetPos(MapX + (RatioW/2) - (XL/2), MapYL + (ScaledBorderSize * 2));
            Canvas.DrawText(S,,Sc,Sc);
            
            S = Class'KFCommon_LocalizedStrings'.default.LoadingString;
            Canvas.DrawColor = WhiteColor;
            Canvas.TextSize(S,XL,YL,Sc,Sc);
            Canvas.SetPos(ScaledBorderSize * 4, YL + (ScaledBorderSize * 2));
            Canvas.DrawText(S,,Sc,Sc);
            
            S = MenuPlayerOwner.TransitionGame;
            Canvas.DrawColor = WhiteColor;
            Canvas.TextSize(S,XL,YL,Sc,Sc);
            Canvas.SetPos(ScaledBorderSize * 4, (YL * 2) + (ScaledBorderSize * 2));
            Canvas.DrawText(S,,Sc,Sc);
        }
        
        if( bShowProgress )
            RenderProgress();
    }
        
    Super.PostRender();
}

function RenderProgress()
{
    local float X,Y,XL,YL,Sc,TY,TX,BoxX,BoxW,TextX;
    local int i;
    local Color OutlineColor;
    
    Canvas.Font = GUIStyle.PickFont(Sc);
    Sc += 0.25f;
    
    OutlineColor = MakeColor(235, 0, 0, 255);
    
    if( bProgressDC )
        Canvas.SetDrawColor(255,80,80,255);
    else Canvas.SetDrawColor(255,255,255,255);
    
    for( i=0; i<ProgressLines.Length; ++i )
    {
        Canvas.TextSize("<"@ProgressLines[i]@">",XL,YL,Sc,Sc);
        TX = FMax(TX,XL);
    }
    TY = YL*ProgressLines.Length;
    
    Y = Canvas.ClipY - (TY * 1.25f);
    X = (Canvas.ClipX/2) - (TX/2);
    
    BoxX = X+(ScaledBorderSize*2);
    BoxW = TX-(ScaledBorderSize*4);
    
    Canvas.SetDrawColor(5, 5, 5, 255);
    Canvas.SetPos(BoxX, Y);
    GUIStyle.DrawWhiteBox(BoxW, TY);
    
    GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, X, Y, ScaledBorderSize*2, TY, OutlineColor, true, false, true, false);
    GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, X+TX-(ScaledBorderSize*2), Y, ScaledBorderSize*2, TY, OutlineColor, false, true, false, true);

    Canvas.DrawColor = WhiteColor;
    for( i=0; i<ProgressLines.Length; ++i )
    {
        Canvas.TextSize(ProgressLines[i],XL,YL,Sc,Sc);
        
        TextX = BoxX + (BoxW/2) - (XL/2);
        
        GUIStyle.DrawTextShadow(ProgressLines[i], TextX, Y, 1, Sc);
        Y+=YL;
    }
    Canvas.SetPos(Canvas.ClipX*0.2,Canvas.ClipY*0.91);
}

function ShowProgressMsg( string S, optional bool bDis )
{
    if( S=="" )
    {
        bShowProgress = false;
        return;
    }
    bShowProgress = true;
    ParseStringIntoArray(S,ProgressLines,"|",false);
    bProgressDC = bDis;
    if( !bDis )
        ProgressLines.AddItem("Press [Esc] to cancel connection");
}

final function Texture2D GetMapImage(string MapName)
{
    local int i;
    
    for (i = 0; i < MenuPlayerOwner.MapImages.Length; i++)
    {
        if( MenuPlayerOwner.MapImages[i].MapName ~= MapName )
            return MenuPlayerOwner.MapImages[i].Image;
    }
    
    return class'MS_HUD'.static.GetMapImage(MapName);
}

final function string GetMapName(string Map)
{
    local string S;
    
    S = Localize("MapInfo", "DisplayName", Map);
    if( InStr(S, "MapInfo.DisplayName?") == INDEX_NONE )
        return S;
    
    return Map;
}

final function string GetMapAuthor(string Map)
{
    local string S;
    
    S = Localize("MapInfo", "Author", Map);
    if( InStr(S, "MapInfo.Author?") == INDEX_NONE )
        return S;
    
    return "";
}

final function string GetMapDescription(string Map)
{
    local string S;
    
    S = Localize("MapInfo", "Description", Map);
    if( InStr(S, "MapInfo.Description?") == INDEX_NONE )
        return S;
    
    return "";
}

function DrawHUD();

defaultproperties
{
    MapDescriptionClass=class'UIR_MapDescription'
}