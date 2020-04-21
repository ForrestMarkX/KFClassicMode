class KFScoreBoard extends KFGUI_Page;

var transient float PerkXPos, PlayerXPos, StateXPos, TimeXPos, HealXPos, KillsXPos, AssistXPos, CashXPos, DeathXPos, PingXPos;
var transient float NextScoreboardRefresh;

var int PlayerIndex;
var KFGUI_List PlayersList;
var Texture2D DefaultAvatar;

var KFGameReplicationInfo KFGRI;
var array<KFPlayerReplicationInfo> KFPRIArray;

var KFPlayerController OwnerPC;

var Color PingColor;
var int IdealPing,MaxPing,PingBars;

function InitMenu()
{
    Super.InitMenu();
    PlayersList = KFGUI_List(FindComponentID('PlayerList'));
    OwnerPC = KFPlayerController(GetPlayer());
}

static function CheckAvatar(KFPlayerReplicationInfo KFPRI, KFPlayerController PC)
{
    local Texture2D Avatar;
    
    if( KFPRI.Avatar == None || KFPRI.Avatar == default.DefaultAvatar )
    {
        Avatar = FindAvatar(PC, KFPRI.UniqueId);
        if( Avatar == None )
            Avatar = default.DefaultAvatar;
            
        KFPRI.Avatar = Avatar;
    }
}

delegate bool InOrder( KFPlayerReplicationInfo P1, KFPlayerReplicationInfo P2 )
{
    if( P1 == None || P2 == None )
        return true;
        
    if( P1.GetTeamNum() < P2.GetTeamNum() )
        return false;
        
    if( P1.Kills == P2.Kills )
    {
        if( P1.Assists == P2.Assists )
            return true;
            
        return P1.Assists < P2.Assists;
    }
        
    return P1.Kills < P2.Kills;
}

function DrawMenu()
{
    local string S;
    local PlayerController PC;
    local KFPlayerReplicationInfo KFPRI;
    local PlayerReplicationInfo PRI;
    local float XPos, YPos, YL, XL, FontScalar, XPosCenter, DefFontHeight, BoxW;
    local int i, j, NumSpec, NumPlayer, NumAlivePlayer, Width;

    PC = GetPlayer();
    if( KFGRI==None )
    {
        KFGRI = KFGameReplicationInfo(PC.WorldInfo.GRI);
        if( KFGRI==None )
            return;
    }
    
    // Sort player list.
    if( NextScoreboardRefresh < PC.WorldInfo.TimeSeconds )
    {
        NextScoreboardRefresh = PC.WorldInfo.TimeSeconds + 0.1;
        
        for( i=(KFGRI.PRIArray.Length-1); i>0; --i )
        {
            for( j=i-1; j>=0; --j )
            {
                if( !InOrder(KFPlayerReplicationInfo(KFGRI.PRIArray[i]),KFPlayerReplicationInfo(KFGRI.PRIArray[j])) )
                {
                    PRI = KFGRI.PRIArray[i];
                    KFGRI.PRIArray[i] = KFGRI.PRIArray[j];
                    KFGRI.PRIArray[j] = PRI;
                }
            }
        }
    }

    // Check players.
    PlayerIndex = -1;
    NumPlayer = 0;
    for( i=(KFGRI.PRIArray.Length-1); i>=0; --i )
    {
        KFPRI = KFPlayerReplicationInfo(KFGRI.PRIArray[i]);
        if( KFPRI==None )
            continue;
        if( KFPRI.bOnlySpectator )
        {
            ++NumSpec;
            continue;
        }
        if( KFPRI.PlayerHealth>0 && KFPRI.PlayerHealthPercent>0 && KFPRI.GetTeamNum()==0 )
            ++NumAlivePlayer;
        ++NumPlayer;
    }
    
    KFPRIArray.Length = NumPlayer;
    j = KFPRIArray.Length;
    for( i=(KFGRI.PRIArray.Length-1); i>=0; --i )
    {
        KFPRI = KFPlayerReplicationInfo(KFGRI.PRIArray[i]);
        if( KFPRI!=None && !KFPRI.bOnlySpectator )
        {
            KFPRIArray[--j] = KFPRI;
            if( KFPRI==PC.PlayerReplicationInfo )
                PlayerIndex = j;
        }
    }

    // Header font info.
    Canvas.Font = Owner.CurrentStyle.PickFont(FontScalar);
    YL = Owner.CurrentStyle.DefaultHeight;
    DefFontHeight = YL;

    XPosCenter = (Canvas.ClipX * 0.5);
    
    if( !Owner.HUDOwner.bModernScoreboard )
        Canvas.SetDrawColor(255, 0, 0, 255);
    
    // Server Name
    
    XPos = XPosCenter;
    YPos += DefFontHeight;
    
    S = KFGRI.ServerName;
    if( Owner.HUDOwner.bModernScoreboard )
    {
        Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
        
        BoxW = XL + (Owner.HUDOwner.ScaledBorderSize*4);
        Canvas.SetDrawColor(10, 10, 10, 200);
        Owner.CurrentStyle.DrawRectBox(XPos - (BoxW * 0.5), YPos, BoxW, YL, 4);
        Canvas.SetDrawColor(250, 0, 0, 255);
    }
    
    Owner.CurrentStyle.DrawCenteredText(S, XPos, YPos, FontScalar,, true);

    // Deficulty | Wave | MapName

    XPos = XPosCenter;
    YPos += DefFontHeight;

    S = " " $Class'KFCommon_LocalizedStrings'.Static.GetDifficultyString (KFGRI.GameDifficulty) $"  |  "$class'KFGFxHUD_ScoreboardMapInfoContainer'.default.WaveString@KFGRI.WaveNum $"  |  " $class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(PC.WorldInfo.GetMapName(true));
    if( Owner.HUDOwner.bModernScoreboard )
    {
        Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
        
        BoxW = XL + (Owner.HUDOwner.ScaledBorderSize*4);
        Canvas.SetDrawColor(10, 10, 10, 200);
        Owner.CurrentStyle.DrawRectBox(XPos - (BoxW * 0.5), YPos, BoxW, YL, 4);
        Canvas.SetDrawColor(0, 250, 0, 255);
    }
    
    Owner.CurrentStyle.DrawCenteredText(S, XPos, YPos, FontScalar,, true);
    
    // Players | Spectators | Alive | Time

    XPos = XPosCenter;
    YPos += DefFontHeight;
    
    S = " Players : " $ NumPlayer $ "  |  Spectators : " $ NumSpec $ "  |  Alive : " $ NumAlivePlayer $ "  |  Elapsed Time : " $ Owner.CurrentStyle.GetTimeString(KFGRI.ElapsedTime) $ " ";
    if( Owner.HUDOwner.bModernScoreboard )
    {
        Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
        
        BoxW = XL + (Owner.HUDOwner.ScaledBorderSize*4);
        Canvas.SetDrawColor(10, 10, 10, 200);
        Owner.CurrentStyle.DrawRectBox(XPos - (BoxW * 0.5), YPos, BoxW, YL, 4);
        Canvas.SetDrawColor(250, 250, 0, 255);
    }
    
    Owner.CurrentStyle.DrawCenteredText(S, XPos, YPos, FontScalar,, true);
    
    Width = Canvas.ClipX * 0.625;

    XPos = (Canvas.ClipX - Width) * 0.5;
    YPos += DefFontHeight * 2.0;
    
    if( Owner.HUDOwner.bModernScoreboard )
    {
        Canvas.SetDrawColor (10, 10, 10, 200);
        Owner.CurrentStyle.DrawRectBox(XPos, YPos, Width, DefFontHeight, 4);
    }

    Canvas.SetDrawColor(250, 250, 250, 255);

    // Calc X offsets
    PerkXPos = Width * 0.01;
    PlayerXPos = Width * 0.175;
    KillsXPos = Width * 0.5;
    AssistXPos = Width * 0.6;
    CashXPos = Width * 0.7;
    StateXPos = Width * 0.8;
    PingXPos = Width * 0.92;

    // Header texts
    Canvas.SetPos (XPos + PerkXPos, YPos);
    Canvas.DrawText (class'KFGFxMenu_Inventory'.default.PerkFilterString, , FontScalar, FontScalar);

    Canvas.SetPos (XPos + KillsXPos, YPos);
    Canvas.DrawText (class'KFGFxHUD_ScoreboardWidget'.default.KillsString, , FontScalar, FontScalar);

    Canvas.SetPos (XPos + AssistXPos, YPos);
    Canvas.DrawText (class'KFGFxHUD_ScoreboardWidget'.default.AssistsString, , FontScalar, FontScalar);

    Canvas.SetPos (XPos + CashXPos, YPos);
    Canvas.DrawText (class'KFGFxHUD_ScoreboardWidget'.default.DoshString, , FontScalar, FontScalar);

    Canvas.SetPos (XPos + StateXPos, YPos);
    Canvas.DrawText ("STATE", , FontScalar, FontScalar);
    
    Canvas.SetPos (XPos + PlayerXPos, YPos);
    Canvas.DrawText (class'KFGFxHUD_ScoreboardWidget'.default.PlayerString, , FontScalar, FontScalar);

    Canvas.SetPos (XPos + PingXPos, YPos);
    Canvas.DrawText (class'KFGFxHUD_ScoreboardWidget'.default.PingString, , FontScalar, FontScalar);

    PlayersList.XPosition = ((Canvas.ClipX - Width) * 0.5) / InputPos[2];
    PlayersList.YPosition = (YPos + (YL + 4)) / InputPos[3];
    PlayersList.YSize = (1.f - PlayersList.YPosition) - 0.15;
    
    PlayersList.ChangeListSize(KFPRIArray.Length);
}

function DrawPlayerEntry( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local string S, StrValue;
    local float FontScalar, TextYOffset, XL, YL;
    local KFPlayerReplicationInfo KFPRI;
    local Texture2D PerkIcon, PerkStarIcon;
    local byte PerkLevel;
    local bool bIsZED;
    local int Ping;
    
    YOffset *= 1.05;
    KFPRI = KFPRIArray[Index];
    
    if( KFGRI.bVersusGame )
        bIsZED = KFTeamInfo_Zeds(KFPRI.Team) != None;
    
    C.Font = Owner.CurrentStyle.PickFont(FontScalar);
    
    TextYOffset = YOffset + (Height / 2) - (Owner.CurrentStyle.DefaultHeight / 2);
    if( Owner.HUDOwner.bModernScoreboard )
    {
        if (PlayerIndex == Index)
            C.SetDrawColor (51, 30, 101, 150);
        else C.SetDrawColor (30, 30, 30, 150);
        
        Owner.CurrentStyle.DrawRectBox(0.f, YOffset, Width, Height, 4);
    }
    else Owner.CurrentStyle.DrawOutlinedBox(0.f,YOffset,Width,Height,Owner.HUDOwner.ScaledBorderSize,PlayerIndex == Index ? MakeColor(51, 30, 101, 150) : MakeColor(30, 30, 30, 150),KFGRI.bVersusGame ? (KFPRI.GetTeamNum() == 0 ? MakeColor(200, 0, 0, 200) : MakeColor(0, 71, 200, 200)) : MakeColor(120, 120, 0, 200));
    
    C.SetDrawColor(250,250,250,255);

    // Perk
    if( bIsZED )
    {
        C.SetDrawColor(255,0,0,255);
        C.SetPos (PerkXPos, YOffset - ((Height-5) / 2));
        C.DrawRect (Height-5, Height-5, Texture2D'UI_Widgets.MenuBarWidget_SWF_IF');
        
        S = "ZED";
        C.SetPos (PerkXPos + Height, TextYOffset);
        C.DrawText (S, , FontScalar, FontScalar);
    }
    else
    {
        if( KFPRI.CurrentPerkClass!=None )
        {
            PerkLevel = class<ClassicPerk_Base>(KFPRI.CurrentPerkClass).static.PreDrawPerk(C, KFPRI.GetActivePerkLevel(), PerkIcon, PerkStarIcon);
            DrawPerkWithStars(C,PerkXPos,YOffset+(Owner.HUDOwner.ScaledBorderSize * 2),Height-(Owner.HUDOwner.ScaledBorderSize * 4),PerkLevel,PerkIcon,PerkStarIcon);
        }
        else
        {
            C.SetDrawColor(250,250,250,255);
            S = "No Perk";
            C.SetPos (PerkXPos + Height, TextYOffset);
            C.DrawText (S, , FontScalar, FontScalar);
        }
    }
    
    // Avatar
    if( KFPRI.Avatar != None )
    {
        if( KFPRI.Avatar == default.DefaultAvatar )
            CheckAvatar(KFPRI, OwnerPC);
            
        C.SetDrawColor(255,255,255,255);
        C.SetPos(PlayerXPos - (Height * 1.075), YOffset + (Height / 2) - ((Height - 6) / 2));
        C.DrawTile(KFPRI.Avatar,Height - 6,Height - 6,0,0,KFPRI.Avatar.SizeX,KFPRI.Avatar.SizeY);
        Owner.CurrentStyle.DrawBoxHollow(PlayerXPos - (Height * 1.075), YOffset + (Height / 2) - ((Height - 6) / 2), Height - 6, Height - 6, 1);
    } 
    else if( !KFPRI.bBot )
        CheckAvatar(KFPRI, OwnerPC);

    // Player
    C.SetPos (PlayerXPos, TextYOffset);
    
    if( Len(KFPRI.PlayerName) > 25 )
        S = Left(KFPRI.PlayerName, 25);
    else S = KFPRI.PlayerName;
    C.DrawText (S, , FontScalar, FontScalar);
    
    C.SetDrawColor(255,255,255,255);

    // Kill
    C.SetPos (KillsXPos, TextYOffset);
    C.DrawText (string (KFPRI.Kills), , FontScalar, FontScalar);

    // Assist
    C.SetPos (AssistXPos, TextYOffset);
    C.DrawText (string (KFPRI.Assists), , FontScalar, FontScalar);

    // Cash
    C.SetPos (CashXPos, TextYOffset);
    if( bIsZED )
    {
        C.SetDrawColor(250, 0, 0, 255);
        StrValue = "Brains!";
    }
    else
    {
        C.SetDrawColor(250, 250, 100, 255);
        StrValue = Chr(208)$Owner.CurrentStyle.FormatInteger(int(KFPRI.Score));
    }
    C.DrawText (StrValue, , FontScalar, FontScalar);
    
    C.SetDrawColor(255,255,255,255);

    // State
    if( !KFPRI.bReadyToPlay && KFGRI.bMatchHasBegun )
    {
        C.SetDrawColor(250,0,0,255);
        S = "LOBBY";
    }
    else if( !KFGRI.bMatchHasBegun )
    {
        C.SetDrawColor(250,0,0,255);
        S = KFPRI.bReadyToPlay ? "Ready" : "Not Ready";    
    }
    else if( bIsZED && KFTeamInfo_Zeds(GetPlayer().PlayerReplicationInfo.Team) == None )
    {
        C.SetDrawColor(250,0,0,255);
        S = "Unknown";
    }
    else if (KFPRI.PlayerHealth <= 0 || KFPRI.PlayerHealthPercent <= 0)
    {
        C.SetDrawColor(250,0,0,255);
        S = (KFPRI.bOnlySpectator) ? "Spectator" : "DEAD";
    }
    else
    {
        if (ByteToFloat(KFPRI.PlayerHealthPercent) >= 0.8)
            C.SetDrawColor(0,250,0,255);
        else if (ByteToFloat(KFPRI.PlayerHealthPercent) >= 0.4)
            C.SetDrawColor(250,250,0,255);
        else C.SetDrawColor(250,100,100,255);
        
        S =  string (KFPRI.PlayerHealth) @"HP";
    }

    C.SetPos (StateXPos, TextYOffset);
    C.DrawText (S, , FontScalar, FontScalar);
    
    C.SetDrawColor(250,250,250,255);

    // Ping
    if (KFPRI.bBot)
        S = "-";
    else
    {
        Ping = Clamp(int(KFPRI.Ping * `PING_SCALE), 1, MaxPing);
        
        if (Ping <= 100)
            C.SetDrawColor(0,250,0,255);
        else if (Ping <= 200)
            C.SetDrawColor(250,250,0,255);
        else C.SetDrawColor(250,100,100,255);
        
        S = string(Ping);
    }
        
    if( Owner.HUDOwner.bModernScoreboard )
    {
        C.TextSize(MaxPing, XL, YL, FontScalar, FontScalar);
        
        C.SetPos(PingXPos, TextYOffset);
        C.DrawText(S,, FontScalar, FontScalar);
        
        DrawPingBars(C, YOffset + (Height/2) - ((Height*0.5)/2), PingXPos+XL, Height*0.5, Height*0.5, Ping);
    }
    else
    {
        C.SetPos (PingXPos, TextYOffset);
        C.DrawText (S, , FontScalar, FontScalar);
    }
}

final function DrawPingBars( Canvas C, float YOffset, float XOffset, float W, float H, int Ping )
{
    local float PingMul, BarW, BarH, BaseH, XPos, YPos;
    local byte i;
    
    PingMul = 1.f - FClamp(Max(Ping - IdealPing, 1) / MaxPing, 0.f, 1.f);
    BarW = W / PingBars;
    BaseH = H / PingBars;

    PingColor.R = (1.f - PingMul) * 255;
    PingColor.G = PingMul * 255;

    for(i=1; i<PingBars+1; i++)
    {
        BarH = BaseH * i;
        XPos = XOffset + ((i - 1) * BarW);
        YPos = YOffset + (H - BarH);

        C.SetPos(XPos,YPos);
        C.SetDrawColor(20, 20, 20, 255);
        Owner.CurrentStyle.DrawWhiteBox(BarW,BarH);

        if( i == 1 || PingMul >= i / PingBars )
        {
            C.SetPos(XPos,YPos);
            C.DrawColor = PingColor;
            Owner.CurrentStyle.DrawWhiteBox(BarW,BarH);
        }

        C.SetDrawColor(80, 80, 80, 255);
        Owner.CurrentStyle.DrawBoxHollow(XPos,YPos,BarW,BarH,1);
    }
}

final function DrawPerkWithStars( Canvas C, float X, float Y, float Scale, int Stars, Texture PerkIcon, Texture StarIcon )
{
    local byte i;

    C.SetPos(X,Y);
    C.DrawTile(PerkIcon, Scale, Scale, 0, 0, PerkIcon.GetSurfaceWidth(), PerkIcon.GetSurfaceHeight());
    
    if( Stars==0 || StarIcon==None )
        return;
        
    Y+=Scale*0.9f;
    X+=(Scale*0.8f)+(Owner.HUDOwner.ScaledBorderSize*2);
    Scale*=0.2f;
    
    while( Stars>0 )
    {
        if( (X+Scale) >= PlayerXPos )
            break;
        
        for( i=1; i<=Min(5,Stars); ++i )
        {
            C.SetPos(X,Y-(i*Scale*0.8f));
            C.DrawTile(StarIcon, Scale, Scale, 0, 0, StarIcon.GetSurfaceWidth(), StarIcon.GetSurfaceHeight());
        }
        
        X+=Scale+Owner.HUDOwner.ScaledBorderSize;
        Stars-=5;
    }
}

static final function Texture2D FindAvatar( KFPlayerController PC, UniqueNetId ClientID )
{
    local string S;
    
    S = PC.GetSteamAvatar(ClientID);
    if( S=="" )
        return None;
    return Texture2D(PC.FindObject(S,class'Texture2D'));
}

final static function string GetNiceSize(int Num)
{
    if( Num < 1000 ) return string(Num);
    else if( Num < 1000000 ) return (Num / 1000) $ "K";
    else if( Num < 1000000000 ) return (Num / 1000000) $ "M";

    return (Num / 1000000000) $ "B";
}

function ScrollMouseWheel( bool bUp )
{
    PlayersList.ScrollMouseWheel(bUp);
}

defaultproperties
{
    bEnableInputs=true
    
    PingColor=(R=255,G=255,B=60,A=255)
    IdealPing=50
    MaxPing=1024
    PingBars=4
    
    Begin Object Class=KFGUI_List Name=PlayerList
        XSize=0.625
        OnDrawItem=DrawPlayerEntry
        ID="PlayerList"
        bClickable=false
        ListItemsPerPage=16
    End Object
    Components.Add(PlayerList)
    
    DefaultAvatar=Texture2D'UI_HUD.ScoreBoard_Standard_SWF_I26'
}