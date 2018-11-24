class KFHUDInterface extends KFGFxHudWrapper
    config(ClassicHUD);
    
const HUDBorderSize = 3;
const MAX_WEAPON_GROUPS = 4;

enum EVoteTypes
{
    VT_TYPE_NONE,
    VT_TYPE_KICK,
    VT_TYPE_MUTE,
    VT_TYPE_SKIPTRADER,
    VT_TYPE_BAN
};

enum EJustificationType
{
    HUDA_None,
    HUDA_Right,
    HUDA_Left,
    HUDA_Top,
    HUDA_Bottom
};

struct InventoryCategory
{
    var    array<KFWeapon>    Items;
    var    int ItemCount;
};
var int MinWeaponIndex[MAX_WEAPON_GROUPS], MaxWeaponIndex[MAX_WEAPON_GROUPS];
var int MaxWeaponsPerCatagory;

struct WeaponInfoS
{
    var Weapon Weapon;
    var string WeaponName;
};
var transient WeaponInfoS CachedWeaponInfo;

struct FNewItemEntry
{
    var Texture2D Icon;
    var string Item;
    var float MsgTime;
};
var transient array<FNewItemEntry> NewItems;
var transient array<byte> WasNewlyAdded;
var transient OnlineSubsystem OnlineSub;
var transient bool bLoadedInitItems;

struct VotingInfoS
{
    var PlayerReplicationInfo PRI;
    var int VoteDuration;
    var bool bShowChoices;
    var int YesVotes, NoVotes;
};
var transient VotingInfoS ActiveVote;
var transient string CurrentVoteName, CurrentVoteStatus;
var transient bool bVoteActive;

struct FKillMessageType
{
    var bool bDamage,bLocal;
    var int Counter;
    var Class Type;
    var string Name;
    var PlayerReplicationInfo OwnerPRI;
    var float MsgTime;
    var color MsgColor;
};
var transient array<FKillMessageType> KillMessages;

var transient ClientPerkRepLink ClientRep;
var transient array<PlayerReplicationInfo> TalkerPRIs;

var config int HealthBarFullVisDist, HealthBarCutoffDist;
var int PerkIconSize;
var config int MaxPerkStars, MaxStarsPerRow;
var config bool bLightHUD, bHideWeaponInfo, bHidePlayerInfo, bHideDosh;
var float ScaledBorderSize;
var int PlayerScore, OldPlayerScore;
var float TimeX, FrameTime;
var transient bool bChatOpen;
var transient bool bInterpolating, bDisplayingProgress, bNeedsRepLinkUpdate, bConfirmDisconnect, bObjectReplicationFinished;
var transient float LevelProgressBar, VisualProgressBar;
var transient KF2GUIController GUIController;
var transient GUIStyleBase GUIStyle;
var array<KFGUI_Base> HUDWidgets;
var config Color HudMainColor, HudOutlineColor, FontColor;
var Color DefaultHudMainColor, DefaultHudOutlineColor, DefaultFontColor;
var Texture HealthIcon, ArmorIcon, WeightIcon, GrenadesIcon, DoshIcon, ClipsIcon, BulletsIcon, BurstBulletIcon, AutoTargetIcon, ProgressBarTex, DoorWelderBG;
var Texture WaveCircle, BioCircle;
var Texture ArrowIcon, FlameIcon, FlameTankIcon, FlashlightIcon, FlashlightOffIcon, RocketIcon, BoltIcon, M79Icon, PipebombIcon, SingleBulletIcon, SyringIcon, SawbladeIcon, DoorWelderIcon;
var Texture TraderBox, TraderArrow;
var Texture VoiceChatIcon;

var    bool bDisplayInventory;
var    float InventoryFadeTime, InventoryFadeStartTime, InventoryFadeInTime, InventoryFadeOutTime, InventoryX, InventoryY, InventoryBoxWidth, InventoryBoxHeight, BorderSize;
var    Texture    InventoryBackgroundTexture, SelectedInventoryBackgroundTexture;
var    int    SelectedInventoryCategory, SelectedInventoryIndex;
var    KFWeapon SelectedInventory;

var Texture VictoryScreen, DefeatScreen, VictoryScreenOverlay, DefeatScreenOverlay;
var transient bool bVictory, bCheckedForWin;

var class<UI_MainChatBox> ChatBoxClass;
var UI_MainChatBox ChatBox;

var class<UIR_SpectatorInfoBox> SpectatorInfoClass;
var UIR_SpectatorInfoBox SpectatorInfo;

var class<KFScoreBoard> ScoreboardClass;
var KFScoreBoard Scoreboard;

var int MaxNonCriticalMessages;
var float NonCriticalMessageDisplayTime,NonCriticalMessageFadeInTime,NonCriticalMessageFadeOutTime;

struct FCritialMessage
{
    var string Text, Delimiter;
    var float StartTime;
};
var transient array<FCritialMessage> NonCriticalMessages;

struct FPriorityMessage
{
    var string PrimaryText, SecondaryText;
    var float StartTime, LifeTime;
    
    structdefaultproperties
    {
        PrimaryText="Label"
        SecondaryText="Label"
        LifeTime=5.f
    }
};
var transient FPriorityMessage PriorityMessage;

var bool bDisplayQuickSyringe;
var float QuickSyringeStartTime;
var float QuickSyringeDisplayTime;
var float QuickSyringeFadeInTime;
var float QuickSyringeFadeOutTime;

var bool bDrawingPortrait, bPortraitTimeSet;
var float PortraitTime;
var float PortraitX;
var Texture TraderPortrait, PatriarchPortrait, LockheartPortrait, UnknownPortrait, TraderPortraitBox;

var transient Texture CurrentTraderPortrait;
var transient string CurrentTraderName;

var transient array<string> ProgressLines;
var transient float ProgressMsgTime;
var transient bool bShowProgress,bProgressDC;

struct FDoorCache
{
    var KFDoorActor Door;
    var vector WeldUILocation;
};
var array<FDoorCache> DoorCache;

struct HUDBoxRenderInfo
{
    var int JustificationPadding;
    var Color TextColor;
    var Texture IconTex;
    var float Alpha;
    var float IconScale;
    var array<String> StringArray;
    var bool bUseOutline;
    var EJustificationType Justification;
    
    structdefaultproperties
    {
        TextColor=(R=255,B=255,G=255,A=255)
        Alpha=-1.f
        IconScale=1.f
    }
};

var transient class<KFTraderVoiceGroupBase> CurrentTraderVoiceClass;
var transient byte LastWarningTime;
var config int iConfigVersion;

var ClassicPlayerController ClassicPlayerOwner;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    if( iConfigVersion <= 0 )
    {
        HealthBarFullVisDist = 700.f;
        HealthBarCutoffDist = 2000.f;
        
        MaxPerkStars = 5;
        MaxStarsPerRow = 5;
        
        HudMainColor = DefaultHudMainColor;
        HudOutlineColor = DefaultHudOutlineColor;
        FontColor = DefaultFontColor;
        
        bLightHUD = false;
        bHideWeaponInfo = false;
        bHidePlayerInfo = false;
        bHideDosh = false;
        
        iConfigVersion = 1;
        
        SaveConfig();
    }
    
    ClassicPlayerOwner = ClassicPlayerController(PlayerOwner);
    
    PlayerOwner.PlayerInput.OnReceivedNativeInputKey = NotifyInputKey;
    PlayerOwner.PlayerInput.OnReceivedNativeInputAxis = NotifyInputAxis;
    PlayerOwner.PlayerInput.OnReceivedNativeInputChar = NotifyInputChar;
    
    /*
    OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
    if( OnlineSub!=None )
    {
        OnlineSub.AddOnInventoryReadCompleteDelegate(SearchInventoryForNewItem);
        SetTimer(60,false,'SearchInventoryForNewItem');
    }
    */
    
    //SetTimer(300 + FRand()*120.f, false, 'CheckForItems');
    SetTimer(0.25, true, 'BuildDoorCache');
}

function ResetHUDColors()
{
    HudMainColor = DefaultHudMainColor;
    HudOutlineColor = DefaultHudOutlineColor;
    FontColor = DefaultFontColor;
    SaveConfig();
}

function GetTraderVoiceClass()
{
    local ClassicHumanPawn P;
    
    P = ClassicHumanPawn(PlayerOwner.Pawn);
    if( P != None )
    {
        CurrentTraderVoiceClass = P.GetTraderVoiceGroupClass();
    }
}

function BuildDoorCache()
{
    local KFDoorActor Door;
    local FDoorCache MyCache;
    
    foreach DynamicActors(class'KFDoorActor',Door)
    {
        if( DoorCache.Find('Door', Door) != INDEX_NONE )
            continue;
            
        if( Door.CenterWeldComponent != None )
            Door.CenterWeldComponent = None;
            
        MyCache.Door = Door;
        MyCache.WeldUILocation = Door.WeldUILocation;
        
        DoorCache.AddItem(MyCache);
    }
}

function PostRender()
{
    local KFPawn_Human KFPH;
    
    if( !bObjectReplicationFinished )
    {
        SetupHUDTextures();
        return;
    }
    
    if( GUIController!=None && PlayerOwner.PlayerInput==None )
        GUIController.NotifyLevelChange();
        
    if( GUIController==None || GUIController.bIsInvalid )
    {
        GUIController = Class'KF2GUIController'.Static.GetGUIController(PlayerOwner);
        if( GUIController!=None )
        {
            GUIStyle = GUIController.CurrentStyle;
            LaunchHUDMenus();
        }
    }
    GUIStyle.Canvas = Canvas;
    GUIStyle.PickDefaultFontSize(Canvas.ClipY);
    
    ScaledBorderSize = GUIStyle.ScreenScale(HUDBorderSize);
    
    if( PlayerOwner != None )
    {
        RenderKFHUD(KFPawn_Human(PlayerOwner.Pawn));
    }
    
    if( KillMessages.Length > 0 )
    {
        RenderKillMsg();
    }
    
    /*
    if( NewItems.Length > 0 )
    {
        DrawItemsList();
    }
    */
    
    if( ClassicPlayerOwner.LobbyMenu == None )
    {
        if( TalkerPRIs.Length > 0 )
        {
            DrawVOIPStatus();
        }
        
        if( bVoteActive )
        {
            RenderVotingOptions();
        }
    }
    
    if( HUDWidgets.Length > 0 )
    {
        RenderHUDWidgets();
    }
    
    if( KFGameReplicationInfo(WorldInfo.GRI).bMatchIsOver )
    {
        if( !bCheckedForWin )
        {
            foreach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
            {
                if ( KFPH.IsAliveAndWell() )
                {
                    bVictory = true;
                    break;
                }
            }
            
            bCheckedForWin = true;
        }
        
        if( bVictory )
        {
            DrawVictoryEndScreen();
        }
        else
        {
            DrawDefeatEndScreen();
        }
    }
    
    Super.PostRender();

    DrawDoorHealthBars();
    
    if( bShowProgress || PlayerOwner.Player==None )
    {
        if( ProgressMsgTime<WorldInfo.TimeSeconds )
        {
            bShowProgress = false;
            if( PlayerOwner.Player==None )
            {
                ShowProgressMsg("Downloading contents for next map, please wait...|Press [Escape] key to cancel connection!");
                RenderProgress();
            }
            else if( bProgressDC )
                KFPlayerOwner.ConsoleCommand("Disconnect");
        }
        else RenderProgress();
    }
    if( PlayerOwner.Player==None && class'GameEngine'.static.GetOnlineSubsystem()!=None )
        NotifyLevelChange();
}

function LaunchHUDMenus()
{
    ChatBox = UI_MainChatBox(GUIController.InitializeHUDWidget(ChatBoxClass));
    ChatBox.SetVisible(false);
    
    SpectatorInfo = UIR_SpectatorInfoBox(GUIController.InitializeHUDWidget(SpectatorInfoClass));
    SpectatorInfo.SetSpectatedPRI(PlayerOwner.PlayerReplicationInfo);
}

function SetupHUDTextures()
{
    local ObjectReferencer RepObject;
    
    if( ClientRep == None )
    {
        ClientRep = class'ClientPerkRepLink'.static.FindContentRep( WorldInfo );
        if( ClientRep == None )
        {
            return;
        }
    }
    
    RepObject = ClientRep.ObjRef;
    if( RepObject != None )
    {
        ProgressBarTex = Texture2D(RepObject.ReferencedObjects[85]);
        
        HealthIcon = Texture2D(RepObject.ReferencedObjects[27]);
        ArmorIcon = Texture2D(RepObject.ReferencedObjects[31]);
        WeightIcon = Texture2D(RepObject.ReferencedObjects[34]);
        GrenadesIcon = Texture2D(RepObject.ReferencedObjects[23]);
        DoshIcon = Texture2D(RepObject.ReferencedObjects[30]);
        BulletsIcon = Texture2D(RepObject.ReferencedObjects[17]);
        ClipsIcon = Texture2D(RepObject.ReferencedObjects[11]);
        BurstBulletIcon = Texture2D(RepObject.ReferencedObjects[18]);
        AutoTargetIcon = Texture2D(RepObject.ReferencedObjects[13]);
        
        ArrowIcon = Texture2D(RepObject.ReferencedObjects[12]);
        FlameIcon = Texture2D(RepObject.ReferencedObjects[19]);
        FlameTankIcon = Texture2D(RepObject.ReferencedObjects[20]);
        FlashlightIcon = Texture2D(RepObject.ReferencedObjects[21]);
        FlashlightOffIcon = Texture2D(RepObject.ReferencedObjects[22]);
        RocketIcon = Texture2D(RepObject.ReferencedObjects[24]);
        BoltIcon = Texture2D(RepObject.ReferencedObjects[25]);
        M79Icon = Texture2D(RepObject.ReferencedObjects[26]);
        PipebombIcon = Texture2D(RepObject.ReferencedObjects[29]);
        SingleBulletIcon = Texture2D(RepObject.ReferencedObjects[32]);
        SyringIcon = Texture2D(RepObject.ReferencedObjects[33]);
        SawbladeIcon = Texture2D(RepObject.ReferencedObjects[78]);
        
        TraderBox = Texture2D(RepObject.ReferencedObjects[16]);
        
        WaveCircle = Texture2D(RepObject.ReferencedObjects[15]);
        BioCircle = Texture2D(RepObject.ReferencedObjects[14]);
        
        DoorWelderBG = TraderBox;
        DoorWelderIcon = Texture2D(RepObject.ReferencedObjects[88]);
        
        InventoryBackgroundTexture = Texture2D(RepObject.ReferencedObjects[113]);
        SelectedInventoryBackgroundTexture = Texture2D(RepObject.ReferencedObjects[114]);
        
        TraderPortrait = Texture2D(RepObject.ReferencedObjects[86]);
        PatriarchPortrait = Texture2D(RepObject.ReferencedObjects[58]);
        LockheartPortrait = Texture2D(RepObject.ReferencedObjects[70]);
        UnknownPortrait = Texture2D(RepObject.ReferencedObjects[56]);
        TraderPortraitBox = Texture2D(RepObject.ReferencedObjects[2]);
        
        VictoryScreen = Texture2D(RepObject.ReferencedObjects[115]);
        DefeatScreen = Texture2D(RepObject.ReferencedObjects[117]);
        VictoryScreenOverlay = Texture2D(RepObject.ReferencedObjects[116]);
        DefeatScreenOverlay = Texture2D(RepObject.ReferencedObjects[118]);
        
        bObjectReplicationFinished = true;
    }
}

simulated function CancelConnection()
{
    if( !bConfirmDisconnect )
    {
        ShowProgressMsg("Are you sure you want to cancel connection?|Press [Escape] again to confirm...");
        bConfirmDisconnect = true;
    }
    else class'Engine'.Static.GetEngine().GameViewport.ConsoleCommand("Disconnect");
}

function string GetGameInfoText()
{
    local int TraderTime, Min, Time;
    
    if( KFGRI != None )
    {
        if( KFGRI.bTraderIsOpen )
        {
            TraderTime = KFGRI.GetTraderTimeRemaining();
            
            Min = TraderTime / 60;
            Time = TraderTime - (Min * 60);
            
            return (Min >= 10 ? string(Min) : "0" $ Min) $ ":" $ (Time >= 10 ? string(Time) : "0" $ Time);
        }
        else if( KFGRI.bWaveIsActive )
        {
            if( KFGRI.IsBossWave() )
            {
                return class'KFGFxHUD_WaveInfo'.default.BossWaveString;
            }
            else if( KFGRI.IsEndlessWave() )
            {
                // ∞ symbol
                return Chr(0x221E);
            }
            
            return string(KFGRI.AIRemaining);
        }
    }
    
    return "";
}

function string GetGameInfoSubText()
{
    local int WaveMax;
    local string S;
    
    if( KFGRI != None && KFGRI.bWaveIsActive && !KFGRI.IsBossWave() )
    {
        WaveMax = KFGRI.WaveMax-1;
        
        if( KFGameReplicationInfo_Endless(KFGRI) != None )
            S = string(KFGRI.WaveNum);
        else S = string(KFGRI.WaveNum) $ "/" $ string(WaveMax);
        
        return class'KFGFxHUD_WaveInfo'.default.WaveString @ S;
    }
    
    return "";
}

function DrawHUDBox
    (
    out float X, 
    out float Y, 
    float Width, 
    float Height, 
    coerce string Text, 
    float TextScale=1.f,
    optional HUDBoxRenderInfo HBRI
    )
{
    local float XL, YL, TempX, IconXL, IconYL;
    local bool bUseAlpha;
    local int i;
    local FontRenderInfo FRI;
    
    FRI.bClipText = true;
    FRI.bEnableShadow = true;
    
    bUseAlpha = HBRI.Alpha != -1.f;
    
    if( !bLightHUD )
    {
        GUIStyle.DrawOutlinedBox(X, Y, Width, Height, ScaledBorderSize, MakeColor(HudMainColor.R, HudMainColor.G, HudMainColor.B, bUseAlpha ? byte(FMin(HBRI.Alpha, HudMainColor.A)) : HudMainColor.A), MakeColor(HudOutlineColor.R, HudOutlineColor.G, HudOutlineColor.B, bUseAlpha ? byte(Min(HBRI.Alpha, HudOutlineColor.A)) : HudOutlineColor.A));
    }
    
    TempX = X - (ScaledBorderSize/2);
    
    if( HBRI.IconTex != None )
    {
        IconXL = TempX + (HBRI.IconScale / 2);
        IconYL = Y + (Height / 2) - (HBRI.IconScale / 2);
        
        if( HudOutlineColor != DefaultHudOutlineColor )
            Canvas.SetDrawColor(HudOutlineColor.R, HudOutlineColor.G, HudOutlineColor.B, bUseAlpha ? byte(HBRI.Alpha) : 255);
        else Canvas.SetDrawColor(255, 255, 255, bUseAlpha ? byte(HBRI.Alpha) : 255);
        
        Canvas.SetPos(IconXL, IconYL);
        
        if( HBRI.IconScale == 1.f )
        {
            HBRI.IconScale = HBRI.IconTex.GetSurfaceHeight();
        }
        
        Canvas.DrawRect(HBRI.IconScale - ScaledBorderSize, HBRI.IconScale - ScaledBorderSize, HBRI.IconTex);
    }

    Canvas.SetDrawColor(HBRI.TextColor.R, HBRI.TextColor.G, HBRI.TextColor.B, bUseAlpha ? byte(Min(HBRI.Alpha, HBRI.TextColor.A)) : HBRI.TextColor.A);
    
    if( HBRI.StringArray.Length < 1 )
    {
        Canvas.TextSize(GUIStyle.StripTextureFromString(Text), XL, YL, TextScale, TextScale);
        GUIStyle.DrawTexturedString(Text, TempX + (HBRI.IconTex != None ? (HBRI.IconScale * 1.75f) : (Width / 2) - (XL / 2)), Y + (Height / 2) - (YL / 1.75f), Width, Height, TextScale, FRI, HBRI.bUseOutline);
    }
    else
    {
        Y -= (ScaledBorderSize / 1.75f);
        
        for( i=0; i<HBRI.StringArray.Length; ++i )
        {
            Canvas.TextSize(GUIStyle.StripTextureFromString(HBRI.StringArray[i]), XL, YL, TextScale, TextScale);
            GUIStyle.DrawTexturedString(HBRI.StringArray[i], TempX + (HBRI.IconTex != None ? (HBRI.IconScale * 1.75f) : (Width / 2) - (XL / 2)), Y, Width, Height, TextScale, FRI, HBRI.bUseOutline);
            Y+=GUIStyle.DefaultHeight;
        }
    }
    
    switch(HBRI.Justification)
    {
        case HUDA_Right:
            X += Width + GUIStyle.ScreenScale(HBRI.JustificationPadding);
            break;
        case HUDA_Left:
            X -= Width + GUIStyle.ScreenScale(HBRI.JustificationPadding);
            break;
        case HUDA_Top:
            Y += Height + GUIStyle.ScreenScale(HBRI.JustificationPadding);
            break;
        case HUDA_Bottom:
            Y -= Height + GUIStyle.ScreenScale(HBRI.JustificationPadding);
            break;
    }
}

function DrawDeployTime(byte RemainingTime)
{
    local float FontScalar, XL, YL;
    local int Min, Time;
    local byte Glow;
    local string S;
    
    Canvas.Font = GUIStyle.PickFont(FontScalar);
    FontScalar += GUIStyle.ScreenScale(0.5);
    
    if( RemainingTime == -1 )
    {
        S = class'UI_LobbyMenu'.default.WaitingForOtherPlayers;
        Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
        GUIStyle.DrawTextShadow(S, (Canvas.ClipX * 0.5f) - (XL * 0.5f), Canvas.ClipY * 0.05f, int( Canvas.ClipY / 360.f ), FontScalar);
    }
    else
    {
		if( RemainingTime <= 10 )
        {
            Glow = Clamp(Sin(WorldInfo.TimeSeconds * 8) * 200 + 255, 0, 255);
            Canvas.DrawColor = MakeColor(255, Glow, Glow, 255);
            
            if( LastWarningTime != RemainingTime )
            {
                LastWarningTime = RemainingTime;   
                KFPlayerOwner.MyGFxHUD.PlaySoundFromTheme('PARTYWIDGET_COUNTDOWN', 'UI');
            }
        }
        
        Min = RemainingTime / 60;
        Time = RemainingTime - (Min * 60);

        S = class'UI_LobbyMenu'.default.AutoCommence$":" @ (Min >= 10 ? string(Min) : "0" $ Min) $ ":" $ (Time >= 10 ? string(Time) : "0" $ Time);
        Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
        GUIStyle.DrawTextShadow(S, (Canvas.ClipX * 0.5f) - (XL * 0.5f), Canvas.ClipY * 0.05f, int( Canvas.ClipY / 360.f ), FontScalar);
    }
}

function RenderKFHUD(KFPawn_Human KFPH)
{
    local float scale_w, scale_w2, FontScalar, OriginalFontScalar, XL, YL, BoxXL, BoxYL, BoxSW, BoxSH, DoshXL, DoshYL, PerkXL, PerkYL, StarXL, StarYL, TempSize;
    local float PerkProgressSize, PerkProgressX, PerkProgressY;
    local byte PerkLevel;
    local int i, XPos, YPos, DrawCircleSize, FlashlightCharge, AmmoCount, MagCount, StarCount, CurrentScore, FadeAlpha, Index;
    local string CircleText, SubCircleText, WeaponName, TraderDistanceText;
    local bool bSingleFire, bHasSecondaryAmmo;
    local Texture PerkIcon, PerkStarIcon;
    local KFInventoryManager Inv;
    local KFPlayerReplicationInfo MyKFPRI;
    local KFGameReplicationInfo MyKFGRI;
    local KFWeapon CurrentWeapon;
    local KFTraderTrigger T;
    local KFWeap_Healer_Syringe S;
    local KFGFxObject_TraderItems TraderItems;
    local FontRenderInfo FRI;
    local Color HealthFontColor;
    local HUDBoxRenderInfo HBRI;
    
    if( KFPlayerOwner.bCinematicMode )
        return;
        
    if( !WorldInfo.GRI.bMatchHasBegun && ClassicPlayerOwner.LobbyMenu.bViewMapClicked )
    {
        DrawDeployTime(WorldInfo.GRI.RemainingTime);
    }
        
    if( ClassicPlayerOwner.LobbyMenu != None )
        return;
    
    FRI.bClipText = true;
    FRI.bEnableShadow = true;
        
    // I know this is drawn in DrawHUD but it needs to be here to prevent the weapon overlay mesh from being drawn ontop.
    DisplayLocalMessages();
    DrawTraderIndicator();
    
    scale_w = GUIStyle.ScreenScale(64);
    scale_w2 = GUIStyle.ScreenScale(32);
    
    BoxXL = SizeX * 0.015;
    BoxYL = SizeY * 0.935;
    
    BoxSW = SizeX * 0.0625;
    BoxSH = SizeY * 0.0425;
    
    // Trader/Wave info
    CircleText = GetGameInfoText();
    SubCircleText = GetGameInfoSubText();
    if( CircleText != "" )
    {
        Canvas.Font = GUIStyle.PickFont(OriginalFontScalar);
        
        FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.3);
        DrawCircleSize = GUIStyle.ScreenScale(128);
        
        if( !bLightHUD )
        {
            if( HudOutlineColor != DefaultHudOutlineColor )
                Canvas.SetDrawColor(HudOutlineColor.R, HudOutlineColor.G, HudOutlineColor.B, 255);
            else Canvas.SetDrawColor(255, 255, 255, 255);
            
            Canvas.SetPos(Canvas.ClipX - DrawCircleSize, 2);
            Canvas.DrawRect(DrawCircleSize, DrawCircleSize, KFGRI.bWaveIsActive ? BioCircle : WaveCircle);
        }
        
        Canvas.TextSize(CircleText, XL, YL, FontScalar, FontScalar);
        
        XPos = Canvas.ClipX - DrawCircleSize/2 - (XL / 2);
        YPos = SubCircleText != "" ? DrawCircleSize/2 - (YL / 1.5) : DrawCircleSize/2 - YL / 2;
        
        Canvas.DrawColor = FontColor;
        Canvas.SetPos(XPos, YPos);
        Canvas.DrawText(CircleText, , FontScalar, FontScalar, FRI);
        
        if( SubCircleText != "" )
        {
            FontScalar = OriginalFontScalar;
            
            Canvas.TextSize(SubCircleText, XL, YL, FontScalar, FontScalar);
            Canvas.SetPos(Canvas.ClipX - DrawCircleSize/2 - (XL / 2), DrawCircleSize/2 + (YL / 2.5));
            Canvas.DrawText(SubCircleText, , FontScalar, FontScalar, FRI);
        }
    }
    
    if( !bShowHUD || KFPH == None )
        return;
        
    Inv = KFInventoryManager(KFPH.InvManager);
        
    Canvas.Font = GUIStyle.PickFont(OriginalFontScalar, true);
    FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.3);
    
    HBRI.IconScale = scale_w2;
    HBRI.Justification = HUDA_Right;
    HBRI.TextColor = FontColor;
    
    if( !bHidePlayerInfo )
    {
        // Health
        HealthFontColor = FontColor;
        if ( KFPH.Health < 50 )
        {
            HealthFontColor.R = 255;
            HealthFontColor.G = Clamp(Sin(WorldInfo.TimeSeconds * 12) * 200 + 200, 0, 200);
            HealthFontColor.B = 0;
        }

        HBRI.TextColor = HealthFontColor;
        HBRI.IconTex = HealthIcon;
        DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, string(KFPH.Health), FontScalar, HBRI);
        
        HBRI.TextColor = FontColor;
    
        // Armor
        HBRI.IconTex = ArmorIcon;
        DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, string(KFPH.Armor), FontScalar, HBRI);
        
        if( Inv != None )
        {
            HBRI.IconTex = WeightIcon;
            
            // Weight
            BoxSW = SizeX * 0.082;
            DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, Inv.CurrentCarryBlocks$"/"$Inv.MaxCarryBlocks, FontScalar, HBRI);
        }
        
        BoxSW = SizeX * 0.0625;
    }
    
    MyKFPRI = KFPlayerReplicationInfo(KFPlayerOwner.PlayerReplicationInfo);
    if( MyKFPRI != None )
    {
        if( !bHideDosh )
        {
            FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.625);
            
            // Dosh
            DoshXL = SizeX * 0.85;
            DoshYL = SizeY * 0.835;
            
            if( HudOutlineColor != DefaultHudOutlineColor )
                Canvas.SetDrawColor(HudOutlineColor.R, HudOutlineColor.G, HudOutlineColor.B, 255);
            else Canvas.SetDrawColor(255, 255, 255, 255);

            Canvas.SetPos(DoshXL, DoshYL);
            Canvas.DrawRect(scale_w, scale_w, DoshIcon);
            
            CurrentScore = int(MyKFPRI.Score);
            if( OldPlayerScore != CurrentScore )
            {
                if( !bInterpolating )
                {
                    bInterpolating = true;
                    TimeX = WorldInfo.RealTimeSeconds;
                }
                
                PlayerScore = Clamp(Lerp(PlayerScore, CurrentScore, WorldInfo.RealTimeSeconds-TimeX), 0, CurrentScore);
                if( PlayerScore == CurrentScore )
                {
                    bInterpolating = false;
                    OldPlayerScore = CurrentScore;
                }
            }
            
            Canvas.TextSize(PlayerScore, XL, YL, FontScalar, FontScalar);
            Canvas.SetDrawColorStruct(FontColor);
            GUIStyle.DrawTextOutline(PlayerScore, DoshXL + (DoshXL * 0.035), DoshYL + (scale_w / 2) - (YL / 2), 1, MakeColor(0, 0, 0, FontColor.A), FontScalar, FRI);
        }
        
        // Draw Perk Info
        if( MyKFPRI.CurrentPerkClass == none )
        {
            return;
        }
        
        FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.15);
        PerkLevel = class<ClassicPerk_Base>(MyKFPRI.CurrentPerkClass).static.PreDrawPerk(Canvas, MyKFPRI.GetActivePerkLevel(), PerkIcon, PerkStarIcon);
        
        //Perk Icon
        PerkXL = SizeX - (SizeX - 12);
        PerkYL = SizeY * 0.8625;
        
        Canvas.SetPos(PerkXL, PerkYL);
        Canvas.DrawRect(scale_w, scale_w, PerkIcon);

        //Perk Stars
        if( PerkLevel > 0 )
        {
            StarCount = 0;
            PerkIconSize = GUIStyle.ScreenScale(default.PerkIconSize);
            StarXL = PerkXL + (scale_w - (PerkIconSize / 4));
            
            for ( i = 0; i < PerkLevel; i++ )
            {
                StarYL = (PerkYL + (scale_w - PerkIconSize)) - (StarCount * PerkIconSize);
                
                Canvas.SetPos(StarXL, StarYL);
                Canvas.DrawRect(PerkIconSize, PerkIconSize, PerkStarIcon);
                
                if( ++StarCount == MaxStarsPerRow )
                {
                    StarCount = 0;
                    StarXL += PerkIconSize;
                }
            }
        }
        
        // Progress Bar
        PerkProgressSize = GUIStyle.ScreenScale(76);
        PerkProgressX = Canvas.ClipX * 0.007;
        PerkProgressY = PerkYL - (scale_w / 2);
        Canvas.DrawColor = WhiteColor;
        
        bDisplayingProgress = true;
        LevelProgressBar = KFPlayerOwner.GetPerkLevelProgressPercentage(KFPlayerOwner.CurrentPerk.Class);
        DrawProgressBar(PerkProgressX,PerkProgressY-PerkProgressSize*0.12f,PerkProgressSize*2.f,PerkProgressSize*0.125f,VisualProgressBar);
    }
    
    // Trader Distance
    MyKFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( MyKFGRI != None && (MyKFGRI.OpenedTrader != None || MyKFGRI.NextTrader != None) )
    {
        T = MyKFGRI.OpenedTrader != None ? MyKFGRI.OpenedTrader : MyKFGRI.NextTrader;
        if( T != None )
        {
            Canvas.Font = GUIStyle.PickFont(OriginalFontScalar);
            
            FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.3);
            
            TraderDistanceText = "Trader"$": "$int(VSize(T.Location - KFPH.Location) / 100.f)$"m";
            Canvas.TextSize(TraderDistanceText, XL, YL, FontScalar, FontScalar);
            
            Canvas.SetDrawColorStruct(FontColor);
            GUIStyle.DrawTextOutline(TraderDistanceText, Canvas.ClipX*0.015, YL, 1, MakeColor(0, 0, 0, FontColor.A), FontScalar, FRI);
        }
    }
    
    CurrentWeapon = KFWeapon(KFPH.Weapon);
    if( CurrentWeapon != None )
    {
        if( !bHideWeaponInfo )
        {
            Canvas.Font = GUIStyle.PickFont(OriginalFontScalar);
            FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.1);
            
            // Weapon Name
            if( CachedWeaponInfo.Weapon != CurrentWeapon )
            {
                if( MyKFGRI != None )
                {
                    TraderItems = MyKFGRI.TraderItems;
                    if( TraderItems != None )
                    {
                        Index = TraderItems.SaleItems.Find('ClassName', CurrentWeapon.Class.Name);
                        if( Index != INDEX_NONE )
                        {
                            WeaponName = TraderItems.SaleItems[Index].WeaponDef.static.GetItemName();
                        }
                    }
                }
                
                if( WeaponName == "" )
                    WeaponName = CurrentWeapon.ItemName;
                    
                CachedWeaponInfo.Weapon = CurrentWeapon;
                CachedWeaponInfo.WeaponName = WeaponName;
            }
            else
            {
                WeaponName = CachedWeaponInfo.WeaponName;
            }
            
            Canvas.TextSize(WeaponName, XL, YL, FontScalar, FontScalar);
            Canvas.SetDrawColorStruct(FontColor);
            GUIStyle.DrawTextOutline(WeaponName, (SizeX * 0.95f) - XL, SizeY * 0.892f, 1, MakeColor(0, 0, 0, FontColor.A), FontScalar, FRI);
            
            Canvas.Font = GUIStyle.PickFont(OriginalFontScalar,true);
            
            BoxXL = SizeX * 0.915;
            FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.3);
            
            HBRI.Justification = HUDA_Left;
            
            if( Inv != None )
            {
                // Grenades
                HBRI.IconTex = GrenadesIcon;
                DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, string(Inv.GrenadeCount), FontScalar, HBRI);
            }
            
            // ToDo - Find better way to check for weapons like the Welder and Med Syringe
            if( CurrentWeapon.UsesAmmo() || (CurrentWeapon.IsA('KFWeap_Welder') || CurrentWeapon.IsA('KFWeap_Healer_Syringe')) )
            {
                bSingleFire = CurrentWeapon.default.MagazineCapacity[0] <= 1;
                bHasSecondaryAmmo = CurrentWeapon.UsesSecondaryAmmo();
                
                AmmoCount = CurrentWeapon.AmmoCount[0];
                MagCount = bSingleFire ? CurrentWeapon.GetSpareAmmoForHUD() : FCeil(float(CurrentWeapon.GetSpareAmmoForHUD()) / float(CurrentWeapon.default.MagazineCapacity[0]));
                
                if( CurrentWeapon.IsA('KFWeap_Welder') || CurrentWeapon.IsA('KFWeap_Healer_Syringe') )
                {
                    bSingleFire = true;
                    MagCount = AmmoCount;
                }
                
                // Clips
                HBRI.IconTex = GetClipIcon(CurrentWeapon, bSingleFire);
                DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, string(MagCount), FontScalar, HBRI);
                
                // Bullets
                if( !bSingleFire )
                {
                    HBRI.IconTex = GetBulletIcon(CurrentWeapon);
                    DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, string(AmmoCount), FontScalar, HBRI);
                }
                
                // Secondary Ammo
                if( bHasSecondaryAmmo )
                {
                    HBRI.IconTex = GetSecondaryAmmoIcon(CurrentWeapon);
                    DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, string(CurrentWeapon.GetSecondaryAmmoForHUD()), FontScalar, HBRI);
                }
            }
            
            // Flashlight
            FlashlightCharge = KFPH.BatteryCharge;
            if( FlashlightCharge != KFPH.default.BatteryCharge || KFPH.bFlashlightOn )
            {
                HBRI.IconTex = KFPH.bFlashlightOn ? FlashlightIcon : FlashlightOffIcon;
                DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, string(int(KFPH.BatteryCharge)), FontScalar, HBRI);
            }
            
            // Quick Syringe
            if ( bDisplayQuickSyringe && !CurrentWeapon.IsA('KFWeap_Healer_Syringe') )
            {
                S = KFWeap_Healer_Syringe(KFPH.FindInventoryType(class'KFWeap_Healer_Syringe', true));
                if( S != None )
                {
                    TempSize = WorldInfo.TimeSeconds - QuickSyringeStartTime;
                    if ( TempSize < QuickSyringeDisplayTime )
                    {
                        if ( TempSize < QuickSyringeFadeInTime )
                        {
                            FadeAlpha = int((TempSize / QuickSyringeFadeInTime) * 255.0);
                        }
                        else if ( TempSize > QuickSyringeDisplayTime - QuickSyringeFadeOutTime )
                        {
                            FadeAlpha = int((1.0 - ((TempSize - (QuickSyringeDisplayTime - QuickSyringeFadeOutTime)) / QuickSyringeFadeOutTime)) * 255.0);
                        }
                        else
                        {
                            FadeAlpha = 255;
                        }
                        
                        HBRI.IconTex = SyringIcon;
                        HBRI.Alpha = FadeAlpha;
                        DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, string(S.AmmoCount[0]), FontScalar, HBRI);
                    }
                    else
                    {
                        bDisplayQuickSyringe = false;
                    }
                }
            }
        }
    }
    
    // NonCritical Messages
    if( NonCriticalMessages.Length > 0 )
    {
        for( i=0; i<NonCriticalMessages.Length; ++i )
        {
            DrawNonCritialMessage(i, NonCriticalMessages[i], Canvas.ClipX * 0.5, Canvas.ClipY * 0.9);
        }
    }
    
    // Priority Message
    if( PriorityMessage != default.PriorityMessage )
    {
        DrawPriorityMessage();
    }

    // Portraits
    if( bDrawingPortrait )
    {
        DrawPortrait();
    }
    
    // Inventory
    if ( bDisplayInventory )
    {
        DrawInventory();
    }
}

function DrawInventory()
{
    local InventoryCategory Categorized[MAX_WEAPON_GROUPS];
    local int i, j;
    local byte FadeAlpha, ItemIndex;
    local float TempSize, TempX, TempY, TempWidth, TempHeight, TempBorder, FontScalar, AmmoFontScalar, CatagoryFontScalar;
    local float XL, YL, XS, YS;
    local string WeaponName, S;
    local KFWeapon KFW;
    local KFGameReplicationInfo GRI;
    local Color MainColor, OutlineColor;
    local HUDBoxRenderInfo HBRI;

    if( PlayerOwner.Pawn == None || PlayerOwner.Pawn.InvManager == None )
    {
        return;
    }
    
    GRI = KFGameReplicationInfo(WorldInfo.GRI);

    TempSize = WorldInfo.TimeSeconds - InventoryFadeStartTime;
    if ( TempSize > InventoryFadeTime )
    {
        bDisplayInventory = false;
        return;
    }
    
    if ( TempSize < InventoryFadeInTime )
    {
        FadeAlpha = int((TempSize / InventoryFadeInTime) * 255.0);
    }
    else if ( TempSize > InventoryFadeTime - InventoryFadeOutTime )
    {
        FadeAlpha = int((1.0 - ((TempSize - (InventoryFadeTime - InventoryFadeOutTime)) / InventoryFadeOutTime)) * 255.0);
    }
    else
    {
        FadeAlpha = 255;
    }

    foreach PlayerOwner.Pawn.InvManager.InventoryActors( class'KFWeapon', KFW )
    {
        if ( KFW.InventoryGroup < MAX_WEAPON_GROUPS )
        {
            Categorized[KFW.InventoryGroup].Items[Categorized[KFW.InventoryGroup].ItemCount++] = KFW;
        }
    }
    
    Canvas.Font = GUIStyle.PickFont(FontScalar);
    AmmoFontScalar = FontScalar;
    CatagoryFontScalar = FontScalar;

    TempWidth = InventoryBoxWidth * Canvas.ClipX;
    TempHeight = InventoryBoxHeight * Canvas.ClipX;
    TempBorder = BorderSize * Canvas.ClipX;

    TempX = (Canvas.ClipX/2) - (((TempWidth + TempBorder) * MAX_WEAPON_GROUPS)/2);

    for ( i = 0; i < MAX_WEAPON_GROUPS; i++ )
    {
        if( SelectedInventoryCategory == i && MaxWeaponIndex[i] != 0 )
        {
            if( SelectedInventoryIndex == 0 && MinWeaponIndex[i] != 0 )
            {
                MinWeaponIndex[i] = 0;
            }
            
            if( SelectedInventoryIndex > MaxWeaponIndex[i] )
                MinWeaponIndex[i] = SelectedInventoryIndex - MaxWeaponsPerCatagory;
            else if( SelectedInventoryIndex < MinWeaponIndex[i] )
                MinWeaponIndex[i]--;
        }
        else if( MinWeaponIndex[i] != 0 )
        {
            MinWeaponIndex[i] = 0;
        }
    
        TempY = InventoryY * Canvas.ClipY;
        
        HBRI.Justification = HUDA_Top;
        HBRI.JustificationPadding = 24;
        HBRI.TextColor = FontColor;
        HBRI.Alpha = FadeAlpha;

        DrawHUDBox(TempX, TempY, TempWidth, TempHeight * 0.25, GetWeaponCatagoryName(i), CatagoryFontScalar, HBRI);
        
        if ( Categorized[i].ItemCount != 0 )
        {
            for ( j = 0; j < Categorized[i].ItemCount; j++ )
            {
                if( j < MinWeaponIndex[i] )
                    continue;

                KFW = Categorized[i].Items[j];
                if ( i == SelectedInventoryCategory && j == SelectedInventoryIndex )
                {
                    MainColor = HudOutlineColor * 0.5;
                    MainColor.A = Min(FadeAlpha, default.HudOutlineColor.A);
                    OutlineColor = HudOutlineColor;
                    OutlineColor.A = Min(FadeAlpha, default.HudOutlineColor.A);;
                
                    GUIStyle.DrawOutlinedBox(TempX, TempY, TempWidth, TempHeight, ScaledBorderSize, MainColor, OutlineColor);
                    
                    if( GRI != None && GRI.TraderItems.GetItemIndicesFromArche(ItemIndex, KFW.Class.Name) )
                        WeaponName = GRI.TraderItems.SaleItems[ItemIndex].WeaponDef.static.GetItemName();
                    else WeaponName = KFW.ItemName;
                        
                    Canvas.DrawColor = WhiteColor;
                    Canvas.DrawColor.A = FadeAlpha;
                    Canvas.TextSize(WeaponName, XS, YS, FontScalar, FontScalar);
                    
                    while( XS > TempWidth )
                    {
                        FontScalar -= 0.1;
                        Canvas.TextSize(WeaponName, XS, YS, FontScalar, FontScalar);
                    }
                    
                    Canvas.SetPos(TempX + ((TempWidth/2) - (XS/2)), TempY + (YS/4));
                    Canvas.DrawText(WeaponName,, FontScalar, FontScalar);
                }
                else 
                {
                    MainColor = HudMainColor;
                    MainColor.A = Min(FadeAlpha, default.HudMainColor.A);;
                    OutlineColor = HudOutlineColor;
                    OutlineColor.A = Min(FadeAlpha, default.HudOutlineColor.A);;
                
                    GUIStyle.DrawOutlinedBox(TempX, TempY, TempWidth, TempHeight, ScaledBorderSize, MainColor, OutlineColor);
                }
                
                Canvas.DrawColor = WhiteColor;
                Canvas.DrawColor.A = FadeAlpha;
                
                XL = TempWidth * 0.75;
                YL = TempHeight * 0.5;
                
                Canvas.SetPos(TempX + ((TempWidth/2) - (XL/2)), TempY + ((TempHeight/2) - (YL/2)));
                Canvas.DrawRect(XL, YL, KFW.WeaponSelectTexture);
                
                if( KFW.static.UsesAmmo() )
                {
                    S = KFW.AmmoCount[class'KFWeapon'.const.DEFAULT_FIREMODE]$"/"$KFW.SpareAmmoCount[class'KFWeapon'.const.DEFAULT_FIREMODE];
                    Canvas.TextSize(S, XS, YS, AmmoFontScalar, AmmoFontScalar);
                    Canvas.SetPos(TempX + (TempWidth - XS) - (ScaledBorderSize*2), TempY + (TempHeight - YS) - (ScaledBorderSize*2));
                    Canvas.DrawText(S,, AmmoFontScalar, AmmoFontScalar);
                }
                
                if( KFW.UsesSecondaryAmmo() && KFW.bCanRefillSecondaryAmmo )
                {
                    if( KFW.SpareAmmoCount[class'KFWeapon'.const.ALTFIRE_FIREMODE] <= 0 )
                        S = string(KFW.AmmoCount[class'KFWeapon'.const.ALTFIRE_FIREMODE]);
                    else S = KFW.AmmoCount[class'KFWeapon'.const.ALTFIRE_FIREMODE]$"/"$KFW.SpareAmmoCount[class'KFWeapon'.const.ALTFIRE_FIREMODE];
                    
                    Canvas.TextSize(S, XS, YS, AmmoFontScalar, AmmoFontScalar);
                    Canvas.SetPos(TempX + (ScaledBorderSize*2), TempY + (TempHeight - YS) - (ScaledBorderSize*2));
                    Canvas.DrawText(S,, AmmoFontScalar, AmmoFontScalar);
                }
                
                if( (TempY + TempHeight) > (Canvas.ClipY * 0.75) )
                {
                    if( MaxWeaponsPerCatagory == 0 )
                    {
                        MaxWeaponsPerCatagory = j;
                    }
                    
                    MaxWeaponIndex[i] = j;
                    break;
                }

                TempY += TempHeight;
            }
        }

        TempX += TempWidth + TempBorder;
    }
}

function string GetWeaponCatagoryName(int Index)
{
    switch(Index)
    {
        case 0:
            return class'KFGFxHUD_WeaponSelectWidget'.default.PrimaryString;
        case 1:
            return class'KFGFxHUD_WeaponSelectWidget'.default.SecondaryString;
        case 2:
            return class'KFGFxHUD_WeaponSelectWidget'.default.MeleeString;
        case 3:
            return class'KFGFxHUD_WeaponSelectWidget'.default.EquiptmentString;
        default:
            return "ERROR!!";
    }
}

function DrawPriorityMessage()
{
    local float XS, YS, XL, YL, FontScalar;
    local float TempSize;
    local byte FadeAlpha;
    local Color PriorityMColor;
    
    TempSize = WorldInfo.TimeSeconds - PriorityMessage.StartTime;
    if ( TempSize > PriorityMessage.LifeTime )
    {
        PriorityMessage = default.PriorityMessage;
        return;
    }
    
    if ( TempSize < 0.15 )
    {
        FadeAlpha = byte((TempSize / 0.15) * 255.0);
    }
    else if ( TempSize > PriorityMessage.LifeTime - 0.5 )
    {
        FadeAlpha = byte((1.0 - ((TempSize - (PriorityMessage.LifeTime - 0.5)) / 0.5)) * 255.0);
    }
    else
    {
        FadeAlpha = 255;
    }
    
    PriorityMColor = FontColor;
    PriorityMColor.A = FadeAlpha;
    Canvas.DrawColor = PriorityMColor;
    
    GUIStyle.PickFont(FontScalar);
    Canvas.Font = class'KFWaitingMessage'.default.CurrentFont;
    FontScalar += GUIStyle.ScreenScale(1.f);
    
    XL = CenterX;
    YL = CenterY;
    
    Canvas.TextSize(PriorityMessage.PrimaryText, XS, YS, FontScalar, FontScalar);
    GUIStyle.DrawTextBlurry(PriorityMessage.PrimaryText, XL - (XS/2), YL - (YS/2), FontScalar);
    
    YL -= YS;
    FontScalar += GUIStyle.ScreenScale(0.6f);
    
    Canvas.TextSize(PriorityMessage.SecondaryText, XS, YS, FontScalar, FontScalar);
    GUIStyle.DrawTextBlurry(PriorityMessage.SecondaryText, XL - (XS/2), YL - (YS/2), FontScalar);
}

function ShowPriorityMessage(string Primary, string Secondary, float LifeTime)
{
    local FPriorityMessage Message;
    
    if( PriorityMessage != default.PriorityMessage )
        return;
        
    Message.PrimaryText = Primary;
    Message.SecondaryText = Secondary;
    Message.StartTime = WorldInfo.TimeSeconds;
    Message.LifeTime = LifeTime;
    
    PriorityMessage = Message;
}

function DrawNonCritialMessage( int Index, FCritialMessage Message, float X, float Y )
{
    local float XS, YS, XL, YL, TX, BoxXS, BoxYS, FontScalar, TempSize, TY;
    local int i, FadeAlpha;
    local array<string> SArray;
    local HUDBoxRenderInfo HBRI;
    
    Canvas.Font = GUIStyle.PickFont(FontScalar);
    FontScalar += GUIStyle.ScreenScale(0.1);
    
    TempSize = WorldInfo.TimeSeconds - Message.StartTime;
    if ( TempSize > NonCriticalMessageDisplayTime )
    {
        NonCriticalMessages.RemoveItem(Message);
        return;
    }

    if ( TempSize < NonCriticalMessageFadeInTime )
    {
        FadeAlpha = int((TempSize / NonCriticalMessageFadeInTime) * 255.0);
    }
    else if ( TempSize > NonCriticalMessageDisplayTime - NonCriticalMessageFadeOutTime )
    {
        FadeAlpha = int((1.0 - ((TempSize - (NonCriticalMessageDisplayTime - NonCriticalMessageFadeOutTime)) / NonCriticalMessageFadeOutTime)) * 255.0);
    }
    else
    {
        FadeAlpha = 255;
    }
    
    if( Message.Delimiter != "" )
    {
        SArray = SplitString(Message.Text, Message.Delimiter);
        if( SArray.Length > 0 )
        {    
            TY += GUIStyle.DefaultHeight*SArray.Length;
            for( i=0; i<SArray.Length; ++i )
            {
                if( SArray[i]!="" )
                {
                    Canvas.TextSize(GUIStyle.StripTextureFromString(SArray[i]),XS,YS);
                    TX = FMax(XS,TX);
                }
            }
            
            TX *= FontScalar;
            
            XL = (TX + ScaledBorderSize) * 1.15;
            YL = TY + (ScaledBorderSize * 2);
        }
    }
    else
    {
        Canvas.TextSize(GUIStyle.StripTextureFromString(Message.Text), XS, YS, FontScalar, FontScalar);
        
        XL = (XS + ScaledBorderSize) * 1.15;
        YL = YS + (ScaledBorderSize * 2);
    }
    
    BoxXS = X - (XL / 2);
    BoxYS = Y - ((YL + GUIStyle.ScreenScale(12)) * Index);
    
    if( (BoxYS + YL) > Canvas.ClipY )
        BoxYS = Canvas.ClipY - (YL * 1.25);
        
    if( Message.Delimiter == "" )
        BoxYS += (ScaledBorderSize / 2);
        
    HBRI.StringArray = SArray;
    HBRI.TextColor = FontColor;
    HBRI.Alpha = FadeAlpha;
    
    DrawHUDBox(BoxXS, BoxYS, XL, YL, Message.Text, FontScalar, HBRI);
}

function ShowNonCriticalMessage( string Message, optional string Delimiter )
{    
    local FCritialMessage Messages;
    local int Index;
    
    Index = NonCriticalMessages.Find('Text', Message);
    if( Index != INDEX_NONE )
    {
        if ( WorldInfo.TimeSeconds - NonCriticalMessages[Index].StartTime > NonCriticalMessageFadeInTime )
        {
            if ( WorldInfo.TimeSeconds - NonCriticalMessages[Index].StartTime > NonCriticalMessageDisplayTime - NonCriticalMessageFadeOutTime )
            {
                NonCriticalMessages[Index].StartTime = WorldInfo.TimeSeconds - NonCriticalMessageFadeInTime + ((NonCriticalMessageDisplayTime - (WorldInfo.TimeSeconds - NonCriticalMessages[Index].StartTime)) * NonCriticalMessageFadeInTime);
            }
            else
            {
                NonCriticalMessages[Index].StartTime = WorldInfo.TimeSeconds - NonCriticalMessageFadeInTime;
            }
        }
        
        return;
    }
    
    if( NonCriticalMessages.Length >= MaxNonCriticalMessages )
        return;
        
    Messages.Text = Message;
    Messages.Delimiter = Delimiter;
    Messages.StartTime = WorldInfo.TimeSeconds;
    
    NonCriticalMessages.AddItem(Messages);
}

function ShowQuickSyringe()
{
    if ( bDisplayQuickSyringe )
    {
        if ( WorldInfo.TimeSeconds - QuickSyringeStartTime > QuickSyringeFadeInTime )
        {
            if ( WorldInfo.TimeSeconds - QuickSyringeStartTime > QuickSyringeDisplayTime - QuickSyringeFadeOutTime )
            {
                QuickSyringeStartTime = WorldInfo.TimeSeconds - QuickSyringeFadeInTime + ((QuickSyringeDisplayTime - (WorldInfo.TimeSeconds - QuickSyringeStartTime)) * QuickSyringeFadeInTime);
            }
            else
            {
                QuickSyringeStartTime = WorldInfo.TimeSeconds - QuickSyringeFadeInTime;
            }
        }
    }
    else
    {
        bDisplayQuickSyringe = true;
        QuickSyringeStartTime = WorldInfo.TimeSeconds;
    }
}

function DrawDoorHealthBars()
{
    local KFDoorActor DamageDoor;
    local Vector CameraLoc, ScreenLoc;
    local Vector OffScreenLoc, OffScreenRot;
    local Vector2D OffScreenPos;
    local Rotator CameraRot;
    local float MyDot;
    local FDoorCache MyCache;
    local float TextWidth, TextHeight, WeldPercentageFloat, FontScale;
    local string IntegrityText;
    local FontRenderInfo FRI;

    foreach DoorCache(MyCache)
    {
        DamageDoor = MyCache.Door;
        if ( DamageDoor != None )
        {
            OffScreenPos.X = SizeX * PI;
            OffScreenPos.Y = SizeY * PI;
            Canvas.DeProject(OffScreenPos, OffScreenLoc, OffScreenRot);
            DamageDoor.WeldUILocation = OffScreenLoc;
                
            if ( DamageDoor.WeldIntegrity > 0 )
            {
                PlayerOwner.GetPlayerViewPoint( CameraLoc, CameraRot );

                if( !FastTrace(MyCache.WeldUILocation - ((MyCache.WeldUILocation - CameraLoc) * 0.25), CameraLoc) )
                {
                    return;
                }
                
                MyDot = vector(CameraRot) dot (DamageDoor.Location - CameraLoc);
                if( MyDot < 0.5f )
                {
                    return;
                }
                ScreenLoc = Canvas.Project( MyCache.WeldUILocation );
                if( ScreenLoc.X < 0 || ScreenLoc.X + DoorWelderIcon.GetSurfaceWidth() * 3 >= Canvas.ClipX || ScreenLoc.Y < 0 && ScreenLoc.Y >= Canvas.ClipY)
                {
                    return;
                }

                if( !DamageDoor.bIsDestroyed )
                {
                    FRI.bClipText = true;

                    WeldPercentageFloat = (float(DamageDoor.WeldIntegrity) / float(DamageDoor.MaxWeldIntegrity)) * 100.0;
                    if( WeldPercentageFloat < 1.f && WeldPercentageFloat > 0.f )
                    {
                        WeldPercentageFloat = 1.f;
                    }
                    else if( WeldPercentageFloat > 99.f && WeldPercentageFloat < 100.f )
                    {
                        WeldPercentageFloat = 99.f;
                    }
                    IntegrityText = int(WeldPercentageFloat) $ "%";

                    Canvas.SetDrawColor(255, 255, 255, DrawToDistance(DamageDoor, 112, 0));
                    Canvas.SetPos(ScreenLoc.X - ((DoorWelderBG.GetSurfaceWidth() * 1.18) / 2) , ScreenLoc.Y - ((DoorWelderBG.GetSurfaceHeight() * 0.9) / 2));
                    Canvas.DrawTileStretched(DoorWelderBG, DoorWelderBG.GetSurfaceWidth() * 1.18, DoorWelderBG.GetSurfaceHeight() * 0.9, 0, 0, DoorWelderBG.GetSurfaceWidth(), DoorWelderBG.GetSurfaceHeight());

                    Canvas.SetDrawColor(255, 50, 50, DrawToDistance(DamageDoor, 255, 0));

                    Canvas.Font = GUIStyle.PickFont(FontScale);
                    FontScale += 0.2;
                    
                    Canvas.TextSize(IntegrityText, TextWidth, TextHeight, FontScale, FontScale);
                    Canvas.SetDrawColor(255, 50, 50, DrawToDistance(DamageDoor, 255, 0));
                    
                    GUIStyle.DrawTextOutline(IntegrityText, ScreenLoc.X + 5, ScreenLoc.Y - (TextHeight / 2.f), 1, MakeColor(0, 0, 0, Canvas.DrawColor.A), FontScale, FRI);
                    
                    Canvas.SetPos((ScreenLoc.X - 5) - 64, ScreenLoc.Y - 24);
                    Canvas.DrawTile(DoorWelderIcon, 64, 48, 0, 0, 256, 192);
                }
            }
        }
    }
}

function DrawVOIPStatus()
{
    local int i;
    local float X, Y, W, H, XL, YL, TextScale;
    local string PlayerName;
    local HUDBoxRenderInfo HBRI;
    
    X = Canvas.ClipX*0.015;
    Y = Canvas.ClipY*0.3;
    
    Canvas.Font = GUIStyle.PickFont(TextScale);
    for( i=0; i <= 4 && i < TalkerPRIs.Length; i++ )
    {
        PlayerName = TalkerPRIs[i].GetHumanReadableName();
        
        Canvas.TextSize(PlayerName, XL, YL, TextScale, TextScale);
        
        H = YL + (ScaledBorderSize * 2);
        W = (XL + H + (ScaledBorderSize * 2)) * 1.25;
        
        HBRI.TextColor = WhiteColor;
        HBRI.IconTex = VoiceChatIcon;
        HBRI.Justification = HUDA_Top;
        HBRI.JustificationPadding = 12;
        HBRI.IconScale = H;
        
        DrawHUDBox(X, Y, W, H, PlayerName, TextScale, HBRI);
    }
}

function VOIPEventTriggered(PlayerReplicationInfo TalkerPRI, bool bIsTalking)
{
    local KFPlayerReplicationInfo KFPRI;
    
    KFPRI = KFPlayerReplicationInfo(TalkerPRI);
    if ( KFPRI == None )
    {
        return;
    }

    if ( !bIsTalking )
    {
        TalkerPRIs.RemoveItem(KFPRI);
    }
    else
    {
        if(TalkerPRIs.Find(KFPRI) != INDEX_NONE)
        {
            TalkerPRIs.RemoveItem(KFPRI);
        }
        if(!PlayerOwner.IsPlayerMuted(KFPRI.UniqueId))
        {
            TalkerPRIs.AddItem(KFPRI);
        }
    }
}

function RenderHUDWidgets()
{
    local int i;
    local float OrgX,OrgY,ClipX,ClipY;
    
    OrgX = Canvas.OrgX;
    OrgY = Canvas.OrgY;
    ClipX = Canvas.ClipX;
    ClipY = Canvas.ClipY;
    
    for( i=(HUDWidgets.Length-1); i>=0; --i )
    {
        HUDWidgets[i].InputPos[0] = 0.f;
        HUDWidgets[i].InputPos[1] = 0.f;
        HUDWidgets[i].InputPos[2] = GUIController.ScreenSize.X;
        HUDWidgets[i].InputPos[3] = GUIController.ScreenSize.Y;
        HUDWidgets[i].Canvas = Canvas;
        HUDWidgets[i].PreDraw();
    }
    
    Canvas.SetOrigin(OrgX,OrgY);
    Canvas.SetClip(ClipX,ClipY);
}

function RenderVotingOptions()
{
    local float TextWidth, TextHeight, TextScale, OriginalTextScale;
    local float X, Y;
    local FontRenderInfo FRI;
    
    FRI = Canvas.CreateFontRenderInfo(true);
    Canvas.Font = GUIStyle.PickFont(OriginalTextScale);
    
    TextScale = OriginalTextScale + 0.5;
    
    Canvas.TextSize(CurrentVoteName, TextWidth, TextHeight, TextScale, TextScale);
    Y = TextHeight;
    X = (Canvas.ClipX - TextWidth) * 0.5;
    
    GUIStyle.DrawOutlinedBox(X, Y, TextWidth + ScaledBorderSize, TextHeight + ScaledBorderSize, ScaledBorderSize, HudMainColor, HudOutlineColor);
    
    Canvas.DrawColor = WhiteColor;
    GUIStyle.DrawTextOutline(CurrentVoteName, X, Y, 1, MakeColor(0, 0, 0, WhiteColor.A), TextScale, FRI);
    
    Y += TextHeight;
    
    TextScale = OriginalTextScale + 0.3;
    
    Canvas.DrawColor = WhiteColor;
    Canvas.TextSize(CurrentVoteStatus, TextWidth, TextHeight, TextScale, TextScale);
    
    X = (Canvas.ClipX - TextWidth) * 0.5;
    GUIStyle.DrawTextOutline(CurrentVoteStatus, X, Y, 1, MakeColor(0, 0, 0, WhiteColor.A), TextScale, FRI);
    
    Y += TextHeight;
    DrawAdditionalInfo(Canvas, Y);
}

delegate DrawAdditionalInfo(Canvas C, float Y);

function ShowVoteUI(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices, EVoteTypes Type)
{
    if( bVoteActive )
        return;
        
    switch( Type )
    {
        case VT_TYPE_KICK:
            CurrentVoteName = "Kick"@PRI.GetHumanReadableName();
            DrawAdditionalInfo = RenderVoteKick;
            break;
    }
    
    ActiveVote.PRI = PRI;
    ActiveVote.VoteDuration = WorldInfo.TimeSeconds + VoteDuration;
    ActiveVote.bShowChoices = bShowChoices;
    
    bVoteActive = true;
}

function HideVoteUI()
{
    bVoteActive = false;
    DrawAdditionalInfo = None;
    ActiveVote = default.ActiveVote;
    
    CurrentVoteStatus = "";
    CurrentVoteName = "";
}

function UpdateVoteCount(byte YesVotes, byte NoVotes)
{
    ActiveVote.YesVotes = YesVotes;
    ActiveVote.NoVotes = NoVotes;
}

function RenderVoteKick(Canvas C, float Y)
{
    local float TextWidth, TextHeight, TextScale;
    local float X;
    local string YesS, NoS;
    local int Min, Time, VoteTimeLeft;
    local KFPlayerInput KFInput;
    local KeyBind TempKeyBind;
    local FontRenderInfo FRI;
    
    FRI = Canvas.CreateFontRenderInfo(true);
    KFInput = KFPlayerInput(PlayerOwner.PlayerInput);
    
    VoteTimeLeft = Max(ActiveVote.VoteDuration - WorldInfo.TimeSeconds, 0);
    Min = VoteTimeLeft / 60;
    Time = VoteTimeLeft - (Min * 60);
    
    CurrentVoteStatus = ((Min >= 10 ? string(Min) : "0" $ Min) $ ":" $ (Time >= 10 ? string(Time) : "0" $ Time))@"-"@Class'KFCommon_LocalizedStrings'.default.YesString@"("$ActiveVote.YesVotes$")"@Class'KFCommon_LocalizedStrings'.default.NoString@"("$ActiveVote.NoVotes$")";

    KFInput.GetKeyBindFromCommand(TempKeyBind, "GBA_VoteYes");
    YesS = Class'KFCommon_LocalizedStrings'.default.YesString@"-"@Repl(KFInput.GetBindDisplayName(TempKeyBind), "XboxTypeS_", "");
    
    KFInput.GetKeyBindFromCommand(TempKeyBind, "GBA_VoteNo");
    NoS = Class'KFCommon_LocalizedStrings'.default.NoString@"-"@Repl(KFInput.GetBindDisplayName(TempKeyBind), "XboxTypeS_", "");
    
    C.Font = GUIStyle.PickFont(TextScale);
    
    C.DrawColor = MakeColor(0, 255, 0, 255);
    C.TextSize(YesS, TextWidth, TextHeight, TextScale, TextScale);
    X = (C.ClipX - TextWidth) * 0.5;
    GUIStyle.DrawTextOutline(YesS, X, Y, 1, MakeColor(0, 0, 0, C.DrawColor.A), TextScale, FRI); 

    Y += TextHeight;
    C.DrawColor = MakeColor(255, 0, 0, 255);
    C.TextSize(NoS, TextWidth, TextHeight, TextScale, TextScale);
    X = (C.ClipX - TextWidth) * 0.5;
    GUIStyle.DrawTextOutline(NoS, X, Y, 1, MakeColor(0, 0, 0, C.DrawColor.A), TextScale, FRI);         
}

function DrawVictoryEndScreen()
{
    local float TexW, TexH, XL, YL;
    local float X, Y;
    
    Canvas.DrawColor = WhiteColor;
    
    TexW = VictoryScreen.GetSurfaceWidth();
    TexH = VictoryScreen.GetSurfaceHeight();
    
    XL = Canvas.ClipX * 0.9;
    YL = Canvas.ClipY * 0.9;
    
    X = (Canvas.ClipX * 0.5) - (XL/2);
    Y = (Canvas.ClipY * 0.5) - (YL/2);
    
    Canvas.SetPos(X + GUIController.FastFontBlurX, Y + GUIController.FastFontBlurY);
    Canvas.DrawTile(VictoryScreenOverlay, XL, YL, 0, 0, TexW, TexH);
    
    Canvas.SetPos(X + GUIController.FastFontBlurX2, Y + GUIController.FastFontBlurY2);
    Canvas.DrawTile(VictoryScreenOverlay, XL, YL, 0, 0, TexW, TexH);
    
    Canvas.SetPos(X, Y);
    Canvas.DrawTile(VictoryScreen, XL, YL, 0, 0, TexW, TexH);
}

function DrawDefeatEndScreen()
{
    local float TexW, TexH, XL, YL;
    local float X, Y;
    
    Canvas.DrawColor = WhiteColor;
    
    TexW = DefeatScreen.GetSurfaceWidth();
    TexH = DefeatScreen.GetSurfaceHeight();
    
    XL = Canvas.ClipX * 0.9;
    YL = Canvas.ClipY * 0.9;
    
    X = (Canvas.ClipX * 0.5) - (XL/2);
    Y = (Canvas.ClipY * 0.5) - (YL/2);
    
    Canvas.SetPos(X + GUIController.FastFontBlurX, Y + GUIController.FastFontBlurY);
    Canvas.DrawTile(DefeatScreenOverlay, XL, YL, 0, 0, TexW, TexH);
    
    Canvas.SetPos(X + GUIController.FastFontBlurX2, Y + GUIController.FastFontBlurY2);
    Canvas.DrawTile(DefeatScreenOverlay, XL, YL, 0, 0, TexW, TexH);
    
    Canvas.SetPos(X, Y);
    Canvas.DrawTile(DefeatScreen, XL, YL, 0, 0, TexW, TexH);
}

function bool NotifyInputKey(int ControllerId, Name Key, EInputEvent Event, float AmountDepressed, bool bGamepad)
{
    local int i;
    
    for( i=(HUDWidgets.Length-1); i>=0; --i )
    {
        if( HUDWidgets[i].NotifyInputKey(ControllerId, Key, Event, AmountDepressed, bGamepad) )
            return true;
    }
    
    return false;
}

function bool NotifyInputAxis(int ControllerId, name Key, float Delta, float DeltaTime, optional bool bGamepad)
{
    local int i;
    
    for( i=(HUDWidgets.Length-1); i>=0; --i )
    {
        if( HUDWidgets[i].NotifyInputAxis(ControllerId, Key, Delta, DeltaTime, bGamepad) )
            return true;
    }
    
    return false;
}

function bool NotifyInputChar(int ControllerId, string Unicode)
{
    local int i;
    
    for( i=(HUDWidgets.Length-1); i>=0; --i )
    {
        if( HUDWidgets[i].NotifyInputChar(ControllerId, Unicode) )
            return true;
    }
    
    return false;
}

// Hate this but can't add a Texture var for HUD textures to the weapons themselves.
function Texture GetClipIcon(KFWeapon Wep, bool bSingleFire)
{
    if( bSingleFire )
    {
        return GetBulletIcon(Wep);
    }
        
    if( Wep.IsA('KFWeap_Flame_CaulkBurn') || Wep.IsA('KFWeap_Flame_Flamethrower') )
    {
        return FlameTankIcon;
    }
    
    return ClipsIcon;
}

function Texture GetBulletIcon(KFWeapon Wep)
{
    if( Wep.bUseAltFireMode )
    {
        return GetSecondaryAmmoIcon(Wep);
    }
        
    if( Wep.IsA('KFWeap_Eviscerator') )
    {
        return SawbladeIcon;
    }
    else if( Wep.IsA('KFWeap_Flame_CaulkBurn') || Wep.IsA('KFWeap_Flame_Flamethrower') || Wep.IsA('KFWeap_HuskCannon') )
    {
        return FlameIcon;
    }
    else if( Wep.IsA('KFWeap_Bow_Crossbow') )
    {
        return ArrowIcon;
    }
    else if( Wep.IsA('KFWeap_GrenadeLauncher_HX25') || Wep.IsA('KFWeap_GrenadeLauncher_M79') )
    {
        return M79Icon;
    }
    else if( Wep.IsA('KFWeap_Healer_Syringe') )
    {
        return SyringIcon;
    }
    else if( Wep.IsA('KFWeap_RocketLauncher_RPG7') )
    {
        return RocketIcon;
    }    
    else if( Wep.IsA('KFWeap_Welder') )
    {
        return BoltIcon;
    }    
    else if( Wep.IsA('KFWeap_AssaultRifle_AR15') )
    {
        return BurstBulletIcon;
    }
    else if( Wep.IsA('KFWeap_Thrown_C4') )
    {
        return PipebombIcon;
    }    
    else if( Wep.IsA('KFWeap_Rifle_M99') )
    {
        return SingleBulletIcon;
    }
    
    return BulletsIcon;
}

function Texture GetSecondaryAmmoIcon(KFWeapon Wep)
{
    if( Wep.IsA('KFWeap_Eviscerator') )
    {
        return FlameTankIcon;
    }    
    else if( Wep.IsA('KFWeap_MedicBase') )
    {
        return SyringIcon;
    }    
    else if( Wep.IsA('KFWeap_AssaultRifle_M16M203') )
    {
        return M79Icon;
    }    
    else if( Wep.IsA('KFWeap_Rifle_RailGun') || Wep.IsA('KFWeap_RocketLauncher_Seeker6') )
    {
        return AutoTargetIcon;
    }
    else if( Wep.IsA('KFWeap_SMG_MP5RAS') || Wep.IsA('KFWeap_AssaultRifle_AK12') || Wep.IsA('KFWeap_AssaultRifle_AK12') || Wep.IsA('KFWeap_SMG_HK_UMP') )
    {
        return BurstBulletIcon;
    }
    else if( Wep.IsA('KFWeap_DualBase') )
    {
        return BulletsIcon;
    }
    
    return SingleBulletIcon;
}

function byte DrawToDistance(Actor A, optional float StartAlpha=255.f, optional float MinAlpha=50.f)
{
    local float Dist, BeaconAlpha;
    local vector PLCameraLoc;
    local rotator PLCameraRot;
    
    PlayerOwner.GetPlayerViewPoint(PLCameraLoc,PLCameraRot);
    
    Dist = vsize(A.Location - PLCameraLoc);
    Dist -= HealthBarFullVisDist;
    Dist = FClamp(Dist, 0, HealthBarCutoffDist-HealthBarFullVisDist);
    Dist = Dist / (HealthBarCutoffDist - HealthBarFullVisDist);
    BeaconAlpha = byte((1.f - Dist) * StartAlpha);
    
    return FMax(BeaconAlpha, MinAlpha);
}

simulated function bool DrawFriendlyHumanPlayerInfo( KFPawn_Human KFPH )
{
    local float Percentage;
    local float BarHeight, BarLength;
    local float XL, YL;
    local vector ScreenPos, TargetLocation;
    local KFPlayerReplicationInfo KFPRI;
    local FontRenderInfo MyFontRenderInfo;
    local float FontScale;
    local color PerkColor, BarTextColor;
    local byte PerkLevel, FadeAlpha;
        
    KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

    if( KFPRI == none )
    {
        return false;
    }

    FadeAlpha = DrawToDistance(KFPH);
    MyFontRenderInfo = Canvas.CreateFontRenderInfo( true );
    BarLength = FMin(PlayerStatusBarLengthMax * (SizeX / 1024.f), PlayerStatusBarLengthMax) * FriendlyHudScale;
    BarHeight = FMin(8.f * (SizeX / 1024.f), 8.f) * FriendlyHudScale;

    TargetLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,2.2f) );

    ScreenPos = Canvas.Project( TargetLocation );
    if( ScreenPos.X < 0 || ScreenPos.X > SizeX || ScreenPos.Y < 0 || ScreenPos.Y > SizeY )
    {
        return false;
    }

    //Draw health bar
    Percentage = FMin(float(KFPH.Health) / float(KFPH.HealthMax), 100);
    DrawPlayerInfo(KFPH, Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, MakeColor(255, 0, 0, FadeAlpha));

    //Draw armor bar
    if( KFPH.Armor > 0 )
    {
        Percentage = FMin(float(KFPH.Armor) / float(KFPH.MaxArmor), 100);
        DrawPlayerInfo(KFPH, Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight - 4, MakeColor(0, 0, 255, FadeAlpha));
    }
    
    BarTextColor = PlayerBarTextColor;
    BarTextColor.A = FadeAlpha;
    PerkColor.A = FadeAlpha;

    //Draw player name (Top)
    Canvas.Font = GUIStyle.PickFont(FontScale);
    Canvas.SetDrawColorStruct(BarTextColor);
    Canvas.TextSize(KFPRI.PlayerName, XL, YL, FontScale * FriendlyHudScale, FontScale * FriendlyHudScale);
    GUIStyle.DrawTextOutline(KFPRI.PlayerName, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - (BarHeight + (YL * 1.25)), 1, MakeColor(0, 0, 0, Canvas.DrawColor.A), FontScale * FriendlyHudScale, MyFontRenderInfo);

    if( KFPRI.CurrentPerkClass == None )
    {
        return false;
    }
    
    PerkLevel = KFPRI.GetActivePerkLevel();
    PerkColor = class<ClassicPerk_Base>(KFPRI.CurrentPerkClass).static.GetPerkColor(PerkLevel);
    PerkColor.A = FadeAlpha;

    //draw perk icon
    Canvas.SetDrawColorStruct(PerkColor);
    Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f) - PlayerStatusIconSize, ScreenPos.Y - BarHeight * 3.0f);
    Canvas.DrawRect(PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, class<ClassicPerk_Base>(KFPRI.CurrentPerkClass).static.GetCurrentPerkIcon(PerkLevel));

    //Draw perk level and name text
    Canvas.SetDrawColorStruct(BarTextColor);
    GUIStyle.DrawTextOutline(PerkLevel@class<ClassicPerk_Base>(KFPRI.CurrentPerkClass).static.GetPerkName(), ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight * 0.65 + 4, 1, MakeColor(0, 0, 0, Canvas.DrawColor.A), FontScale * FriendlyHudScale, MyFontRenderInfo);

    return true;
}

simulated function DrawPlayerInfo( KFPawn_Human Pawn, float BarPercentage, float BarLength, float BarHeight, float XPos, float YPos, Color BarColor, optional bool bDrawingArmor )
{
    local color BarBGColor;
    
    Canvas.SetDrawColorStruct(MakeColor(185, 185, 185, BarColor.A));
    GUIStyle.DrawBoxHollow(XPos - 2, YPos - 2, BarLength + 4, BarHeight + 4, 1);
    
    BarBGColor = PlayerBarBGColor;
    BarBGColor.A = BarColor.A;
    
    Canvas.SetPos(XPos, YPos);
    Canvas.SetDrawColorStruct(BarBGColor);
    Canvas.DrawTile(PlayerStatusBarBGTexture, BarLength, BarHeight, 0, 0, 32, 32);
    
    Canvas.SetPos(XPos, YPos);
    Canvas.SetDrawColorStruct(BarColor);
    Canvas.DrawTile(PlayerStatusBarBGTexture, BarLength * BarPercentage, BarHeight, 0, 0, 32, 32);
}

function RenderKillMsg()
{
    local float Sc,YL,T,X,Y;
    local string S;
    local int i;
    
    Canvas.Font = GUIStyle.PickFont(Sc);
    Canvas.TextSize("A",X,YL,Sc,Sc);

    X = Canvas.ClipX*0.015;
    Y = Canvas.ClipY*0.15;
    
    for( i=0; i<KillMessages.Length; ++i )
    {
        T = WorldInfo.TimeSeconds-KillMessages[i].MsgTime;
        if( T>6.f )
        {
            KillMessages.Remove(i--,1);
            continue;
        }

        if( KillMessages[i].bDamage )
            S = "-"$KillMessages[i].Counter$" HP "$KillMessages[i].Name;
        else if( KillMessages[i].bLocal )
            S = "+"$KillMessages[i].Counter@KillMessages[i].Name$(KillMessages[i].Counter>1 ? " kills" : " kill");
        else S = (KillMessages[i].OwnerPRI!=None ? KillMessages[i].OwnerPRI.GetHumanReadableName() : "Someone")$" +"$KillMessages[i].Counter@KillMessages[i].Name$(KillMessages[i].Counter>1 ? " kills" : " kill");
        Canvas.DrawColor = KillMessages[i].MsgColor;
        T = (1.f - (T/6.f)) * 255.f;
        Canvas.DrawColor.A = T;
        GUIStyle.DrawTextOutline(S, X, Y, 1, MakeColor(0, 0, 0, Canvas.DrawColor.A), Sc);
        Y+=YL;
    }
}

function color GetMsgColor( bool bDamage, int Count )
{
    local float T;

    if( bDamage )
    {
        if( Count>1500 )
            return MakeColor(148,0,0,255);
        else if( Count>1000 )
        {
            T = (Count-1000) / 500.f;
            return MakeColor(148,0,0,255)*T + MakeColor(255,0,0,255)*(1.f-T);
        }
        else if( Count>500 )
        {
            T = (Count-500) / 500.f;
            return MakeColor(255,0,0,255)*T + MakeColor(255,255,0,255)*(1.f-T);
        }
        T = Count / 500.f;
        return MakeColor(255,255,0,255)*T + MakeColor(0,255,0,255)*(1.f-T);
    }
    if( Count>20 )
        return MakeColor(255,0,0,255);
    else if( Count>10 )
    {
        T = (Count-10) / 10.f;
        return MakeColor(148,0,0,255)*T + MakeColor(255,0,0,255)*(1.f-T);
    }
    else if( Count>5 )
    {
        T = (Count-5) / 5.f;
        return MakeColor(255,0,0,255)*T + MakeColor(255,255,0,255)*(1.f-T);
    }
    T = Count / 5.f;
    return MakeColor(255,255,0,255)*T + MakeColor(0,255,0,255)*(1.f-T);
}

static function string StripMsgColors( string S )
{
    local int i;
    
    while( true )
    {
        i = InStr(S,Chr(6));
        if( i==-1 )
            break;
        S = Left(S,i)$Mid(S,i+2);
    }
    return S;
}

static function string GetNameArticle( string S )
{
    switch( Caps(Left(S,1)) ) // Check if a vowel, then an.
    {
    case "A":
    case "E":
    case "I":
    case "O":
    case "U":
        return "an";
    }
    return "a";
}

static function string GetNameOf( class<Pawn> Other )
{
    local string S;
    local class<KFPawn_Monster> KFM;
        
    KFM = class<KFPawn_Monster>(Other);
    if( KFM!=None )
        return KFM.static.GetLocalizedName();
        
    if( Other.Default.MenuName!="" )
        return Other.Default.MenuName;
        
    S = string(Other.Name);
    if( Left(S,10)~="KFPawn_Zed" )
        S = Mid(S,10);
    else if( Left(S,7)~="KFPawn_" )
        S = Mid(S,7);
    S = Repl(S,"_"," ");
    
    return S;
}

function AddKillMessage( class<Pawn> Victim, int Value, PlayerReplicationInfo PRI, byte Type )
{
    local int i;
    local bool bDmg,bLcl;
    
    bDmg = (Type==2);
    bLcl = (Type==0);
    for( i=0; i<KillMessages.Length; ++i )
        if( KillMessages[i].bDamage==bDmg && KillMessages[i].bLocal==bLcl && KillMessages[i].Type==Victim && (bDmg || bLcl || KillMessages[i].OwnerPRI==PRI) )
        {
            KillMessages[i].Counter+=Value;
            KillMessages[i].MsgTime = WorldInfo.TimeSeconds;
            KillMessages[i].MsgColor = GetMsgColor(bDmg,KillMessages[i].Counter);
            return;
        }
    
    KillMessages.Length = i+1;
    KillMessages[i].bDamage = bDmg;
    KillMessages[i].bLocal = bLcl;
    KillMessages[i].Counter = Value;
    KillMessages[i].Type = Victim;
    KillMessages[i].OwnerPRI = PRI;
    KillMessages[i].MsgTime = WorldInfo.TimeSeconds;
    KillMessages[i].Name = GetNameOf(Victim);
    KillMessages[i].MsgColor = GetMsgColor(bDmg,Value);
}

exec function SetShowScores(bool bNewValue)
{
    bShowScores = bNewValue;
    if( GUIController!=None )
    {
        if( bShowScores )
        {
            Scoreboard = KFScoreBoard(GUIController.OpenMenu(ScoreboardClass));
        }
        else 
        {
            if( Scoreboard == None )
                GUIController.CloseMenu(ScoreboardClass);
            else Scoreboard.DoClose();
        }
    }
}

function DrawTraderIndicator()
{
    local KFTraderTrigger T;
    local rotator CamRot,R;
    local vector CamPos,V,X;
    local string S;
    local float XS,YS,ArrowScale,FontScalar;
    local Canvas.FontRenderInfo FI;
    local KFGameReplicationInfo MyKFGRI;
    
    MyKFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( MyKFGRI == None || (MyKFGRI.OpenedTrader == None && MyKFGRI.NextTrader == None) )
        return;
    
    FI.bClipText = true;
    
    Canvas.Font = GUIStyle.PickFont(FontScalar);
    
    ArrowScale = Canvas.ClipY/33.f;
    PlayerOwner.GetPlayerViewPoint(CamPos,CamRot);
    X = vector(CamRot);
    
    T = MyKFGRI.OpenedTrader != None ? MyKFGRI.OpenedTrader : MyKFGRI.NextTrader;
    if( T != None )
    {
        // First see if on screen.
        Canvas.DrawColor = HudOutlineColor;
        V = T.Location - CamPos;
        if( (V Dot X)>0.997 ) // Front of camera.
        {
            V = Canvas.Project(T.Location+vect(0,0,1.055));
            if( V.X>0 && V.Y>0 && V.X<Canvas.ClipX && V.Y<Canvas.ClipY ) // Within screen bounds.
            {
                Canvas.SetPos(V.X-(ArrowScale*0.5),V.Y-ArrowScale);
                Canvas.DrawRect(ArrowScale, ArrowScale, TraderArrow);
                
                S = class'KFGFxHUD_TraderCompass'.default.TraderString;
                Canvas.TextSize(S,XS,YS,FontScalar,FontScalar);
                GUIStyle.DrawOutlinedBox(V.X-((XS+8.f)*0.5), V.Y-ArrowScale-YS-8.f, XS+8.f, YS+8.f, ScaledBorderSize * 0.5, HudMainColor, HudOutlineColor);
                
                Canvas.SetPos(V.X-(XS*0.5)-((ScaledBorderSize * 0.5)/2),V.Y-ArrowScale-YS-4.f-((ScaledBorderSize * 0.5)/2));
                Canvas.SetDrawColorStruct(WhiteColor);
                Canvas.DrawColor.A = 255;
                Canvas.DrawText(S,,FontScalar,FontScalar,FI);
                
                return;
            }
        }
        
        // Draw the arrow towards the trader.
        // First transform trader offset to local screen space.
        V = (T.Location - CamPos) << CamRot;
        V.X = 0;
        V = Normal(V);

        // Check pitch.
        R.Yaw = rotator(V).Pitch;
        if( V.Y>0 ) // Must flip pitch
            R.Yaw = 32768-R.Yaw;
        R.Yaw+=16384;

        // Check screen edge location.
        V = FindEdgeIntersection(V.Y,-V.Z,ArrowScale);
        
        // Draw arrow.
        Canvas.SetPos(V.X,V.Y);
        Canvas.DrawRotatedTile(TraderArrow,R,ArrowScale,ArrowScale,0,0,TraderArrow.GetSurfaceWidth(),TraderArrow.GetSurfaceHeight());
    }
}

final function vector FindEdgeIntersection( float XDir, float YDir, float ClampSize )
{
    local vector V;
    local float TimeXS,TimeYS,SX,SY;

    // First check for paralell lines.
    if( Abs(XDir)<0.001f )
    {
        V.X = Canvas.ClipX*0.5f;
        if( YDir>0.f )
            V.Y = Canvas.ClipY-ClampSize;
        else V.Y = ClampSize;
    }
    else if( Abs(YDir)<0.001f )
    {
        V.Y = Canvas.ClipY*0.5f;
        if( XDir>0.f )
            V.X = Canvas.ClipX-ClampSize;
        else V.X = ClampSize;
    }
    else
    {
        SX = Canvas.ClipX*0.5f;
        SY = Canvas.ClipY*0.5f;

        // Look for best intersection axis.
        TimeXS = Abs((SX-ClampSize) / XDir);
        TimeYS = Abs((SY-ClampSize) / YDir);
        
        if( TimeXS<TimeYS ) // X axis intersects first.
        {
            V.X = TimeXS*XDir;
            V.Y = TimeXS*YDir;
        }
        else
        {
            V.X = TimeYS*XDir;
            V.Y = TimeYS*YDir;
        }
        
        // Transform axis to screen center.
        V.X += SX;
        V.Y += SY;
    }
    return V;
}

function DrawProgressBar( float X, float Y, float XS, float YS, float Value )
{
    Canvas.DrawColor.A = 64;
    Canvas.SetPos(X, Y);
    Canvas.DrawTileStretched(ProgressBarTex,XS,YS,0,0,ProgressBarTex.GetSurfaceWidth(),ProgressBarTex.GetSurfaceHeight());
    if( Value>0.f )
    {
        Canvas.DrawColor.A = 150;
        Canvas.SetPos(X,Y);
        Canvas.DrawTileStretched(ProgressBarTex,XS*Value,YS,0,0,ProgressBarTex.GetSurfaceWidth(),ProgressBarTex.GetSurfaceHeight());
    }
}

function DrawPortrait()
{
    local float PortraitWidth, PortraitHeight, XL, YL, FontScalar;
    
    if( CurrentTraderPortrait == None )
    {
        if( CurrentTraderVoiceClass == None )
        {
            GetTraderVoiceClass();
        }

        if( class<KFTraderVoiceGroup_Patriarch>(CurrentTraderVoiceClass) != None )
        {
            CurrentTraderPortrait = PatriarchPortrait;
            CurrentTraderName = "Patriarch";
        }
        else if( class<KFTraderVoiceGroup_Lockheart>(CurrentTraderVoiceClass) != None )
        {
            CurrentTraderPortrait = LockheartPortrait;
            CurrentTraderName = "Lockheart";
        }
        else if( class<KFTraderVoiceGroup_Default>(CurrentTraderVoiceClass) != None )
        {
            CurrentTraderPortrait = TraderPortrait;
            CurrentTraderName = "Trader";
        }
        else
        {
            CurrentTraderPortrait = UnknownPortrait;
            CurrentTraderName = "Unknown";
        }
    }

    PortraitWidth = 0.125 * Canvas.ClipY;
    PortraitHeight = 1.5 * PortraitWidth;

    Canvas.DrawColor = WhiteColor;
    
    Canvas.SetPos(-PortraitWidth * PortraitX, 0.5 * (Canvas.ClipY - PortraitHeight));
    Canvas.DrawTileStretched(TraderPortraitBox, 1.05 * PortraitWidth, 1.05 * PortraitHeight, 0, 0, TraderPortraitBox.GetSurfaceWidth(), TraderPortraitBox.GetSurfaceHeight());
    
    Canvas.SetPos(-PortraitWidth * PortraitX + 0.025 * PortraitWidth, 0.5 * (Canvas.ClipY - PortraitHeight) + 0.025 * PortraitHeight);
    Canvas.DrawTile(CurrentTraderPortrait, PortraitWidth, PortraitHeight, 0, 0, 256, 384);
    
    Canvas.Font = GUIStyle.PickFont(FontScalar);
    FontScalar += GUIStyle.ScreenScale(0.1);
    
    Canvas.DrawColor = RedColor;
    Canvas.TextSize(CurrentTraderName, XL, YL, FontScalar, FontScalar);
    GUIStyle.DrawTextOutline(CurrentTraderName, Canvas.ClipY / 256 - PortraitWidth * PortraitX + 0.5 * (PortraitWidth - XL), 0.5 * (Canvas.ClipY + PortraitHeight) + 0.06 * PortraitHeight, 1, MakeColor(0, 0, 0, Canvas.DrawColor.A), FontScalar);
}

simulated function Tick( float Delta )
{
    local ClassicHumanPawn CHP;
    local float PortraitTimeAddition;
    
    FrameTime = Delta;
    
    if( bDisplayingProgress )
    {
        bDisplayingProgress = false;
        if( VisualProgressBar<LevelProgressBar )
            VisualProgressBar = FMin(VisualProgressBar+Delta,LevelProgressBar);
        else if( VisualProgressBar>LevelProgressBar )
            VisualProgressBar = FMax(VisualProgressBar-Delta,LevelProgressBar);
    }
    
       if ( bDrawingPortrait && !bPortraitTimeSet )
    {
        CHP = ClassicHumanPawn(PlayerOwner.Pawn);
        if( CHP != None )
        {
            PortraitTimeAddition = CHP.CurrentTraderVoiceDuration;
        }
        else
        {
            PortraitTimeAddition = 3.f;
        }
        
        PortraitTime = WorldInfo.TimeSeconds + PortraitTimeAddition;
        bPortraitTimeSet = true;
    }

    if ( PortraitTime > WorldInfo.TimeSeconds )
    {
        PortraitX = FMax(0, PortraitX - 3 * Delta);
    }
    else if ( bDrawingPortrait )
    {
        PortraitX = FMin(1, PortraitX + 3 * Delta);

        if ( PortraitX == 1 )
        {
            bPortraitTimeSet = false;
            bDrawingPortrait = false;
        }
    }
    
    Super.Tick(Delta);
}

function DrawMessageText(HudLocalizedMessage LocalMessage, float ScreenX, float ScreenY)
{
    local class<ClassicLocalMessage> ClassicMessage;
    
    ClassicMessage = class<ClassicLocalMessage>(LocalMessage.Message);
    if( ClassicMessage != None && ClassicMessage.default.bComplexString )
    {
        ClassicMessage.static.RenderComplexMessage(Canvas, ScreenX, ScreenY, LocalMessage.StringMessage, LocalMessage.Switch, LocalMessage.OptionalObject);
    }
    else
    {
        Super.DrawMessageText(LocalMessage, ScreenX, ScreenY);
    }
}

function LocalizedMessage
(
    class<LocalMessage>      InMessageClass,
    PlayerReplicationInfo    RelatedPRI_1,
    PlayerReplicationInfo    RelatedPRI_2,
    string                   MessageString,
    int                      Switch,
    float                    Position,
    float                    LifeTime,
    int                      FontSize,
    color                    DrawColor,
    optional object          OptionalObject
)
{
    local string HexClr,TempS;
    local class<KFLocalMessage>  KFLocalMessageClass;

    // Stops KFAIController_ScriptedPawn and KFAIController_Monster from spamming the chatbox with team change messages.
    if( KFDummyReplicationInfo(RelatedPRI_1) != None || KFDummyReplicationInfo(RelatedPRI_2) != None )
        return;
    
    // Removing the flash HUD causes this to print a corrupted translation string to the chatbox, lets avoid that.
    // I can't remove the section of code that calls this because the class object it's called from can't be changed.
    if( class<KFLocalMessage_PlayerKills>(InMessageClass) != None )
        return;

    if( class<ClassicLocalMessage>(InMessageClass) != None )
    {
        Super(HUD).LocalizedMessage(InMessageClass, RelatedPRI_1, RelatedPRI_2, MessageString, Switch, Position, LifeTime, FontSize, DrawColor, OptionalObject);
        return;
    }
    
    if( MessageString == "" )
    {
        return;
    }

    MessageString = Repl(MessageString, "  ", " ");
    
    if( !InMessageClass.default.bIsSpecial )
    {
        AddConsoleMessage( MessageString, InMessageClass, RelatedPRI_1 );
        return;
    }

    if( bMessageBeep && InMessageClass.default.bBeep )
        PlayerOwner.PlayBeepSound();

    KFLocalMessageClass = class<KFLocalMessage>(InMessageClass);
    if(KFLocalMessageClass != none)
    {
        HexClr = KFLocalMessageClass.static.GetHexColor(Switch);
    }
    else if(InMessageClass == class'GameMessage')
    {
        HexClr = class 'KFLocalMessage'.default.ConnectionColor;
    }
    
    TempS = "#{"$HexClr$"}"$MessageString$"<LINEBREAK>";
    if( ClassicPlayerOwner.LobbyMenu != None )
    {
        ClassicPlayerOwner.LobbyMenu.ChatBox.AddText(TempS);
    }
    
    ChatBox.AddText(TempS);
}

static function Font GetFontSizeIndex(int FontSize)
{
    switch(FontSize)
    {
        case 0:
            return Font'EngineFonts.TinyFont';
        case 1:
            return Font'UI_Canvas_Fonts.Font_Main';
        default:
            return Font(DynamicLoadObject("KFClassicMode_Assets.Font.KFMainFont", class'Font'));
    }
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
    if( !bProgressDC )
        ProgressMsgTime = WorldInfo.TimeSeconds+4.f;
    bProgressDC = bDis;
    if( bDis )
    {
        LocalPlayer(KFPlayerOwner.Player).ViewportClient.ViewportConsole.OutputText(Repl(S,"|","\n"));
    }
}

final function RenderProgress()
{
    local float Y,XL,YL,Sc;
    local int i;
    
    Canvas.Font = GUIStyle.PickFont(Sc);
    Sc += 0.1;
    
    if( bProgressDC )
        Canvas.SetDrawColor(255,80,80,255);
    else Canvas.SetDrawColor(255,255,255,255);
    Y = Canvas.ClipY*0.2;

    for( i=0; i<ProgressLines.Length; ++i )
    {
        Canvas.TextSize(ProgressLines[i],XL,YL,Sc,Sc);
        Canvas.SetPos((Canvas.ClipX-XL)*0.5,Y);
        Canvas.DrawText(ProgressLines[i],,Sc,Sc);
        Y+=YL;
    }
}

simulated function Destroyed()
{
    Super.Destroyed();
    NotifyLevelChange();
}

simulated final function NotifyLevelChange( optional bool bMapswitch )
{
    if( bMapswitch )
        SetTimer(0.5,false,'PendingMapSwitch');
        
    /*
    if( OnlineSub!=None )
    {
        OnlineSub.ClearOnInventoryReadCompleteDelegate(SearchInventoryForNewItem);
        OnlineSub = None;
    }
    */
}

simulated function PendingMapSwitch()
{
    class'MS_Game'.Static.SetReference();
    class'MS_PC'.Default.TravelData.PendingURL = WorldInfo.GetAddressURL();
    ConsoleCommand("Open KFMainMenu?Game="$PathName(class'MS_Game'));
}

simulated function SearchInventoryForNewItem()
{
    local int i,j;

    if( WasNewlyAdded.Length!=OnlineSub.CurrentInventory.Length )
        WasNewlyAdded.Length = OnlineSub.CurrentInventory.Length;
    for( i=0; i<OnlineSub.CurrentInventory.Length; ++i )
    {
        if( OnlineSub.CurrentInventory[i].NewlyAdded==1 && WasNewlyAdded[i]==0 )
        {
            WasNewlyAdded[i] = 1;
            if( WorldInfo.TimeSeconds<80.f || !bLoadedInitItems ) // Skip initial inventory.
                continue;
            j = OnlineSub.ItemPropertiesList.Find('Definition', OnlineSub.CurrentInventory[i].Definition);

            if(j != INDEX_NONE)
            {
                NewItems.Insert(0,1);
                NewItems[0].Icon = Texture2D(DynamicLoadObject(OnlineSub.ItemPropertiesList[j].IconURL,Class'Texture2D'));
                NewItems[0].Item = OnlineSub.ItemPropertiesList[j].Name$" ["$RarityStr(OnlineSub.ItemPropertiesList[j].Rarity)$"]";
                NewItems[0].MsgTime = WorldInfo.TimeSeconds;
                ClassicPlayerOwner.ServerItemDropGet(NewItems[0].Item);
            }
        }
    }
    bLoadedInitItems = true;
}

simulated final function string RarityStr( byte R )
{
    switch( R )
    {
    case ITR_Common:            return "Common";
    case ITR_Uncommon:            return "Uncommon +";
    case ITR_Rare:                return "Rare ++";
    case ITR_Legendary:            return "Legendary +++";
    case ITR_ExceedinglyRare:    return "Exceedingly Rare ++++";
    case ITR_Mythical:            return "Mythical !!!!";
    default:                    return "Unknown -";
    }
}

simulated final function DrawItemsList()
{
    local int i;
    local float T,FontScale,XS,YS,YSize,XPos,YPos;
    
    FontScale = Canvas.ClipY / 660.f;
    Canvas.Font = GetFontSizeIndex(0);
    Canvas.TextSize("ABC",XS,YSize,FontScale,FontScale);
    YSize*=2.f;
    YPos = Canvas.ClipY*0.45 - YSize;
    XPos = Canvas.ClipX - YSize*0.15;

    for( i=0; i<NewItems.Length; ++i )
    {
        T = WorldInfo.TimeSeconds-NewItems[i].MsgTime;
        if( T>=10.f )
        {
            NewItems.Remove(i--,1);
            continue;
        }
        if( T>9.f )
        {
            T = 255.f * (10.f-T);
            Canvas.SetDrawColor(255,255,255,T);
        }
        else Canvas.SetDrawColor(255,255,255,255);
        
        Canvas.TextSize(NewItems[i].Item,XS,YS,FontScale,FontScale);

        if( NewItems[i].Icon!=None )
        {
            Canvas.SetPos(XPos-YSize,YPos);
            Canvas.DrawRect(YSize,YSize,NewItems[i].Icon);
            XS = XPos-(YSize*1.1)-XS;
        }
        else XS = XPos-XS;
        
        Canvas.SetPos(XS,YPos);
        Canvas.DrawText("New Item:",,FontScale,FontScale);
        Canvas.SetPos(XS,YPos+(YSize*0.5));
        Canvas.DrawText(NewItems[i].Item,,FontScale,FontScale);

        YPos-=YSize;
    }
}

simulated function CheckForItems()
{
    if( KFGameReplicationInfo(WorldInfo.GRI)!=none )
        KFGameReplicationInfo(WorldInfo.GRI).ProcessChanceDrop();
    SetTimer(260+FRand()*220.f,false,'CheckForItems');
}

simulated function CheckAndDrawHiddenPlayerIcons( array<PlayerReplicationInfo> VisibleHumanPlayers, array<sHiddenHumanPawnInfo> HiddenHumanPlayers );
function CheckAndDrawRemainingZedIcons();

defaultproperties
{
    MaxNonCriticalMessages=2
    
    HUDClass=class'ClassicMoviePlayer_HUD'
    ChatBoxClass=class'UI_MainChatBox'
    SpectatorInfoClass=class'UIR_SpectatorInfoBox'
    ScoreboardClass=class'KFScoreBoard'
    
    DefaultHudMainColor=(R=0,B=0,G=0,A=195)
    DefaultHudOutlineColor=(R=200,B=15,G=15,A=195)
    DefaultFontColor=(R=255,B=50,G=50,A=255)
    
    TraderArrow=Texture2D'UI_Objective_Tex.UI_Obj_World_Loc'
    VoiceChatIcon=Texture2D'UI_HUD.voip_icon'
    
    InventoryFadeTime=1.25
    InventoryFadeInTime=0.1
    InventoryFadeOutTime=0.15
    
    InventoryX=0.35
    InventoryY=0.025
    InventoryBoxWidth=0.1
    InventoryBoxHeight=0.075
    BorderSize=0.005
    
    PerkIconSize=16
    
    QuickSyringeDisplayTime=5.0
    QuickSyringeFadeInTime=1.0
    QuickSyringeFadeOutTime=0.5    
    
    NonCriticalMessageDisplayTime=3.0
    NonCriticalMessageFadeInTime=0.65
    NonCriticalMessageFadeOutTime=0.5
}
