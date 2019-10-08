Class MS_HUD extends HUD
    config(LoadingScreen);

var transient GUIStyleBase GUIStyle;
var transient Texture2D MapIcon, BackgroundImage;

var transient array<string> ProgressLines;
var transient bool bShowProgress,bProgressDC;

var float ScaledBorderSize;

final static function string GetGameInfoName()
{
    local array<string> GamemModeStringArray;

    ParseStringIntoArray(KFGameEngine(Class'Engine'.static.GetEngine()).TransitionGameType, GamemModeStringArray, ".", true);

    if( GamemModeStringArray.Length > 0 )
    {
        if(Caps(GamemModeStringArray[0]) == Caps("KFGameContent"))
        {
            return Localize(GamemModeStringArray[1], "GameName", "KFGameContent" );
        }
        else if( GamemModeStringArray.Length > 1 )
        {
            return GamemModeStringArray[1];
        }
    }
    
    return "Unknown Game";
}

function PostRender()
{
    Super.PostRender();
    
    if( GUIStyle == None )
    {
        GUIStyle = New(None) class'ClassicStyle';
        GUIStyle.PickDefaultFontSize(Canvas.ClipY);
        GUIStyle.InitStyle();
    }
    GUIStyle.Canvas = Canvas;
    
    ScaledBorderSize = FMax(class'KFHUDInterface'.const.HUDBorderSize * ( Canvas.ClipX / 1920.f ), 1.f);
    if( bShowProgress )
        RenderProgress();
}

final function ShowProgressMsg( string S, optional bool bDis )
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

final function RenderProgress()
{
    local float X,Y,XL,YL,Sc,TY,TX,BoxX,BoxW,TextX;
    local int i;
    local Color OutlineColor;
    
    Canvas.Font = GUIStyle.PickFont(Sc);
    Sc += 0.25f;
    
    OutlineColor = MakeColor(235, 0, 0, 195);
    
    if( bProgressDC )
        Canvas.SetDrawColor(255,80,80,255);
    else Canvas.SetDrawColor(255,255,255,255);
    Y = Canvas.ClipY*0.05;

    for( i=0; i<ProgressLines.Length; ++i )
    {
        Canvas.TextSize("<"@ProgressLines[i]@">",XL,YL,Sc,Sc);
        TX = FMax(TX,XL);
    }
    TY = YL*ProgressLines.Length;
    
    X = (Canvas.ClipX/2) - (TX/2);
    
    BoxX = X+(ScaledBorderSize*2);
    BoxW = TX-(ScaledBorderSize*4);
    
    Canvas.DrawColor = MakeColor(15, 15, 15, 195);
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

static final function Texture2D GetMapImage(string MapName)
{
    local KFMapSummary MapData;

    MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName(MapName);
    if ( MapData != None )
        return Texture2D(DynamicLoadObject(MapData.ScreenshotPathName, class'Texture2D'));
    else
    {
        MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName("KF-Default");
        if ( MapData != None )
            return Texture2D(DynamicLoadObject(MapData.ScreenshotPathName, class'Texture2D'));    
    }
    
    return None;
}

defaultproperties
{
}