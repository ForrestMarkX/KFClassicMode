class KFWaitingMessage extends ClassicLocalMessage;

var string WaveInboundMessage,SurvivedMessage,FinalWaveInboundMessage,BossInboundMessage;
var Font CurrentFont;

static function string GetString(
    optional int Switch,
    optional bool bPRI1HUD,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch( Switch )
    {
        case `WM_WAVEINBOUND:
            return default.WaveInboundMessage;
        case `WM_WAVESURVIVED:
            return default.SurvivedMessage;
        case `WM_FINALWAVEINBOUND:
            return default.FinalWaveInboundMessage;
        case `WM_BOSSINBOUND:
            return default.BossInboundMessage;
    }
}

static function int GetFontSize(int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer)
{
    switch( Switch )
    {
        case `WM_WAVEINBOUND:
        case `WM_WAVESURVIVED:
        case `WM_FINALWAVEINBOUND:
        case `WM_BOSSINBOUND:
            return 4;
        default:
            return default.FontSize;
    }
}

static function float GetPos( int Switch, HUD myHUD )
{
    local float OutPosY;
    
    switch( Switch )
    {
        case `WM_WAVEINBOUND:
        case `WM_FINALWAVEINBOUND:
        case `WM_BOSSINBOUND:
            OutPosY = 0.45;
            break;
        case `WM_WAVESURVIVED:
            OutPosY = 0.4;
            break;
    }
    
    return OutPosY;
}

static function float GetLifeTime(int Switch)
{
    switch( switch )
    {
        case `WM_WAVEINBOUND:
        case `WM_FINALWAVEINBOUND:
        case `WM_BOSSINBOUND:
            return 1;
        case `WM_WAVESURVIVED:
            return 3;
    }
}

static function RenderComplexMessage(
    Canvas Canvas,
    out float XL,
    out float YL,
    optional string MessageString,
    optional int Switch,
    optional Object OptionalObject
    )
{
    local int i, ShadowSize;
    local float TempY, FontScaleX;
    local PlayerController LocalPC;
    local KFHUDInterface HUD;
    
    if( default.CurrentFont == None )
        return;
    
    i = InStr(MessageString, "|");

    TempY = YL;
    FontScaleX = (Canvas.ClipX / 1024.f);
    
    LocalPC = Class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();
    if( LocalPC == None )
        return;
        
    HUD = KFHUDInterface(LocalPC.myHUD);
    if( HUD == None )
        return;
    
    ShadowSize = int(Canvas.ClipY / 360.f);
    
    Canvas.Font = default.CurrentFont;
    if ( i < 0 )
    {
        Canvas.TextSize(MessageString, XL, YL, FontScaleX, FontScaleX);
        HUD.GUIStyle.DrawTextShadow(MessageString, (Canvas.ClipX / 2.f) - (XL / 2.f), TempY, ShadowSize, FontScaleX);
    }
    else
    {
        Canvas.TextSize(Left(MessageString, i), XL, YL, FontScaleX, FontScaleX);
        HUD.GUIStyle.DrawTextShadow(Left(MessageString, i), (Canvas.ClipX / 2.f) - (XL / 2.f), TempY, ShadowSize, FontScaleX);

        Canvas.TextSize(Mid(MessageString, i + 1), XL, YL, FontScaleX, FontScaleX);
        HUD.GUIStyle.DrawTextShadow(Mid(MessageString, i + 1), (Canvas.ClipX / 2.f) - (XL / 2.f), TempY + YL, ShadowSize, FontScaleX);
    }
}

defaultproperties
{
    bComplexString=true
    bIsConsoleMessage=false
    DrawColor=(R=255,G=0,B=0,A=255)
    WaveInboundMessage="NEXT WAVE INBOUND!"
    SurvivedMessage="WAVE COMPLETED!|GET TO THE TRADER!"
    FinalWaveInboundMessage="FINAL WAVE INBOUND"
    BossInboundMessage="BOSS INBOUND!!"
    FontSize=5
}
