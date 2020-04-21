class KFHUDInterface extends KFGFxHudWrapper
    config(ClassicHUD);
   
const MAX_WEAPON_GROUPS = 4;
const HUDBorderSize = 3;

const PHASE_DONE = -1;
const PHASE_SHOWING = 0;
const PHASE_DELAYING = 1;
const PHASE_HIDING = 2;

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

enum EDamageTypes
{
    DMG_Fire,
    DMG_Toxic,
    DMG_Bleeding,
    DMG_EMP,
    DMG_Freeze,
    DMG_Flashbang,
    DMG_Generic,
    DMG_High,
    DMG_Medium,
    DMG_Unspecified
};

enum PopupPosition 
{
    PP_BOTTOM_CENTER,
    PP_BOTTOM_LEFT,
    PP_BOTTOM_RIGHT,
    PP_TOP_CENTER,
    PP_TOP_LEFT,
    PP_TOP_RIGHT
};

enum EPriorityAlignment
{
    PR_TOP,
    PR_BOTTOM
};

enum EPriorityAnimStyle
{
    ANIM_SLIDE,
    ANIM_DROP
};

var config enum PlayerInfo
{
    INFO_CLASSIC,
    INFO_LEGACY,
    INFO_MODERN
} PlayerInfoType; 

struct InventoryCategory
{
    var array<KFWeapon> Items;
    var int ItemCount;
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
    var string Item,IconURL;
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
    var bool bDamage,bLocal,bPlayerDeath,bSuicide;
    var int Counter;
    var Class Type;
    var string Name;
    var PlayerReplicationInfo OwnerPRI;
    var float MsgTime,XPosition,CurrentXPosition;
    var color MsgColor;
};
var transient array<FKillMessageType> KillMessages;

var array<KFPlayerReplicationInfo> TalkerPRIs;

var config int HealthBarFullVisDist, HealthBarCutoffDist;
var int PerkIconSize;
var config int MaxPerkStars, MaxStarsPerRow;
var int PlayerScore, OldPlayerScore;
var float TimeX;
var config bool bLightHUD, bHideWeaponInfo, bHidePlayerInfo, bHideDosh, bDisableHiddenPlayers, bDrawRegenBar, bShowSpeed, bDisableLastZEDIcons, bDisablePickupInfo, bDisableLockOnUI, bDisableRechargeUI, bModernScoreboard, bShowXPEarned, bNoConsoleReplacement;
var transient bool bChatOpen;
var transient bool bInterpolating, bDisplayingProgress, bNeedsRepLinkUpdate, bConfirmDisconnect, bObjectReplicationFinished, bReplicatedColorTextures;
var transient float LevelProgressBar, VisualProgressBar;
var transient ClientPerkRepLink ClientRep;
var config Color HudMainColor, HudOutlineColor, FontColor;
var Color DefaultHudMainColor, DefaultHudOutlineColor, DefaultFontColor;
var array<Color> DamageMsgColors;
var Texture HealthIcon, ArmorIcon, WeightIcon, GrenadesIcon, DoshIcon, ClipsIcon, BulletsIcon, BurstBulletIcon, AutoTargetIcon, ProgressBarTex, DoorWelderBG;
var Texture WaveCircle, BioCircle;
var Texture ArrowIcon, FlameIcon, FlameTankIcon, FlashlightIcon, FlashlightOffIcon, RocketIcon, BoltIcon, M79Icon, PipebombIcon, SingleBulletIcon, SyringIcon, SawbladeIcon, DoorWelderIcon;
var Texture TraderBox, TraderArrow, TraderArrowLight;
var Texture VoiceChatIcon;

var bool bDisplayInventory;
var float InventoryFadeTime, InventoryFadeStartTime, InventoryFadeInTime, InventoryFadeOutTime, InventoryX, InventoryY, InventoryBoxWidth, InventoryBoxHeight, BorderSize;
var Texture InventoryBackgroundTexture, SelectedInventoryBackgroundTexture;
var int SelectedInventoryCategory, SelectedInventoryIndex;
var KFWeapon SelectedInventory;

var bool bFinalCountdown;
var byte FinalCountTime;

var int CurrentRhythmCount,CurrentRhythmMax;
var Texture2D RhythmHUDIcon;

struct FHealthBarInfo
{
    var float LastHealthUpdate,HealthUpdateEndTime;
    var int OldBarHealth,OldHealth;
    var bool bDrawingHistory;
};
var array<FHealthBarInfo> HealthBarDamageHistory;
var int DamageHistoryNum;

var Texture VictoryScreen, DefeatScreen, VictoryScreenOverlay, DefeatScreenOverlay;
var transient bool bVictory, bCheckedForWin;

var class<UI_MainChatBox> ChatBoxClass;
var UI_MainChatBox ChatBox;

var class<UIR_SpectatorInfoBox> SpectatorInfoClass;
var UIR_SpectatorInfoBox SpectatorInfo;

var class<UIR_VoiceComms> VoiceCommsClass;
var UIR_VoiceComms VoiceComms;

var class<KFScoreBoard> ScoreboardClass;
var KFScoreBoard Scoreboard;

var int MaxNonCriticalMessages;
var float NonCriticalMessageDisplayTime,NonCriticalMessageFadeInTime,NonCriticalMessageFadeOutTime;

struct FCritialMessage
{
    var string Text, Delimiter;
    var float StartTime;
    var bool bHighlight,bUseAnimation;
    var int TextAnimAlpha;
};
var transient array<FCritialMessage> NonCriticalMessages;

struct FPriorityMessage
{
    var string PrimaryText, SecondaryText;
    var float StartTime, SecondaryStartTime, LifeTime, FadeInTime, FadeOutTime;
    var EPriorityAlignment SecondaryAlign;
    var EPriorityAnimStyle PrimaryAnim, SecondaryAnim;
    var Texture2D Icon,SecondaryIcon;
    var Color IconColor,SecondaryIconColor;
    var bool bSecondaryUsesFullLength;
    
    structdefaultproperties
    {
        FadeInTime=0.15f
        FadeOutTime=0.15f
        LifeTime=5.f
        IconColor=(R=255,G=255,B=255,A=255)
        SecondaryIconColor=(R=255,G=255,B=255,A=255)
    }
};
var transient FPriorityMessage PriorityMessage;
var int CurrentPriorityMessageA,CurrentSecondaryMessageA;

var bool bDisplayQuickSyringe;
var float QuickSyringeStartTime, QuickSyringeDisplayTime, QuickSyringeFadeInTime, QuickSyringeFadeOutTime;

var bool bDrawingPortrait;
var float PortraitTime, PortraitX;
var Texture TraderPortrait, PatriarchPortrait, LockheartPortrait, UnknownPortrait, TraderPortraitBox;

var array<Color> BattlePhaseColors;

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

struct FScriptedPawnCache
{
    var KFPawn_Scripted Pawn;
    var Texture2D Icon;
};
var array<FScriptedPawnCache> ScriptedPawnCache;

var Texture2D BossInfoIcon;

struct XPEarnedS
{
    var float StartTime,XPos,YPos,RandX,RandY;
    var bool bInit;
    var int XP;
    var Texture2D Icon;
    var Color IconColor;
};
const XPEARNED_COUNT = 32;
var XPEarnedS XPPopups[XPEARNED_COUNT];
var int NextXPPopupIndex;
var float XPFadeOutTime;

struct HUDBoxRenderInfo
{
    var int JustificationPadding;
    var Color TextColor, OutlineColor, BoxColor;
    var Texture IconTex;
    var float Alpha;
    var float IconScale;
    var array<String> StringArray;
    var bool bUseOutline, bUseRounded, bRoundedOutline, bHighlighted;
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
var const Color BlueColor;

struct PopupDamageInfo
{
    var int Damage;
    var float HitTime;
    var Vector HitLocation;
    var byte Type;
    var color FontColor;
    var vector RandVect;
};
const DAMAGEPOPUP_COUNT = 32;
var PopupDamageInfo DamagePopups[DAMAGEPOPUP_COUNT];
var int NextDamagePopupIndex;
var float DamagePopupFadeOutTime;
var config bool bEnableDamagePopups;

struct PopupMessage 
{
    var string Header;
    var string Body;
    var Texture2D Image;
    var PopupPosition MsgPosition;
};
var privatewrite int NotificationPhase;
var privatewrite array<PopupMessage> MessageQueue;
var privatewrite string NewLineSeparator;
var float NotificationWidth, NotificationHeight, NotificationPhaseStartTime, NotificationIconSpacing, NotificationShowTime, NotificationHideTime, NotificationHideDelay, NotificationBorderSize;
var Texture NotificationBackground;

var Texture2D MedicLockOnIcon;
var float MedicLockOnIconSize, LockOnStartTime, LockOnEndTime;
var Color MedicLockOnColor, MedicPendingLockOnColor;
var KFPawn OldTarget;

var ClassicDroppedPickup WeaponPickup;
var float MaxWeaponPickupDist;
var float WeaponPickupScanRadius;
var float ZedScanRadius;
var Texture2D WeaponAmmoIcon, WeaponWeightIcon;
var float WeaponIconSize;
var Color WeaponIconColor,WeaponOverweightIconColor;

var rotator MedicWeaponRot;
var float MedicWeaponHeight;
var Color MedicWeaponBGColor;
var Color MedicWeaponNotChargedColor, MedicWeaponChargedColor;

var float ScaledBorderSize;

var transient KF2GUIController GUIController;
var transient GUIStyleBase GUIStyle;

var array<KFGUI_Base> HUDWidgets;

var transient vector PLCameraLoc,PLCameraDir;
var transient rotator PLCameraRot;

var class<Console> ConsoleClass;
var transient KF2GUIInput CustomInput;
var transient PlayerInput BackupInput;
var transient GameViewportClient ClientViewport;
var transient Console OrgConsole;
var transient Console NewConsole;

var transient bool bIsMenu;

simulated function PostBeginPlay()
{
    local bool bSaveConfig;
    
    if( iConfigVersion <= 0 )
    {
        MaxPerkStars = 5;
        MaxStarsPerRow = 5;
        
        HudMainColor = DefaultHudMainColor;
        HudOutlineColor = DefaultHudOutlineColor;
        FontColor = DefaultFontColor;
        
        bLightHUD = false;
        bHideWeaponInfo = false;
        bHidePlayerInfo = false;
        bHideDosh = false;
        
        iConfigVersion++;
        bSaveConfig = true;
    }
    
    if( iConfigVersion <= 1 )
    {
        bDisableHiddenPlayers = false;
        bEnableDamagePopups = true;
        bDrawRegenBar = true;
        bShowSpeed = false;
        bDisableLastZEDIcons = false;
        bDisablePickupInfo = false;
        bDisableLockOnUI = false;
        bDisableRechargeUI = false;
        bModernScoreboard = true;
        bShowXPEarned = true;
        bNoConsoleReplacement = false;
        PlayerInfoType = INFO_CLASSIC;
        HealthBarFullVisDist = 350.f;
        HealthBarCutoffDist = 3500.f;
        iConfigVersion++;
        bSaveConfig = true;
    }
    
    if( bSaveConfig )
        SaveConfig();
    
    bIsMenu = class'WorldInfo'.static.IsMenuLevel();
    if( !bIsMenu )
    {
        OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
        if( OnlineSub!=None )
        {
            OnlineSub.AddOnInventoryReadCompleteDelegate(SearchInventoryForNewItem);
            SetTimer(60,false,'SearchInventoryForNewItem');
        }
    
        SetTimer(300 + FRand()*120.f, false, 'CheckForItems');
        SetTimer(0.1f, true, 'BuildCacheItems');
        SetTimer(0.1f, true, 'CheckForWeaponPickup');
    }
    
    Super.PostBeginPlay();
    
    PlayerOwner.PlayerInput.OnReceivedNativeInputKey = NotifyInputKey;
    PlayerOwner.PlayerInput.OnReceivedNativeInputAxis = NotifyInputAxis;
    PlayerOwner.PlayerInput.OnReceivedNativeInputChar = NotifyInputChar;
    
    ClassicPlayerOwner = ClassicPlayerController(PlayerOwner);
    
    ClientViewport = LocalPlayer(PlayerOwner.Player).ViewportClient;
    if( ClientViewport != None )
        CreateAndSetConsoleReplacment();
}

function CreateAndSetConsoleReplacment();
/*{
    if( (bNoConsoleReplacement && !bIsMenu) || ConsoleClass == None )
        return;
        
    if( NewConsole == None )
    {
        NewConsole = New(ClientViewport) ConsoleClass;
        NewConsole.Initialized();
        OrgConsole = ClientViewport.ViewportConsole;
    }

    OrgConsole.OnReceivedNativeInputKey = NewConsole.InputKey;
    OrgConsole.OnReceivedNativeInputChar = NewConsole.InputChar;
    
    ClientViewport.ViewportConsole = NewConsole;
    
    if( UI_Console(NewConsole) != None )
        UI_Console(NewConsole).OriginalConsole = OrgConsole;
}*/

function ResetHUDColors()
{
    HudMainColor = DefaultHudMainColor;
    HudOutlineColor = DefaultHudOutlineColor;
    FontColor = DefaultFontColor;
    SaveConfig();
    SetupHUDTextures();
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

function BuildCacheItems()
{
    local KFDoorActor Door;
    local FDoorCache MyCache;
    local KFPawn_Scripted Pawn;
    local KFPawn KFPawn;
    local FScriptedPawnCache ScriptedCache;
    
    foreach DynamicActors(class'KFDoorActor',Door)
    {
        if( DoorCache.Find('Door', Door) != INDEX_NONE )
            continue;
            
        MyCache.Door = Door;
        MyCache.WeldUILocation = Door.WeldUILocation;
        
        DoorCache.AddItem(MyCache);
    }
    
    foreach WorldInfo.AllPawns( class'KFPawn', KFPawn )
    {
        Pawn = KFPawn_Scripted(KFPawn);
        if( Pawn != None && ScriptedPawnCache.Find('Pawn', Pawn) == INDEX_NONE && Pawn.ShouldShowOnHUD() )
        {
            ScriptedCache.Pawn = Pawn;
            ScriptedCache.Icon = Texture2D(DynamicLoadObject(Pawn.GetIconPath(),class'Texture2D'));
            
            ScriptedPawnCache.AddItem(ScriptedCache);
        }
    }
}

simulated function CheckForWeaponPickup()
{
    if( !bDisablePickupInfo )
        WeaponPickup = GetWeaponPickup();
}

simulated function ClassicDroppedPickup GetWeaponPickup()
{
    local ClassicDroppedPickup KFDP, BestKFDP;
    local int KFDPCount, ZedCount;
    local vector EndTrace, HitLocation, HitNormal;
    local Actor HitActor;
    local float DistSq, BestDistSq;
    local KFPawn_Monster KFPM;

    if (KFPlayerOwner == None || !KFPlayerOwner.WorldInfo.GRI.bMatchHasBegun)
        return None;

    EndTrace = PLCameraLoc + PLCameraDir * MaxWeaponPickupDist;
    HitActor = KFPlayerOwner.Trace(HitLocation, HitNormal, EndTrace, PLCameraLoc);
    
    if (HitActor == None)
        return None;
        
    foreach KFPlayerOwner.CollidingActors(class'KFPawn_Monster', KFPM, ZedScanRadius, HitLocation)
    {
        if (KFPM.IsAliveAndWell())
            return None;
        
        ZedCount++;
        if (ZedCount > 20)
            return None;
    }
        
    BestDistSq = WeaponPickupScanRadius * WeaponPickupScanRadius;

    foreach KFPlayerOwner.CollidingActors(class'ClassicDroppedPickup', KFDP, WeaponPickupScanRadius, HitLocation)
    {
        if (KFDP.Velocity.Z == 0 && ClassIsChildOf(KFDP.InventoryClass, class'KFWeapon'))
        {
            DistSq = VSizeSq(KFDP.Location - HitLocation);
            if (DistSq < BestDistSq)
            {
                BestKFDP = KFDP;
                BestDistSq = DistSq;
            }
        }

        KFDPCount++;
        if (KFDPCount > 2)
            break;
    }

    return BestKFDP;
}

function PostRender()
{
    if( !bObjectReplicationFinished )
    {
        SetupHUDTextures();
        return;
    }
    
    if( BossRef != None && BossInfoIcon == None )
    {
        BossInfoIcon = Texture2D(DynamicLoadObject(BossRef.GetIconPath(),class'Texture2D'));
    }
    else if( BossRef == None && BossInfoIcon != None )
    {
        BossInfoIcon = None;
    }
    
    if( !bReplicatedColorTextures && HudOutlineColor != DefaultHudOutlineColor )
    {
        bReplicatedColorTextures = true;
        SetupHUDTextures(true);
    }
    
    if( GUIController!=None && PlayerOwner.PlayerInput==None )
        GUIController.NotifyLevelChange();
        
    if( GUIController==None || GUIController.bIsInvalid )
    {
        GUIController = Class'KFClassicMode.KF2GUIController'.Static.GetGUIController(PlayerOwner);
        if( GUIController!=None )
        {
            GUIStyle = GUIController.CurrentStyle;
            LaunchHUDMenus();
        }
    }
    GUIStyle.Canvas = Canvas;
    GUIStyle.PickDefaultFontSize(Canvas.ClipY);
    
    ScaledBorderSize = FMax(GUIStyle.ScreenScale(HUDBorderSize), 1.f);
    
    Super.PostRender();
    
    PlayerOwner.GetPlayerViewPoint(PLCameraLoc,PLCameraRot);
    PLCameraDir = vector(PLCameraRot);
    
    if( ClassicPlayerOwner.bIsSpectating )
    {
        RenderVisibleSpectatorInfo();
    }
    
    if( HUDWidgets.Length > 0 )
    {
        RenderHUDWidgets();
    }
    
    DamageHistoryNum = 0;
}

function RenderVisibleSpectatorInfo()
{
    local float FontScalar, XL, YL, BoxW, BoxH, BoxX, BoxY, TX, TY;
    local string UseKeyName,ItemInfo;
    local KFPawn Pawn;
    
    Canvas.Font = GUIStyle.PickFont(FontScalar);
    FontScalar += 0.3f;
    
    Pawn = KFPawn(ClassicPlayerOwner.ViewTarget);
    if( Pawn != None )
        ItemInfo = "heal player";
    else ItemInfo = "fire laser";
    
    UseKeyName = "Tap ["@class'KFLocalMessage_Interaction'.static.GetKeyBind(PlayerOwner, IMT_DoshActivate)@"] to "$ItemInfo$".";
    Canvas.TextSize(UseKeyName, XL, YL, FontScalar, FontScalar);
    
    BoxW = XL+(ScaledBorderSize*2)+16;
    BoxH = YL+(ScaledBorderSize*2)+16;
    BoxX = Canvas.ClipX - BoxW - (ScaledBorderSize*2) - 8;
    BoxY = Canvas.ClipY - BoxH - (ScaledBorderSize*2) - 8;
    GUIStyle.DrawRoundedBoxOutlined(ScaledBorderSize, BoxX, BoxY, BoxW, BoxH, HudMainColor, HudOutlineColor);
    
    TX = BoxX + (BoxW/2) - (XL/2);
    TY = BoxY + (BoxH/2) - (YL/2) - 8;
    
    Canvas.SetPos(TX,TY);
    Canvas.SetDrawColor(255,255,255,255);
    Canvas.DrawText(UseKeyName,, FontScalar, FontScalar);
    
    if( ClassicPlayerOwner.NextFireTimer>WorldInfo.TimeSeconds )
    {
        Canvas.SetDrawColor(255,0,0,255);
        GUIStyle.DrawWhiteBox((ClassicPlayerOwner.NextFireTimer-WorldInfo.TimeSeconds)*ClassicPlayerOwner.NeqFireTime, 8);
    }
}

delegate int SortRenderDistance(KFPawn_Human PawnA, KFPawn_Human PawnB)
{
    if( PawnA == None || PawnB == None )
        return -1;
    return VSizeSq(PawnA.Location - PlayerOwner.Location) < VSizeSq(PawnB.Location - PlayerOwner.Location) ? -1 : 0;
}

function DrawHUD()
{
    local KFPawn_Human KFPH;
    local KFPawn_Scripted KFPS;
    local vector PlayerPartyInfoLocation;
    local array<PlayerReplicationInfo> VisibleHumanPlayers;
    local array<sHiddenHumanPawnInfo> HiddenHumanPlayers;
    local float ThisDot;
    local vector TargetLocation;
    local Actor LocActor;
    local FScriptedPawnCache SPawnCache;
    local int i;

    if( KFPlayerOwner != none && KFPlayerOwner.Pawn != None && KFPlayerOwner.Pawn.Weapon != None )
    {
        KFPlayerOwner.Pawn.Weapon.DrawHUD( self, Canvas );
    }

    Super(HUD).DrawHUD();
    
    Canvas.EnableStencilTest(true);
    
    if( WeaponPickup != None )
    {
        DrawWeaponPickupInfo();
    }
    
    if( bEnableDamagePopups )
    {
        DrawDamage();
    }
    
    DrawDoorHealthBars();
    
    if( KFPlayerOwner != None && KFPlayerOwner.Pawn != None )
    {
        if( !bDisableLockOnUI && KFWeap_MedicBase(KFPlayerOwner.Pawn.Weapon) != None )
        {
            DrawMedicWeaponLockOn(KFWeap_MedicBase(KFPlayerOwner.Pawn.Weapon));
        }
        
        if( !bDisableRechargeUI && !KFPlayerOwner.bCinematicMode )
            DrawMedicWeaponRecharge();
    }
    
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
    
    Canvas.EnableStencilTest(false);
    
    DrawTraderIndicator();

    if( KFGRI == None )
    {
        KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
    }

    if( KFPlayerOwner == None )
    {
        return;
    }
    
    if( !KFPlayerOwner.bCinematicMode )
    {
        LocActor = KFPlayerOwner.ViewTarget != none ? KFPlayerOwner.ViewTarget : KFPlayerOwner;

        if( KFPlayerOwner != none && (bDrawCrosshair || bForceDrawCrosshair || KFPlayerOwner.GetTeamNum() == 255) )
        {
            DrawCrosshair();
        }

        if( PlayerOwner.GetTeamNum() == 0 )
        {
            Canvas.EnableStencilTest(true);
            
            foreach WorldInfo.AllPawns( class'KFPawn_Human', KFPH )
            {
                if( KFPH.IsAliveAndWell() && KFPH != KFPlayerOwner.Pawn && KFPH.Mesh.SkeletalMesh != none && KFPH.Mesh.bAnimTreeInitialised )
                {
                    PlayerPartyInfoLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,1) );
                    if(`TimeSince(KFPH.Mesh.LastRenderTime) < 0.2f && Normal(PlayerPartyInfoLocation - PLCameraLoc) dot PLCameraDir > 0.f )
                    {
                        if( DrawFriendlyHumanPlayerInfo(KFPH) )
                        {
                            VisibleHumanPlayers.AddItem( KFPH.PlayerReplicationInfo );
                        }
                        else
                        {
                            HiddenHumanPlayers.Insert( 0, 1 );
                            HiddenHumanPlayers[0].HumanPawn = KFPH;
                            HiddenHumanPlayers[0].HumanPRI = KFPH.PlayerReplicationInfo;
                        }
                    }
                    else
                    {
                        HiddenHumanPlayers.Insert( 0, 1 );
                        HiddenHumanPlayers[0].HumanPawn = KFPH;
                        HiddenHumanPlayers[0].HumanPRI = KFPH.PlayerReplicationInfo;
                    }
                }
            }

            foreach ScriptedPawnCache(SPawnCache)
            {
                KFPS = SPawnCache.Pawn;
                if (KFPS.ShouldShowOnHUD())
                {
                    PlayerPartyInfoLocation = KFPS.Mesh.GetPosition() + (KFPS.CylinderComponent.CollisionHeight * vect(0,0,1));
                    DrawScriptedPawnInfo(KFPS, Normal(PlayerPartyInfoLocation - PLCameraLoc) dot PLCameraDir, `TimeSince(KFPS.Mesh.LastRenderTime) < 0.2f);
                }
            }

            if( !KFGRI.bHidePawnIcons )
            {
                CheckAndDrawHiddenPlayerIcons( VisibleHumanPlayers, HiddenHumanPlayers );
                CheckAndDrawRemainingZedIcons();

                if(KFGRI.CurrentObjective != none && KFGRI.ObjectiveInterface != none)
                {
                    KFGRI.ObjectiveInterface.DrawHUD(self, Canvas);

                    TargetLocation = KFGRI.ObjectiveInterface.GetIconLocation();
                    ThisDot = Normal((TargetLocation + (class'KFPawn_Human'.default.CylinderComponent.CollisionHeight * vect(0, 0, 1))) - PLCameraLoc) dot PLCameraDir;
                
                    if (ThisDot > 0 &&  
                        KFGRI.ObjectiveInterface.ShouldShowObjectiveHUD() &&
                        (!KFGRI.ObjectiveInterFace.HasObjectiveDrawDistance() || VSizeSq(TargetLocation - LocActor.Location) < MaxDrawDistanceObjective))
                    {
                        DrawObjectiveHUD();
                    }
                }
            }

            Canvas.EnableStencilTest(false);
        }
    }
    
    if( PlayerOwner != None )
    {
        RenderKFHUD(KFPawn_Human(PlayerOwner.Pawn));
    }
     
    if( KillMessages.Length > 0 )
    {
        RenderKillMsg();
    }
    
    if( NonCriticalMessages.Length > 0 )
    {
        for( i=0; i<NonCriticalMessages.Length; ++i )
        {
            DrawNonCritialMessage(i, NonCriticalMessages[i], Canvas.ClipX * 0.5, Canvas.ClipY * 0.9);
        }
    }
    
    if( PriorityMessage != default.PriorityMessage )
    {
        DrawPriorityMessage();
    }

    if( bDrawingPortrait )
    {
        DrawPortrait();
    }
    
    if ( NotificationPhase != PHASE_DONE ) 
    {
        DrawAchievmentInfo();
    }
    
    if( BossRef != None && BossRef.GetMonsterPawn().IsAliveAndWell() )
    {
        DrawBossHealthBars();
    }
    else if( ScriptedPawnCache.Length > 0 )
    {
        DrawEscortHealthBars();
    }
    
    if( NewItems.Length > 0 )
    {
        DrawItemsList();
    }
    
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
    
    if( KFGRI != None && KFGRI.bMatchIsOver )
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
}

function LaunchHUDMenus()
{
    if( !ClassicPlayerOwner.PlayerReplicationInfo.bOnlySpectator )
    {
        ClassicPlayerOwner.GUIController = GUIController;
        ClassicPlayerOwner.OpenLobbyMenu();
    }
    
    if( bIsMenu )
        return;
    
    ChatBox = UI_MainChatBox(GUIController.InitializeHUDWidget(ChatBoxClass));
    ChatBox.SetVisible(false);
    
    SpectatorInfo = UIR_SpectatorInfoBox(GUIController.InitializeHUDWidget(SpectatorInfoClass));
    SpectatorInfo.SetSpectatedPRI(PlayerOwner.PlayerReplicationInfo);
    
    VoiceComms = UIR_VoiceComms(GUIController.InitializeHUDWidget(VoiceCommsClass));
    VoiceComms.SetVisibility(false);
    
    Scoreboard = KFScoreBoard(GUIController.InitializeHUDWidget(ScoreboardClass));
    Scoreboard.SetVisibility(false);
}

function SetupHUDTextures(optional bool bUseColorIcons)
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
        
        HealthIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[146]) : Texture2D(RepObject.ReferencedObjects[27]);
        ArmorIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[149]) : Texture2D(RepObject.ReferencedObjects[31]);
        WeightIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[152]) : Texture2D(RepObject.ReferencedObjects[34]);
        GrenadesIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[142]) : Texture2D(RepObject.ReferencedObjects[23]);
        DoshIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[148]) : Texture2D(RepObject.ReferencedObjects[30]);
        BulletsIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[136]) : Texture2D(RepObject.ReferencedObjects[17]);
        ClipsIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[131]) : Texture2D(RepObject.ReferencedObjects[11]);
        BurstBulletIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[137]) : Texture2D(RepObject.ReferencedObjects[18]);
        AutoTargetIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[133]) : Texture2D(RepObject.ReferencedObjects[13]);
        
        ArrowIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[132]) : Texture2D(RepObject.ReferencedObjects[12]);
        FlameIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[139]) : Texture2D(RepObject.ReferencedObjects[19]);
        FlameTankIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[138]) : Texture2D(RepObject.ReferencedObjects[20]);
        FlashlightIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[141]) : Texture2D(RepObject.ReferencedObjects[21]);
        FlashlightOffIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[140]) : Texture2D(RepObject.ReferencedObjects[22]);
        RocketIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[143]) : Texture2D(RepObject.ReferencedObjects[24]);
        BoltIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[144]) : Texture2D(RepObject.ReferencedObjects[25]);
        M79Icon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[145]) : Texture2D(RepObject.ReferencedObjects[26]);
        PipebombIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[147]) : Texture2D(RepObject.ReferencedObjects[29]);
        SingleBulletIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[150]) : Texture2D(RepObject.ReferencedObjects[32]);
        SyringIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[151]) : Texture2D(RepObject.ReferencedObjects[33]);
        SawbladeIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[153]) : Texture2D(RepObject.ReferencedObjects[78]);
        
        TraderBox = Texture2D(RepObject.ReferencedObjects[16]);
        
        WaveCircle = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[134]) : Texture2D(RepObject.ReferencedObjects[15]);
        BioCircle = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[135]) : Texture2D(RepObject.ReferencedObjects[14]);
        
        DoorWelderBG = TraderBox;
        DoorWelderIcon = bUseColorIcons ? Texture2D(RepObject.ReferencedObjects[154]) : Texture2D(RepObject.ReferencedObjects[88]);
        
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
    if( KFGRI != None )
    {
        if( KFGRI.bTraderIsOpen )
        {
            return GUIStyle.GetTimeString(KFGRI.GetTraderTimeRemaining());
        }
        else if( KFGRI.bWaveIsActive )
        {
            if( KFGRI.IsBossWave() )
            {
                return class'KFGFxHUD_WaveInfo'.default.BossWaveString;
            }
            else if( KFGRI.IsEndlessWave() )
            {
                return Chr(0x221E);
            }
            else if( KFGRI.bMatchIsOver )
            {
                return "---";
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
    local float XL, YL, IconXL, IconYL, IconW, TextX, TextY;
    local bool bUseAlpha;
    local int i;
    local FontRenderInfo FRI;
    local Color BoxColor, OutlineColor, TextColor, BlankColor;
    
    FRI.bClipText = true;
    FRI.bEnableShadow = true;
    
    bUseAlpha = HBRI.Alpha != -1.f;
    BoxColor = HBRI.BoxColor == BlankColor ? HudMainColor : HBRI.BoxColor;
    OutlineColor = HBRI.OutlineColor == BlankColor ? HudOutlineColor : HBRI.OutlineColor;
    TextColor = HBRI.TextColor == BlankColor ? FontColor : HBRI.TextColor;
    
    if( bUseAlpha )
    {
        BoxColor.A = byte(Min(HBRI.Alpha, HudMainColor.A));
        OutlineColor.A = byte(Min(HBRI.Alpha, HudOutlineColor.A));
        TextColor.A = byte(HBRI.Alpha);
    }
    
    if( !bLightHUD )
    {
        if( HBRI.bUseRounded )
        {
            if( HBRI.bHighlighted )
            {
                if( HBRI.bRoundedOutline )
                {
                    GUIStyle.DrawOutlinedBox(X+(ScaledBorderSize*2), Y, Width-(ScaledBorderSize*4), Height, ScaledBorderSize, BoxColor, OutlineColor);
                }
                else
                {
                    Canvas.DrawColor = BoxColor;
                    Canvas.SetPos(X+(ScaledBorderSize*2), Y);
                    GUIStyle.DrawWhiteBox(Width-(ScaledBorderSize*4), Height);
                }
                
                GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, X, Y, ScaledBorderSize*2, Height, OutlineColor, true, false, true, false);
                GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, X+Width-(ScaledBorderSize*2), Y, ScaledBorderSize*2, Height, OutlineColor, false, true, false, true);
            }
            else
            {
                if( HBRI.bRoundedOutline )
                    GUIStyle.DrawRoundedBoxOutlined(ScaledBorderSize, X, Y, Width, Height, BoxColor, OutlineColor);
                else GUIStyle.DrawRoundedBox(ScaledBorderSize*2, X, Y, Width, Height, BoxColor);
            }
        }
        else GUIStyle.DrawOutlinedBox(X, Y, Width, Height, ScaledBorderSize, BoxColor, OutlineColor);
    }
    
    if( HBRI.IconTex != None )
    {
        if( HBRI.IconScale == 1.f )
        {
            HBRI.IconScale = Height;
        }
        
        IconW = HBRI.IconScale - (HBRI.bUseRounded ? 0.f : ScaledBorderSize);
        
        IconXL = X + (IconW/2);
        IconYL = Y + (Height / 2) - (IconW / 2);
        
        if( HudOutlineColor != DefaultHudOutlineColor )
        {
            Canvas.DrawColor = HudOutlineColor;
            if( !bUseAlpha ) 
                Canvas.DrawColor.A = 255;
        }
        else Canvas.SetDrawColor(255, 255, 255, bUseAlpha ? byte(HBRI.Alpha) : 255);
        
        Canvas.SetPos(IconXL, IconYL);
        Canvas.DrawRect(IconW, IconW, HBRI.IconTex);
    }

    Canvas.DrawColor = TextColor;
    
    if( HBRI.StringArray.Length < 1 )
    {
        Canvas.TextSize(GUIStyle.StripTextureFromString(Text), XL, YL, TextScale, TextScale);
        
        if( HBRI.IconTex != None )
            TextX = IconXL + IconW + (ScaledBorderSize*4);
        else TextX = X + (Width / 2) - (XL / 2);
        
        TextY = Y + (Height / 2) - (YL / 2);
        if( !HBRI.bUseRounded )
        {
            TextY -= (ScaledBorderSize/2);
            
            // Always one pixel off, could not find the source
            if( Canvas.SizeX != 1920 )
                TextY -= GUIStyle.ScreenScale(1.f);
        }
        
        GUIStyle.DrawTexturedString(Text, TextX, TextY, TextScale, FRI, HBRI.bUseOutline);
    }
    else
    {
        TextY = Y + ((Height*0.05)/2);
        
        for( i=0; i<HBRI.StringArray.Length; ++i )
        {
            Canvas.TextSize(GUIStyle.StripTextureFromString(HBRI.StringArray[i]), XL, YL, TextScale, TextScale);
            
            if( HBRI.IconTex != None )
                TextX = IconXL + IconW + (ScaledBorderSize*4);
            else TextX = X + (Width / 2) - (XL / 2);
            
            GUIStyle.DrawTexturedString(HBRI.StringArray[i], TextX, TextY, TextScale, FRI, HBRI.bUseOutline);
            TextY+=YL-(ScaledBorderSize/2);
        }
    }
    
    switch(HBRI.Justification)
    {
        case HUDA_Right:
            X += Width + GUIStyle.ScreenScale(HBRI.JustificationPadding) - ScaledBorderSize;
            break;
        case HUDA_Left:
            X -= Width + GUIStyle.ScreenScale(HBRI.JustificationPadding) - ScaledBorderSize;
            break;
        case HUDA_Top:
            Y += Height + GUIStyle.ScreenScale(HBRI.JustificationPadding) - ScaledBorderSize;
            break;
        case HUDA_Bottom:
            Y -= Height + GUIStyle.ScreenScale(HBRI.JustificationPadding) - ScaledBorderSize;
            break;
    }
}

function DrawDeployTime(byte RemainingTime)
{
    local float FontScalar, XL, YL;
    local byte Glow;
    local string S;
    
    RemainingTime = bFinalCountdown ? FinalCountTime : RemainingTime;
    
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
                //KFPlayerOwner.MyGFxHUD.PlaySoundFromTheme('PARTYWIDGET_COUNTDOWN', 'UI');
                KFPlayerOwner.PlayAKEvent(AkEvent'WW_UI_Menu.Play_PARTYWIDGET_COUNTDOWN');
            }
        }

        S = class'UI_LobbyMenu'.default.AutoCommence $ ":" @ GUIStyle.GetTimeString(RemainingTime);
        Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
        GUIStyle.DrawTextShadow(S, (Canvas.ClipX * 0.5f) - (XL * 0.5f), Canvas.ClipY * 0.05f, int( Canvas.ClipY / 360.f ), FontScalar);
    }
}

function RenderKFHUD(KFPawn_Human KFPH)
{
    local float scale_w, scale_w2, FontScalar, OriginalFontScalar, XL, YL, ObjYL, BoxXL, BoxYL, BoxSW, BoxSH, DoshXL, DoshYL, PerkXL, PerkYL, StarXL, StarYL, TempSize, ObjectiveH, SecondaryXL, SecondaryYL;
    local float PerkProgressSize, PerkProgressX, PerkProgressY;
    local byte PerkLevel;
    local int i, XPos, YPos, DrawCircleSize, FlashlightCharge, AmmoCount, MagCount, StarCount, CurrentScore, FadeAlpha, Index, ObjectiveSize, ObjectivePadding, ObjX, ObjY, bStatusWarning, bStatusNotification;
    local string CircleText, SubCircleText, WeaponName, TraderDistanceText, ObjectiveTitle, ObjectiveDesc, ObjectiveProgress, ObjectiveReward, ObjectiveStatusMessage;
    local bool bSingleFire, bHasSecondaryAmmo;
    local Texture2D PerkIcon, PerkStarIcon;
    local KFInventoryManager Inv;
    local KFPlayerReplicationInfo MyKFPRI;
    local KFWeapon CurrentWeapon;
    local KFTraderTrigger T;
    local KFWeap_Healer_Syringe S;
    local KFGFxObject_TraderItems TraderItems;
    local FontRenderInfo FRI;
    local Color HealthFontColor, OrgC;
    local HUDBoxRenderInfo HBRI;
    local KFInterface_MapObjective MapObjective;
    
    if( bIsMenu || KFPlayerOwner.bCinematicMode || ClassicPlayerOwner.LobbyMenu != None )
        return;
        
    if( KFGRI != None && !KFGRI.bMatchHasBegun && !KFGRI.bMatchIsOver && KFPawn_Customization(KFPlayerOwner.Pawn) == None )
    {
        DrawDeployTime(KFGRI.RemainingTime);
    }
    
    FRI.bClipText = true;
    FRI.bEnableShadow = true;
    
    scale_w = GUIStyle.ScreenScale(64);
    scale_w2 = GUIStyle.ScreenScale(32);
    
    BoxXL = SizeX * 0.015;
    BoxYL = SizeY * 0.935;
    
    BoxSW = SizeX * 0.0625;
    BoxSH = SizeY * 0.0425;
    
    // Trader/Wave info
    if( KFGRI != None )
    {
        CircleText = GetGameInfoText();
        SubCircleText = GetGameInfoSubText();
        
        if( CircleText != "" )
        {
           Canvas.Font = GUIStyle.PickFont(OriginalFontScalar, KFGRI.IsEndlessWave() ? FONT_INFINITE : FONT_NAME);
            
            FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(KFGRI.IsEndlessWave() ? 0.75 : 0.3);
            DrawCircleSize = GUIStyle.ScreenScale(128);
            
            if( !bLightHUD )
            {
                if( HudOutlineColor != DefaultHudOutlineColor )
                    Canvas.SetDrawColor(HudOutlineColor.R, HudOutlineColor.G, HudOutlineColor.B, 255);
                else Canvas.SetDrawColor(255, 255, 255, 255);
                
                Canvas.SetPos(Canvas.ClipX - DrawCircleSize, 2);
                Canvas.DrawRect(DrawCircleSize, DrawCircleSize, (KFGRI != None && KFGRI.bWaveIsActive) ? BioCircle : WaveCircle);
            }
            
            Canvas.TextSize(CircleText, XL, YL, FontScalar, FontScalar);
            
            XPos = Canvas.ClipX - DrawCircleSize/2 - (XL / 2);
            YPos = SubCircleText != "" ? DrawCircleSize/2 - (YL / 1.5) : DrawCircleSize/2 - YL / 2;
            
            Canvas.DrawColor = FontColor;
            if( bLightHUD )
            {
                GUIStyle.DrawTextShadow(CircleText, XPos, YPos, 1, FontScalar);
            }
            else
            {
                Canvas.SetPos(XPos, YPos);
                Canvas.DrawText(CircleText, , FontScalar, FontScalar, FRI);
            }
            
            if( SubCircleText != "" )
            {
                Canvas.Font = GUIStyle.PickFont(OriginalFontScalar, FONT_NAME);
                FontScalar = OriginalFontScalar;
                
                Canvas.TextSize(SubCircleText, XL, YL, FontScalar, FontScalar);
                
                XPos = Canvas.ClipX - DrawCircleSize/2 - (XL / 2);
                YPos = DrawCircleSize/2 + (YL / 2.5);
                
                if( bLightHUD )
                {
                    GUIStyle.DrawTextShadow(SubCircleText, XPos, YPos, 1, FontScalar);
                }
                else
                {
                    Canvas.SetPos(XPos, YPos);
                    Canvas.DrawText(SubCircleText, , FontScalar, FontScalar, FRI);
                }
            }
        }
    }
    
    if( !bShowHUD || KFPH == None )
        return;
        
    Inv = KFInventoryManager(KFPH.InvManager);
        
    Canvas.Font = GUIStyle.PickFont(OriginalFontScalar, FONT_NUMBER);
    FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.3);
    
    HBRI.IconScale = scale_w2;
    HBRI.Justification = HUDA_Right;
    HBRI.TextColor = FontColor;
    HBRI.bUseOutline = bLightHUD;
    
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
            
            Canvas.DrawColor = PlayerBarShadowColor;
            Canvas.SetPos(DoshXL+1, DoshYL+1);
            Canvas.DrawRect(scale_w, scale_w, DoshIcon);
            
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
                
                PlayerScore = Clamp(Lerp(PlayerScore, CurrentScore, `RealTimeSince(TimeX)), 0, CurrentScore);
                if( PlayerScore == CurrentScore )
                {
                    bInterpolating = false;
                    OldPlayerScore = CurrentScore;
                }
            }
            
            Canvas.TextSize(PlayerScore, XL, YL, FontScalar, FontScalar);
            Canvas.DrawColor = FontColor;
            GUIStyle.DrawTextShadow(PlayerScore, DoshXL + (DoshXL * 0.035), DoshYL + (scale_w / 2) - (YL / 2), 1, FontScalar);
        }
        
        // Draw Perk Info
        if( MyKFPRI.CurrentPerkClass != None && class<ClassicPerk_Base>(MyKFPRI.CurrentPerkClass) != None )
        {
            FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.15);
            PerkLevel = class<ClassicPerk_Base>(MyKFPRI.CurrentPerkClass).static.PreDrawPerk(Canvas, MyKFPRI.GetActivePerkLevel(), PerkIcon, PerkStarIcon);
            
            //Perk Icon
            PerkXL = SizeX - (SizeX - 12);
            PerkYL = SizeY * 0.8625;
            
            OrgC = Canvas.DrawColor;
            
            Canvas.DrawColor = PlayerBarShadowColor;
            Canvas.SetPos(PerkXL+1, PerkYL+1);
            Canvas.DrawRect(scale_w, scale_w, PerkIcon);
            
            Canvas.DrawColor = OrgC;
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
                    
                    Canvas.DrawColor = PlayerBarShadowColor;
                    Canvas.SetPos(StarXL+1, StarYL+1);
                    Canvas.DrawRect(PerkIconSize, PerkIconSize, PerkStarIcon);
                            
                    Canvas.DrawColor = OrgC;
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
            
            if( bShowXPEarned )
                DrawXPEarned(PerkProgressX + (PerkProgressSize/2), PerkProgressY-(PerkProgressSize*0.125f)-(ScaledBorderSize*2));
        }
    }
    
    // Trader Distance/Objective Container
    if( KFGRI != None )
    {
        if( KFGRI.OpenedTrader != None || KFGRI.NextTrader != None )
        {
            T = KFGRI.OpenedTrader != None ? KFGRI.OpenedTrader : KFGRI.NextTrader;
            if( T != None )
            {
                FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.3);
                
                TraderDistanceText = "Trader"$": "$int(VSize(T.Location - KFPH.Location) / 100.f)$"m";
                Canvas.TextSize(TraderDistanceText, XL, YL, FontScalar, FontScalar);
                
                Canvas.DrawColor = FontColor;
                GUIStyle.DrawTextShadow(TraderDistanceText, Canvas.ClipX*0.015, YL, 1, FontScalar);
            }
        }
        
        //Map Objectives
        MapObjective = KFInterface_MapObjective(KFGRI.CurrentObjective);
        if( MapObjective == None )
            MapObjective = KFInterface_MapObjective(KFGRI.PreviousObjective);
            
        if( MapObjective != None && (MapObjective.IsActive() || ((MapObjective.IsComplete() || MapObjective.HasFailedObjective()) && KFGRI.bWaveIsActive)) )
        {
            FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.155);
            
            ObjectivePadding = GUIStyle.ScreenScale(8);
            ObjectiveH = GUIStyle.ScreenScale(142);
            ObjectiveSize = ObjectiveH * 2.25;
            
            ObjX = Canvas.ClipX*0.015;
            ObjY = T != None ? (YL * 2) + ObjectivePadding : ObjectiveH;
            
            ObjectiveTitle = Localize("Objectives", "ObjectiveTitle", "KFGame");
            Canvas.TextSize(ObjectiveTitle, XL, ObjYL, FontScalar, FontScalar);

            if( !bLightHUD )
            {
                GUIStyle.DrawOutlinedBox(ObjX, ObjY, ObjectiveSize, ObjectiveH, ScaledBorderSize, HudMainColor, HudOutlineColor);
                GUIStyle.DrawOutlinedBox(ObjX, ObjY, ObjectiveSize, ObjYL, ScaledBorderSize, HudMainColor, HudOutlineColor);
            }
        
            // Objective Title
            XPos = ObjX + ObjectivePadding;
            YPos = ObjY - (ObjectivePadding / 2) + (ScaledBorderSize / 2) + 1;
        
            if( MapObjective.GetIcon() != None )
            {
                Canvas.DrawColor = FontColor;
                Canvas.SetPos(XPos + ScaledBorderSize, YPos + (ScaledBorderSize*2.5) + 0.5);
                Canvas.DrawTile(MapObjective.GetIcon(), ObjYL - (ScaledBorderSize*4), ObjYL - (ScaledBorderSize*4), 0, 0, 256, 256);
                
                XPos += (ObjYL - (ScaledBorderSize*2)) + ObjectivePadding;
            }
            
            Canvas.DrawColor = FontColor;
            
            if( bLightHUD )
            {
                GUIStyle.DrawTextShadow(ObjectiveTitle, XPos, YPos, 1, FontScalar);
            }
            else
            {
                Canvas.SetPos(XPos, YPos);
                Canvas.DrawText(ObjectiveTitle,, FontScalar, FontScalar, FRI);
            }
            
            // Objective Progress
            if( MapObjective.IsComplete() )
            {
                ObjectiveProgress = Localize("Objectives", "SuccessString", "KFGame");
                Canvas.SetDrawColor(0, 255, 0, 255);
            }
            else if( MapObjective.HasFailedObjective() )
            {
                ObjectiveProgress = Localize("Objectives", "FailedString", "KFGame");
                Canvas.SetDrawColor(255, 0, 0, 255);
            }
            else
            {
                ObjectiveProgress = MapObjective.GetProgressText();
                Canvas.DrawColor = FontColor;
            }
            
            if( MapObjective.GetProgressTextIsDosh() )
                ObjectiveProgress = Chr(208) $ ObjectiveProgress;
                
            Canvas.TextSize(ObjectiveProgress, XL, YL, FontScalar, FontScalar);
            
            XPos = ObjX + (ObjectiveSize - XL - ObjectivePadding);
            
            if( bLightHUD )
            {
                GUIStyle.DrawTextShadow(ObjectiveProgress, XPos, YPos, 1, FontScalar);
            }
            else
            {
                Canvas.SetPos(XPos, YPos);
                Canvas.DrawText(ObjectiveProgress,, FontScalar, FontScalar, FRI);
            }
            
            // Objective Reward
            Canvas.SetDrawColor(0, 255, 0, 255);
            FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.1);
        
            ObjectiveReward = Chr(208) $ (MapObjective.HasFailedObjective() ? 0 : MapObjective.GetDoshReward());
            Canvas.TextSize(ObjectiveReward, XL, YL, FontScalar, FontScalar);
            
            XPos = ObjX + (ObjectiveSize - XL - ObjectivePadding);
            YPos = ObjY + ((ObjectiveH-ObjYL)/2) + (YL/2);
            
            if( bLightHUD )
            {
                GUIStyle.DrawTextShadow(ObjectiveReward, XPos, YPos, 1, FontScalar);
            }
            else
            {
                Canvas.SetPos(XPos, YPos);
                Canvas.DrawText(ObjectiveReward,, FontScalar, FontScalar, FRI);
            }
            
            // Objective Description
            ObjectiveDesc = MapObjective.GetLocalizedShortDescription();
            if( MapObjective.IsComplete() || MapObjective.HasFailedObjective() )
                Canvas.DrawColor = FontColor * 0.5f;
            else Canvas.DrawColor = FontColor;
            
            YPos = ObjY + ((ObjectiveH-ObjYL)/1.5f) - (YL/1.5f);
            XPos = ObjX + ObjectivePadding;
            
            if( bLightHUD )
            {
                GUIStyle.DrawTextShadow(ObjectiveDesc, XPos, YPos, 1, FontScalar);
            }
            else
            {
                Canvas.SetPos(XPos, YPos);
                Canvas.DrawText(ObjectiveDesc,, FontScalar, FontScalar, FRI);
            }
            
            // Status Message for the Objective
            MapObjective.GetLocalizedStatus(ObjectiveStatusMessage, bStatusWarning, bStatusNotification);
            if( ObjectiveStatusMessage != "" )
            { 
                if( bool(bStatusWarning) )
                    Canvas.SetDrawColor(255, Clamp(Sin(WorldInfo.TimeSeconds * 12) * 200 + 200, 0, 200), 0, 255);
                else Canvas.DrawColor = FontColor;
                
                Canvas.TextSize(ObjectiveStatusMessage, XL, YL, FontScalar, FontScalar);
                
                XPos = ObjX + ObjectivePadding;
                YPos += YL;
                
                if( bLightHUD )
                {
                    GUIStyle.DrawTextShadow(ObjectiveStatusMessage, XPos, YPos, 1, FontScalar);
                }
                else
                {
                    Canvas.SetPos(XPos, YPos);
                    Canvas.DrawText(ObjectiveStatusMessage,, FontScalar, FontScalar, FRI);
                }
            }
        }
    }
    
    CurrentWeapon = KFWeapon(KFPH.Weapon);
    if( CurrentWeapon != None )
    {
        if( !bHideWeaponInfo )
        {
            FontScalar = OriginalFontScalar + GUIStyle.ScreenScale(0.1);
            
            // Weapon Name
            if( CachedWeaponInfo.Weapon != CurrentWeapon )
            {
                if( KFGRI != None )
                {
                    TraderItems = KFGRI.TraderItems;
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
            Canvas.DrawColor = FontColor;
            GUIStyle.DrawTextShadow(WeaponName, (SizeX * 0.95f) - XL, SizeY * 0.892f, 1, FontScalar);
            
            Canvas.Font = GUIStyle.PickFont(OriginalFontScalar, FONT_NUMBER);
            
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
                bSingleFire = CurrentWeapon.MagazineCapacity[0] <= 1;
                bHasSecondaryAmmo = CurrentWeapon.UsesSecondaryAmmo();
                
                AmmoCount = CurrentWeapon.AmmoCount[0];
                MagCount = bSingleFire ? CurrentWeapon.GetSpareAmmoForHUD() : FCeil(float(CurrentWeapon.GetSpareAmmoForHUD()) / float(CurrentWeapon.MagazineCapacity[0]));
                
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
                    if( CurrentWeapon.AmmoCount[class'KFWeapon'.const.ALTFIRE_FIREMODE] <= 0 )
                    {
                        SecondaryXL = BoxXL;
                        SecondaryYL = BoxYL - BoxSH;

                        HBRI.IconTex = None;
                        HBRI.TextColor = MakeColor(255, Clamp(Sin(WorldInfo.TimeSeconds * 12) * 200 + 200, 0, 200), 0, 255);
                        
                        DrawHUDBox(SecondaryXL, SecondaryYL, BoxSW, BoxSH, "RELOAD", FontScalar * 0.75, HBRI);
                        
                        HBRI.TextColor = FontColor;
                    }
                    
                    HBRI.IconTex = GetSecondaryAmmoIcon(CurrentWeapon);
                    DrawHUDBox(BoxXL, BoxYL, BoxSW, BoxSH, CurrentWeapon.GetSecondaryAmmoForHUD(), FontScalar, HBRI);
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
                    TempSize = `TimeSince(QuickSyringeStartTime);
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
    
    if( CurrentRhythmCount > 0 )
    {
        DrawRhythmCounter();
    }
    
    // Inventory
    if ( bDisplayInventory )
    {
        DrawInventory();
    }
    
    // Speed
    if ( bShowSpeed ) 
    {
        DrawSpeedMeter();
    }
    
    // Achievements
    if ( NotificationPhase != PHASE_DONE ) 
    {
        DrawAchievmentInfo();
    }
}

function DrawInventory()
{
    local InventoryCategory Categorized[MAX_WEAPON_GROUPS];
    local int i, j;
    local byte FadeAlpha, OrgFadeAlpha, ItemIndex;
    local float TempSize, TempX, TempY, TempWidth, TempHeight, TempBorder, OriginalFontScalar, FontScalar, AmmoFontScalar, CatagoryFontScalar, UpgradeX, UpgradeY, UpgradeW, UpgradeH, EmptyW, EmptyH, EmptyX, EmptyY;
    local float XL, YL, XS, YS;
    local string WeaponName, S;
    local bool bHasAmmo;
    local KFWeapon KFW;
    local Color MainColor, OutlineColor;
    local HUDBoxRenderInfo HBRI;

    if( PlayerOwner.Pawn == None || PlayerOwner.Pawn.InvManager == None )
    {
        return;
    }

    TempSize = `TimeSince(InventoryFadeStartTime);
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
    
    Canvas.Font = GUIStyle.PickFont(OriginalFontScalar);
    FontScalar = OriginalFontScalar;
    AmmoFontScalar = OriginalFontScalar;
    CatagoryFontScalar = OriginalFontScalar;

    TempWidth = InventoryBoxWidth * Canvas.ClipX;
    TempHeight = InventoryBoxHeight * Canvas.ClipX;
    TempBorder = BorderSize * Canvas.ClipX;

    TempX = (Canvas.ClipX/2) - (((TempWidth + TempBorder) * MAX_WEAPON_GROUPS)/2);

    OrgFadeAlpha = FadeAlpha;
    
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
        HBRI.Alpha = OrgFadeAlpha;
        HBRI.bUseOutline = bLightHUD;
        
        DrawHUDBox(TempX, TempY, TempWidth, TempHeight * 0.25, GetWeaponCatagoryName(i), CatagoryFontScalar, HBRI);
        
        if ( Categorized[i].ItemCount != 0 )
        {
            for ( j = 0; j < Categorized[i].ItemCount; j++ )
            {
                if( j < MinWeaponIndex[i] )
                    continue;

                KFW = Categorized[i].Items[j];
                bHasAmmo = KFW.HasAnyAmmo();
                if( !bHasAmmo )
                    FadeAlpha *= 0.5;
                else if( FadeAlpha != OrgFadeAlpha )
                    FadeAlpha = OrgFadeAlpha;
                
                OutlineColor = KFW.CurrentWeaponUpgradeIndex > 0 ? MakeColor(255, 255, 0) : HudOutlineColor;
                OutlineColor.A = Min(FadeAlpha, default.HudOutlineColor.A);
                
                if ( i == SelectedInventoryCategory && j == SelectedInventoryIndex )
                {
                    MainColor = HudOutlineColor * 0.5;
                    MainColor.A = Min(FadeAlpha, default.HudOutlineColor.A);
                
                    GUIStyle.DrawOutlinedBox(TempX, TempY, TempWidth, TempHeight, ScaledBorderSize, MainColor, OutlineColor);
                    
                    if( KFGRI != None && KFGRI.TraderItems.GetItemIndicesFromArche(ItemIndex, KFW.Class.Name) )
                        WeaponName = KFGRI.TraderItems.SaleItems[ItemIndex].WeaponDef.static.GetItemName();
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
                    MainColor.A = Min(FadeAlpha, default.HudMainColor.A);
                    
                    GUIStyle.DrawOutlinedBox(TempX, TempY, TempWidth, TempHeight, ScaledBorderSize, MainColor, OutlineColor);
                }
                
                if( KFW.CurrentWeaponUpgradeIndex > 0 )
                {
                    S = "*"$KFW.CurrentWeaponUpgradeIndex;
                    Canvas.TextSize(S, XS, YS, OriginalFontScalar, OriginalFontScalar);
                    
                    UpgradeW = XS + (ScaledBorderSize*4);
                    UpgradeH = YS + (ScaledBorderSize*4);
                    UpgradeX = TempX + ScaledBorderSize;
                    UpgradeY = TempY + (TempHeight/2) - (UpgradeH/2);
                    
                    GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, UpgradeX, UpgradeY, UpgradeW, UpgradeH, OutlineColor, false, true, false, true);
                    
                    Canvas.DrawColor = WhiteColor;
                    Canvas.DrawColor.A = FadeAlpha;
                    
                    GUIStyle.DrawTextShadow(S, UpgradeX + ((UpgradeW/2) - (XS/2)), UpgradeY + (UpgradeH/2) - (YS/2), 2, OriginalFontScalar);
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
                        S = "[" @ string(KFW.AmmoCount[class'KFWeapon'.const.ALTFIRE_FIREMODE]) @ "]";
                    else S = "[" @ KFW.AmmoCount[class'KFWeapon'.const.ALTFIRE_FIREMODE]$"/"$KFW.SpareAmmoCount[class'KFWeapon'.const.ALTFIRE_FIREMODE] @ "]";
                    
                    Canvas.TextSize(S, XS, YS, AmmoFontScalar, AmmoFontScalar);
                    Canvas.SetPos(TempX + (ScaledBorderSize*2), TempY + (TempHeight - YS) - (ScaledBorderSize*2));
                    Canvas.DrawText(S,, AmmoFontScalar, AmmoFontScalar);
                }
                
                if( !bHasAmmo )
                {
                    S = "EMPTY";
                    Canvas.TextSize(S, XS, YS, OriginalFontScalar, OriginalFontScalar);
                    
                    EmptyW = XS * 1.25f;
                    EmptyH = YS * 1.25f;
                    EmptyX = TempX + ((TempWidth/2) - (EmptyW/2));
                    EmptyY = TempY + ((TempHeight/2) - (EmptyH/2));
                    
                    MainColor = DefaultHudMainColor;
                    MainColor.A = Min(OrgFadeAlpha, default.DefaultHudMainColor.A);
                    
                    GUIStyle.DrawRoundedBox(ScaledBorderSize*2, EmptyX, EmptyY, EmptyW, EmptyH, MainColor);
                    
                    Canvas.DrawColor = WhiteColor;
                    Canvas.DrawColor.A = OrgFadeAlpha;
                    Canvas.SetPos(EmptyX + (EmptyW/2) - (XS/2), EmptyY + (EmptyH/2) - (YS/2));
                    Canvas.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
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

function AddAchievmentPopup(const out PopupMessage NewMessage) 
{
    MessageQueue.AddItem(NewMessage);

    if( MessageQueue.Length == 1 ) 
    {
        NotificationPhaseStartTime = WorldInfo.TimeSeconds;
        NotificationPhase = PHASE_SHOWING;
    }
}

function DrawAchievmentInfo()
{
    local int i;
    local float IconSize, TempX, TempY, DrawHeight, TimeElapsed, TempWidth, TempHeight, FontScalar;
    local array<string> Parts;
    
    TimeElapsed = `TimeSince(NotificationPhaseStartTime);
    switch( NotificationPhase )
    {
        case PHASE_SHOWING:
            if (TimeElapsed < NotificationShowTime) 
            {
                DrawHeight = (TimeElapsed / NotificationShowTime) * NotificationHeight;
            } 
            else 
            {
                NotificationPhase = PHASE_DELAYING;
                NotificationPhaseStartTime = `TimeSince(TimeElapsed - NotificationShowTime);
                DrawHeight = NotificationHeight;
            }
            break;
        case PHASE_DELAYING:
            if (TimeElapsed < NotificationHideDelay ) 
            {
                DrawHeight = NotificationHeight;
            } 
            else 
            {
                NotificationPhase = PHASE_HIDING; // Hiding Phase
                TimeElapsed -= NotificationHideDelay;
                NotificationPhaseStartTime = `TimeSince(TimeElapsed);
                DrawHeight = (1.0 - (TimeElapsed / NotificationHideTime)) * NotificationHeight;
            }
            break;
        case PHASE_HIDING:
            if (TimeElapsed < NotificationHideTime) 
            {
                DrawHeight = (1.0 - (TimeElapsed / NotificationHideTime)) * NotificationHeight;
            } 
            else 
            {
                // We're done
                MessageQueue.Remove(0, 1);
                if( MessageQueue.Length != 0 ) 
                {
                    NotificationPhaseStartTime = WorldInfo.TimeSeconds;
                    NotificationPhase = PHASE_SHOWING;
                } 
                else 
                {
                    NotificationPhase = PHASE_DONE;
                }
                return;
            }
            break;
    }

    switch( MessageQueue[0].MsgPosition ) 
    {
        case PP_TOP_LEFT:
        case PP_BOTTOM_LEFT:
            TempX = 0;
            break;
        case PP_TOP_CENTER:
        case PP_BOTTOM_CENTER:
            TempX = (Canvas.ClipX / 2.0) - (NotificationWidth / 2.0);
            break;
        case PP_TOP_RIGHT:
        case PP_BOTTOM_RIGHT:
            TempX = Canvas.ClipX - NotificationWidth;
            break;
        default:
            `Warn("Unrecognized position:" @ MessageQueue[0].MsgPosition);
            break;
    }

    switch( MessageQueue[0].MsgPosition ) 
    {
        case PP_BOTTOM_CENTER:
        case PP_BOTTOM_LEFT:
        case PP_BOTTOM_RIGHT:
            TempY = Canvas.ClipY - DrawHeight;
            break;
        case PP_TOP_CENTER:
        case PP_TOP_LEFT:
        case PP_TOP_RIGHT:
            TempY = DrawHeight - NotificationHeight;
            break;
        default:
            `Warn("Unrecognized position:" @ MessageQueue[0].MsgPosition);
            break;
    }

    // Draw the Background
    GUIStyle.DrawOutlinedBox(TempX, TempY, NotificationWidth, NotificationHeight, ScaledBorderSize, HudMainColor, HudOutlineColor);

    // Offset for Border and Calc Icon Size
    TempX += NotificationBorderSize;
    TempY += NotificationBorderSize;

    IconSize = NotificationHeight - (NotificationBorderSize * 2.0);
    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawRect(IconSize, IconSize, MessageQueue[0].Image);
    
    // Offset for desired Spacing between Icon and Text
    TempX += IconSize + NotificationIconSpacing;

    Canvas.Font = GUIStyle.PickFont(FontScalar);
    FontScalar = 0.3;
    
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawText(MessageQueue[0].Header,, FontScalar, FontScalar);
    
    Canvas.SetClip(TempX + (NotificationWidth - IconSize - NotificationBorderSize * 2.0 - NotificationIconSpacing), TempY);
    
    // Set up next line
    ParseStringIntoArray(MessageQueue[0].Body, Parts, NewLineSeparator, true);
    for(i= 0; i < Parts.Length; i++)
    {
        Canvas.TextSize(Parts[i], TempWidth, TempHeight, FontScalar, FontScalar);
        TempY += TempHeight;
        Canvas.SetPos(TempX, TempY);
        Canvas.DrawText(Parts[i],, FontScalar, FontScalar);
    }
}

function DrawPriorityMessage()
{
    local float XS, YS, TextX, TextY, IconX, IconY, BoxW, OrgBoxW, BoxH, OrgBoxH, BoxX, BoxY, OrignalFontScalar, FontScalar, Box2W, OrgBox2W, Box2H, OrgBox2H, Box2X, Box2Y, Box3W, Box3X, SecondaryXS, SecondaryYS, SecondaryScaler;
    local float TempSize, BoxAlpha, SecondaryBoxAlpha;
    local bool bHasIcon, bHasSecondaryIcon, bHasSecondary, bAlignTop, bAlignBottom, bAnimFinished;
    
    TempSize = `TimeSince(PriorityMessage.StartTime);
    
    Canvas.Font = GUIStyle.PickFont(OrignalFontScalar, FONT_NAME);
    
    bHasIcon = PriorityMessage.Icon != None;
    bHasSecondaryIcon = PriorityMessage.SecondaryIcon != None;
    bHasSecondary = PriorityMessage.SecondaryText != "";
    
    FontScalar = OrignalFontScalar + GUIStyle.ScreenScale(0.85f);
    Canvas.TextSize(PriorityMessage.PrimaryText, XS, YS, FontScalar, FontScalar);
    
    if( bHasSecondary )
    {
        SecondaryScaler = OrignalFontScalar + GUIStyle.ScreenScale(0.3f);
        Canvas.TextSize(PriorityMessage.SecondaryText, SecondaryXS, SecondaryYS, SecondaryScaler, SecondaryScaler);
        BoxW = FMax(XS,SecondaryXS + (SecondaryXS/2))+(YS*2)*2;
    }
    else BoxW = XS+(YS*2)*2;
    BoxH = YS;
   
    OrgBoxW = BoxW;
    OrgBoxH = BoxH;
   
    if( PriorityMessage.FadeInTime - TempSize > 0 )
    {
        BoxAlpha = (PriorityMessage.FadeInTime - TempSize) / PriorityMessage.FadeInTime;
        BoxAlpha = 1.f - BoxAlpha;
    }
    else if( (PriorityMessage.LifeTime - TempSize) < PriorityMessage.FadeOutTime )
    {
        BoxAlpha = (PriorityMessage.LifeTime - TempSize) / PriorityMessage.FadeOutTime;
    }
    else
    {
        BoxAlpha = 1.f;
    }
    
    if( PriorityMessage.PrimaryAnim == ANIM_SLIDE )
        BoxW = Lerp(BoxH, BoxW, BoxAlpha);
    else BoxH = Lerp(0, BoxH, BoxAlpha);

    if( TempSize > PriorityMessage.LifeTime )
    {
        PriorityMessage = default.PriorityMessage;
        CurrentPriorityMessageA = 0;
        CurrentSecondaryMessageA = 0;
        return;
    }
    
    BoxX = CenterX - (BoxW/2);
    BoxY = (CenterY*0.5) - (BoxH/2);
    
    TextX = BoxX + (BoxW/2) - (XS/2);
    TextY = BoxY + (BoxH/2) - (YS/2);
    
    if( bHasIcon )
        GUIStyle.DrawOutlinedBox(BoxX+BoxH, BoxY, BoxW-(BoxH*2), BoxH, ScaledBorderSize, HudMainColor, HudOutlineColor);
    else GUIStyle.DrawRoundedBoxOutlined(ScaledBorderSize, BoxX, BoxY, BoxW, BoxH, HudMainColor, HudOutlineColor);
    
    bAnimFinished = (PriorityMessage.PrimaryAnim == ANIM_SLIDE ? BoxW >= OrgBoxW : BoxH >= OrgBoxH) && (TempSize+PriorityMessage.FadeInTime+0.5f) > 1.f;
    if( bAnimFinished ) 
    {
        if( CurrentPriorityMessageA != 255 )
        {
            CurrentPriorityMessageA += RandRange(3,10);
            if( CurrentPriorityMessageA > 255 )
                CurrentPriorityMessageA = 255;
        }
            
        Canvas.DrawColor = FontColor;
        Canvas.DrawColor.A = CurrentPriorityMessageA;
        GUIStyle.DrawTextBlurry(PriorityMessage.PrimaryText, TextX, TextY, FontScalar);
    }
    
    if( bHasIcon )
    {
        IconX = BoxX;
        
        GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, IconX, BoxY, BoxH, BoxH, HudOutlineColor, true, false, true, false);

        Canvas.DrawColor = PriorityMessage.IconColor;
        Canvas.SetPos(IconX, TextY);
        Canvas.DrawRect(BoxH, BoxH, PriorityMessage.Icon);
        
        IconX = BoxX+(BoxW-BoxH);
        
        GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, IconX, BoxY, BoxH, BoxH, HudOutlineColor, false, true, false, true);
        
        Canvas.DrawColor = PriorityMessage.IconColor;
        Canvas.SetPos(IconX, TextY);
        Canvas.DrawRect(BoxH, BoxH, PriorityMessage.Icon);
    }
    
    if( bHasSecondary && bAnimFinished && CurrentPriorityMessageA >= 255 )
    {
        if( PriorityMessage.SecondaryStartTime <= 0.f )
            PriorityMessage.SecondaryStartTime = WorldInfo.TimeSeconds;
            
        if( PriorityMessage.bSecondaryUsesFullLength )
            Box2W = BoxW - (BoxH * 2) + (ScaledBorderSize*2);
        else
        {
            Box2W = FMin(SecondaryXS + (SecondaryXS/2), BoxW - (BoxH * 2));
            if( bHasSecondaryIcon )
                Box2W += Box2H*2;
        }
        Box2H = SecondaryYS;
        
        OrgBox2W = Box2W;
        OrgBox2H = Box2H;

        SecondaryBoxAlpha = GUIStyle.TimeFraction(PriorityMessage.SecondaryStartTime, PriorityMessage.SecondaryStartTime+PriorityMessage.FadeInTime, WorldInfo.TimeSeconds);
        if( PriorityMessage.SecondaryAnim == ANIM_SLIDE )
            Box2W = Lerp(0, Box2W, SecondaryBoxAlpha);
        else Box2H = Lerp(0, Box2H, SecondaryBoxAlpha);
            
        Box2X = BoxX + (BoxW/2) - (Box2W/2);
        
        bAlignTop = PriorityMessage.SecondaryAlign == PR_TOP;
        bAlignBottom = PriorityMessage.SecondaryAlign == PR_BOTTOM;
        
        if( bAlignTop )
            Box2Y = BoxY - Box2H;
        else Box2Y = BoxY + BoxH;
        
        Box3X = Box2X+ScaledBorderSize;
        Box3W = Box2W-(ScaledBorderSize*2);
        
        Canvas.DrawColor = HudMainColor;
        Canvas.SetPos(Box3X, Box2Y);
        GUIStyle.DrawWhiteBox(Box3W, Box2H);
       
        GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*4, Box2X, Box2Y, ScaledBorderSize*2, Box2H, HudOutlineColor, bAlignTop, false, bAlignBottom, false);
        GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*4, Box2X+(Box2W-(ScaledBorderSize*2)), Box2Y, ScaledBorderSize*2, Box2H, HudOutlineColor, false, bAlignTop, false, bAlignBottom);

        TextX = Box3X + (Box3W/2) - (SecondaryXS/2) + ScaledBorderSize;
        TextY = Box2Y + (Box2H/2) - (SecondaryYS/2) - (ScaledBorderSize/2);
        
        if( PriorityMessage.SecondaryAnim == ANIM_SLIDE ? Box2W >= OrgBox2W : Box2H >= OrgBox2H )
        {
            if( CurrentSecondaryMessageA != 255 )
            {
                CurrentSecondaryMessageA += RandRange(3,10);
                if( CurrentSecondaryMessageA > 255 )
                    CurrentSecondaryMessageA = 255;
            }
                
            Canvas.DrawColor = FontColor;
            Canvas.DrawColor.A = CurrentSecondaryMessageA;
            Canvas.SetPos(TextX, TextY);
            Canvas.DrawText(PriorityMessage.SecondaryText,,SecondaryScaler,SecondaryScaler);
        }
        
        if( bHasSecondaryIcon )
        {
            IconX = TextX-Box2H;
            IconY = TextY+(ScaledBorderSize*2);
            
            Canvas.DrawColor = PriorityMessage.SecondaryIconColor;
            Canvas.SetPos(IconX, IconY);
            Canvas.DrawRect(Box2H-(ScaledBorderSize*4), Box2H-(ScaledBorderSize*4), PriorityMessage.SecondaryIcon);
            
            IconX = TextX+SecondaryXS+(ScaledBorderSize*2);

            Canvas.DrawColor = PriorityMessage.SecondaryIconColor;
            Canvas.SetPos(IconX, IconY);
            Canvas.DrawRect(Box2H-(ScaledBorderSize*4), Box2H-(ScaledBorderSize*4), PriorityMessage.SecondaryIcon);
        }
    }
}

function ShowPriorityMessage(FPriorityMessage Msg)
{
    if( PriorityMessage != default.PriorityMessage || Msg.LifeTime < Msg.FadeInTime || Msg.LifeTime < Msg.FadeOutTime )
        return;
        
    Msg.LifeTime += 0.5f;
    Msg.StartTime = WorldInfo.TimeSeconds;
    PriorityMessage = Msg;
}

function DrawNonCritialMessage( int Index, FCritialMessage Message, float X, float Y )
{
    local float XS, YS, XL, YL, TX, BoxXS, BoxYS, FontScalar, TempSize, TY, OrgXL, BoxAlpha, AnimFadeIn, AnimFadeOut, DisplayTime;
    local int i, FadeAlpha;
    local array<string> SArray;
    local HUDBoxRenderInfo HBRI;
    local bool bAnimFinished, bTextAnimFinished;
    local string S;
    local Color TextColor;
    
    Canvas.Font = GUIStyle.PickFont(FontScalar);
    FontScalar += GUIStyle.ScreenScale(0.1);
    TextColor = FontColor;
    DisplayTime = Message.bUseAnimation ? 1.775f : NonCriticalMessageDisplayTime;
    
    TempSize = `TimeSince(Message.StartTime);
    if ( TempSize > DisplayTime )
    {
        NonCriticalMessages.RemoveItem(Message);
        return;
    }
    
    if( Message.Delimiter != "" )
    {
        SArray = SplitString(Message.Text, Message.Delimiter);
        if( SArray.Length > 0 )
        {    
            for( i=0; i<SArray.Length; ++i )
            {
                if( SArray[i]!="" )
                {
                    Canvas.TextSize(GUIStyle.StripTextureFromString(SArray[i]),XS,YS,FontScalar,FontScalar);
                    TX = FMax(XS,TX);
                    TY += YS;
                }
            }
            
            XL = TX * 1.2;
            YL = TY * 1.05;
        }
    }
    else
    {
        Canvas.TextSize(GUIStyle.StripTextureFromString(Message.Text), XS, YS, FontScalar, FontScalar);
        
        XL = XS * 1.2;
        YL = YS * 1.05;
    }
    
    if( Message.bHighlight )
        XL += ScaledBorderSize*4;
        
    if( Message.bUseAnimation )
    {
        FadeAlpha = -1.f;
        OrgXL = XL;
        
        AnimFadeIn = NonCriticalMessageFadeInTime * 0.25;
        AnimFadeOut = NonCriticalMessageFadeOutTime * 0.25;
        
        if( AnimFadeIn - TempSize > 0 )
        {
            BoxAlpha = (AnimFadeIn - TempSize) / AnimFadeIn;
            BoxAlpha = 1.f - BoxAlpha;
        }
        else if( (DisplayTime - TempSize) < AnimFadeOut )
        {
            BoxAlpha = (DisplayTime - TempSize) / AnimFadeOut;
        }
        else
        {
            BoxAlpha = 1.f;
        }
        
        BoxAlpha = FClamp(BoxAlpha, 0.f, 1.f);
        XL = Lerp(ScaledBorderSize*2, XL, BoxAlpha);
        
        bAnimFinished = XL >= OrgXL && (TempSize+AnimFadeIn+0.5f) > 1.f;
        if( bAnimFinished )
        {
            HBRI.StringArray = SArray;
            S = Message.Text;
            
            bTextAnimFinished = NonCriticalMessages[Index].TextAnimAlpha >= 255;
            if( !bTextAnimFinished )
            {
                NonCriticalMessages[Index].TextAnimAlpha += RandRange(3,10);
                if( NonCriticalMessages[Index].TextAnimAlpha > 255 )
                    NonCriticalMessages[Index].TextAnimAlpha =  255;
            }
                
            TextColor.A = NonCriticalMessages[Index].TextAnimAlpha;
        }
    }
    else
    {
        if ( TempSize < NonCriticalMessageFadeInTime )
        {
            FadeAlpha = int((TempSize / NonCriticalMessageFadeInTime) * 255.0);
        }
        else if ( TempSize > DisplayTime - NonCriticalMessageFadeOutTime )
        {
            FadeAlpha = int((1.0 - ((TempSize - (DisplayTime - NonCriticalMessageFadeOutTime)) / NonCriticalMessageFadeOutTime)) * 255.0);
        }
        else
        {
            FadeAlpha = 255;
        }
        
        HBRI.StringArray = SArray;
        S = Message.Text;
    }
    
    BoxXS = X - (XL / 2);
    BoxYS = Y - ((YL + (ScaledBorderSize * 2)) * Index);
    
    if( (BoxYS + YL) > Canvas.ClipY )
        BoxYS = Canvas.ClipY - YL - (ScaledBorderSize * 2);
        
    HBRI.TextColor = TextColor;
    HBRI.Alpha = FadeAlpha;
    HBRI.bUseOutline = bLightHUD;
    HBRI.bUseRounded = true;
    HBRI.bHighlighted = Message.bHighlight;
    
    DrawHUDBox(BoxXS, BoxYS, XL, YL, S, FontScalar, HBRI);
}

function ShowNonCriticalMessage( string Message, optional string Delimiter, optional bool bHighlight, optional bool bUseAnimation )
{    
    local FCritialMessage Messages;
    local int Index;
    local float DisplayTime;
    
    if( ClassicPlayerOwner.IsBossCameraMode() )
        return;
        
    Index = NonCriticalMessages.Find('Text', Message);
    if( Index != INDEX_NONE )
    {
        DisplayTime = bUseAnimation ? 1.775f : NonCriticalMessageDisplayTime;
        if ( `TimeSince(NonCriticalMessages[Index].StartTime) > NonCriticalMessageFadeInTime )
        {
            if ( `TimeSince(NonCriticalMessages[Index].StartTime) > DisplayTime - NonCriticalMessageFadeOutTime )
                NonCriticalMessages[Index].StartTime = `TimeSince(NonCriticalMessageFadeInTime + ((DisplayTime - `TimeSince(NonCriticalMessages[Index].StartTime)) * NonCriticalMessageFadeInTime));
            else NonCriticalMessages[Index].StartTime = `TimeSince(NonCriticalMessageFadeInTime);
        }
        
        return;
    }
    
    if( NonCriticalMessages.Length >= (SpectatorInfo != None && SpectatorInfo.bVisible) ? 1 : MaxNonCriticalMessages )
        return;
        
    Messages.Text = Message;
    Messages.Delimiter = Delimiter;
    Messages.StartTime = WorldInfo.TimeSeconds;
    Messages.bHighlight = bHighlight;
    Messages.bUseAnimation = bUseAnimation;
    
    NonCriticalMessages.AddItem(Messages);
}

function ShowQuickSyringe()
{
    if ( bDisplayQuickSyringe )
    {
        if ( `TimeSince(QuickSyringeStartTime) > QuickSyringeFadeInTime )
        {
            if ( `TimeSince(QuickSyringeStartTime) > QuickSyringeDisplayTime - QuickSyringeFadeOutTime )
                QuickSyringeStartTime = `TimeSince(QuickSyringeFadeInTime + ((QuickSyringeDisplayTime - `TimeSince(QuickSyringeStartTime)) * QuickSyringeFadeInTime));
            else QuickSyringeStartTime = `TimeSince(QuickSyringeFadeInTime);
        }
    }
    else
    {
        bDisplayQuickSyringe = true;
        QuickSyringeStartTime = WorldInfo.TimeSeconds;
    }
}

function DrawImportantHealthBar(float X, float Y, float W, float H, string S, float HealthFrac, Color MainColor, Color BarColor, Texture2D Icon, optional float BorderScale, optional bool bDisabled, optional bool bTrackDamageHistory, optional int Health, optional int HealthMax, optional KFZEDBossInterface Interface)
{
    local float FontScalar,MainBoxH,XPos,YPos,IconBoxX,IconBoxY,IconXL,IconYL,XL,YL,HistoryX,ShieldHealthPct;
    local Color BoxColor,FadeColor;
    
    if( BorderScale == 0.f )
        BorderScale = ScaledBorderSize*2;
        
    if( bDisabled )
        MainColor.A = 95;
    
    MainBoxH = H * 2;
    IconBoxX = X;
    IconBoxY = Y;
    
    BoxColor = MakeColor(30, 30, 30, 255);
    GUIStyle.DrawRoundedBoxEx(BorderScale, IconBoxX, IconBoxY, MainBoxH, MainBoxH, BoxColor, true, false, true, false);
    
    X += MainBoxH;
    W -= MainBoxH;
    
    GUIStyle.DrawRoundedBoxEx(BorderScale, X, Y, W, H, MainColor, false, true, false, true);
    
    // ToDo - Make this code less ugly and more optimal. Moving the boss healthbar to a widget may help
    if( bTrackDamageHistory )
    {
        GUIStyle.DrawRoundedBoxEx(BorderScale, X, Y, W * HealthFrac, H, BarColor, false, !HealthBarDamageHistory[DamageHistoryNum].bDrawingHistory, false, !HealthBarDamageHistory[DamageHistoryNum].bDrawingHistory);
        
        if( DamageHistoryNum >= HealthBarDamageHistory.Length )
            HealthBarDamageHistory.Length = DamageHistoryNum+1;
            
        if( HealthBarDamageHistory[DamageHistoryNum].OldBarHealth != Health )
        {
            if( HealthBarDamageHistory[DamageHistoryNum].OldBarHealth > Health )
            {
                HealthBarDamageHistory[DamageHistoryNum].bDrawingHistory = true;
                
                if( HealthBarDamageHistory[DamageHistoryNum].OldHealth != Health )
                {
                    HealthBarDamageHistory[DamageHistoryNum].OldHealth = Health;
                    HealthBarDamageHistory[DamageHistoryNum].LastHealthUpdate = WorldInfo.RealTimeSeconds + 0.1f;
                    HealthBarDamageHistory[DamageHistoryNum].HealthUpdateEndTime = WorldInfo.RealTimeSeconds + 0.925f;
                }
                
                HistoryX = X + (W * HealthFrac);
                HealthFrac = FMin(float(HealthBarDamageHistory[DamageHistoryNum].OldBarHealth-Health) / float(HealthMax),1.f-HealthFrac);
                
                FadeColor = WhiteColor;
                FadeColor.A  = BarColor.A;
                if( HealthBarDamageHistory[DamageHistoryNum].LastHealthUpdate < WorldInfo.RealTimeSeconds )
                {
                    FadeColor.A = Clamp(Sin(WorldInfo.RealTimeSeconds * 12) * 200 + 255, 0, BarColor.A);
                    
                    if( HealthBarDamageHistory[DamageHistoryNum].HealthUpdateEndTime < WorldInfo.RealTimeSeconds )
                    {
                        HealthBarDamageHistory[DamageHistoryNum].OldBarHealth = Health;
                        HealthBarDamageHistory[DamageHistoryNum].bDrawingHistory = false;
                        HealthBarDamageHistory[DamageHistoryNum].LastHealthUpdate = 0.f;
                        HealthBarDamageHistory[DamageHistoryNum].HealthUpdateEndTime = 0.f;
                    }
                }
                
                GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, HistoryX, Y, W * HealthFrac, H, FadeColor, false, true, false, true);
            }
            else
            {
                HealthBarDamageHistory[DamageHistoryNum].OldBarHealth = Health;
            }
        }
        
        DamageHistoryNum++;
    }
    else GUIStyle.DrawRoundedBoxEx(BorderScale, X, Y, W * HealthFrac, H, BarColor, false, true, false, true);
    
    if( Interface != None )
    {
        ShieldHealthPct = Interface.GetShieldHealthPercent();
        if( ShieldHealthPct > 0.f && Interface.GetShieldPSC() != None )
            GUIStyle.DrawRoundedBoxEx(ScaledBorderSize, X, Y, W * ShieldHealthPct, H * 0.25, MakeColor(0, 162, 232, 255), false, true, false, false);
    }

    Canvas.DrawColor = BoxColor;
    Canvas.SetPos(IconBoxX+MainBoxH,IconBoxY);
    GUIStyle.DrawCornerTex(BorderScale*2,3);
    
    IconXL = MainBoxH-BorderScale;
    IconYL = IconXL;
    
    XPos = IconBoxX + (MainBoxH/2) - (IconXL/2);
    YPos = IconBoxY + (MainBoxH/2) - (IconYL/2);
    
    Canvas.SetDrawColor(255, 255, 255, bDisabled ? 95 : 255);
    Canvas.SetPos(XPos, YPos);
    Canvas.DrawRect(IconXL, IconYL, Icon);
    
    if( S != "" )
    {
        Canvas.Font = GUIStyle.PickFont(FontScalar);
        Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);

        XPos = X + BorderScale;
        YPos = (Y+H) + (H/2) - (YL/2);
        
        Canvas.DrawColor = class'HUD'.default.WhiteColor;
        GUIStyle.DrawTextShadow(S, XPos, YPos, 1, FontScalar);
    }
}

function DrawBossHealthBars()
{
    local KFPawn_MonsterBoss BossPawn;
    local KFPawn_Monster MonsterPawn;
    local int i;
    local float BarH, BarW, MainBarX, MainBarY, MainBoxW, ArmorW, ArmorH;
    local float HealthFrac, ArmorPct;
    local Color PawnHealthColor;
    local ArmorZoneInfo ArmorZone;
    
    if( bDisplayInventory || ClassicPlayerOwner.bHideBossHealthBar )
        return;
        
    MonsterPawn = BossRef.GetMonsterPawn();
    BossPawn = KFPawn_MonsterBoss(MonsterPawn);
    
    if( MonsterPawn.IsDoingSpecialMove(SM_BossTheatrics) )
        return;
    
    BarH = GUIStyle.DefaultHeight;
    BarW = Canvas.ClipX * 0.45;
    
    MainBoxW = BarW * 0.125;
    
    MainBarX = (Canvas.ClipX/2) - (BarW/2) + (MainBoxW/2);
    MainBarY = BarH;
    
    HealthFrac = FClamp(BossRef.GetHealthPercent(), 0, 1);
    if( BossPawn != None )
    {
        PawnHealthColor = BattlePhaseColors[Max(BossPawn.GetCurrentBattlePhase() - 1, 0)];
    }
    else
    {
        if( HealthFrac <= 0.25 )
            PawnHealthColor = BattlePhaseColors[3];
        else if( HealthFrac <= 0.5 )
            PawnHealthColor = BattlePhaseColors[2];
        else if( HealthFrac <= 0.75 )
            PawnHealthColor = BattlePhaseColors[1];
        else PawnHealthColor = BattlePhaseColors[0];
    }
    
    DrawImportantHealthBar(MainBarX, MainBarY, BarW, BarH, GetNameOf(MonsterPawn.Class), HealthFrac, HudMainColor, PawnHealthColor, BossInfoIcon,,,true,MonsterPawn.Health,MonsterPawn.HealthMax,KFZEDBossInterface(MonsterPawn));
    
    if( MonsterPawn.ArmorInfo != None )
    {
        ArmorW = BarW * 0.2;
        ArmorH = BarH * 0.45;
        
        MainBarX = MainBarX + (BarW - ArmorW - ScaledBorderSize);
        MainBarY += (BarH/2) + ArmorH + (ScaledBorderSize*2);
            
        for(i=0; i<MonsterPawn.ArmorInfo.ArmorZones.Length; i++)
        {
            ArmorZone = MonsterPawn.ArmorInfo.ArmorZones[i];
            ArmorPct = FClamp(ByteToFloat(MonsterPawn.RepArmorPct[i]), 0.f, 1.f);
            
            DrawImportantHealthBar(MainBarX, MainBarY, ArmorW, ArmorH, "", ArmorPct, HudMainColor, MakeColor(0, 162, 232, 255), ArmorZone.ZoneIcon, ScaledBorderSize, ArmorPct <= 0.f);
            MainBarX -= ArmorW + (ScaledBorderSize*2);
        }
    }
}

function DrawEscortHealthBars()
{
    local KFPawn_Scripted ScriptedPawn;
    local FScriptedPawnCache ValidPawn;
    local int BarH, BarW, MainBarX, MainBarY, MainBoxW;
    local float HealthFrac;
    local Color PawnHealthColor;
    local Texture2D Icon;
    
    if( bDisplayInventory || bShowScores )
        return;
    
    foreach ScriptedPawnCache(ValidPawn)
    {
        if( ValidPawn.Pawn != None && ValidPawn.Pawn.ShouldShowOnHUD() )
        {
            ScriptedPawn = ValidPawn.Pawn;
            Icon = ValidPawn.Icon;
            break;
        }
        else
        {
            ScriptedPawnCache.RemoveItem(ValidPawn);
        }
    }
    
    if( ScriptedPawn != None )
    {
        BarH = GUIStyle.DefaultHeight;
        BarW = Canvas.ClipX * 0.45;
        
        MainBoxW = BarW * 0.125;
        
        MainBarX = (Canvas.ClipX/2) - (BarW/2) + (MainBoxW/2);
        MainBarY = BarH;
        
        HealthFrac = FClamp(float(ScriptedPawn.Health)/float(ScriptedPawn.HealthMax), 0, 1);
        PawnHealthColor = MakeColor(0, 150, 0, 175);
        PawnHealthColor.g = 150 * HealthFrac;
        PawnHealthColor.r = 150 - PawnHealthColor.g;
        
        DrawImportantHealthBar(MainBarX, MainBarY, BarW, BarH, ScriptedPawn.GetLocalizedName(), HealthFrac, HudMainColor, PawnHealthColor, Icon,,, true, ScriptedPawn.Health, ScriptedPawn.HealthMax);
    }
}

function DrawDoorHealthBars()
{
    local KFDoorActor DamageDoor;
    local Vector ScreenLoc, OffScreenLoc, OffScreenRot;
    local Vector2D OffScreenPos;
    local float MyDot;
    local FDoorCache MyCache;
    local float TextWidth, TextHeight, WeldPercentageFloat, OriginalFontScale, FontScale, CurrentValue, MaxValue, BackgroundW, BackgroundH, IconW, IconH;
    local string IntegrityText;
    local bool bUsable;
    local KFPawn KFP;
    
    KFP = KFPawn(PlayerOwner.Pawn);

    foreach DoorCache(MyCache)
    {
        DamageDoor = MyCache.Door;
        if ( DamageDoor != None )
        {
            OffScreenPos.X = SizeX * PI;
            OffScreenPos.Y = SizeY * PI;
            Canvas.DeProject(OffScreenPos, OffScreenLoc, OffScreenRot);
            DamageDoor.WeldUILocation = OffScreenLoc;
                
            bUsable = (KFP != None && KFP.GetPerk() != None && KFP.GetPerk().CanRepairDoors());
            if ( DamageDoor.WeldIntegrity > 0 || bUsable )
            {
                if( !FastTrace(MyCache.WeldUILocation - ((MyCache.WeldUILocation - PLCameraLoc) * 0.25), PLCameraLoc) )
                {
                    return;
                }
                
                MyDot = PLCameraDir dot (DamageDoor.Location - PLCameraLoc);
                if( MyDot < 0.5f )
                {
                    return;
                }
                ScreenLoc = Canvas.Project( MyCache.WeldUILocation );
                if( ScreenLoc.X < 0 || ScreenLoc.X + DoorWelderIcon.GetSurfaceWidth() * 3 >= Canvas.ClipX || ScreenLoc.Y < 0 && ScreenLoc.Y >= Canvas.ClipY)
                {
                    return;
                }
                
                if( DamageDoor.bIsDestroyed && bUsable )
                {
                    CurrentValue = float(DamageDoor.RepairProgress);
                    MaxValue = 255.f;
                }
                else if( DamageDoor.WeldIntegrity > 0 )
                {
                    CurrentValue = float(DamageDoor.WeldIntegrity);
                    MaxValue = float(DamageDoor.MaxWeldIntegrity);
                }

                if( !DamageDoor.bIsDestroyed )
                {
                    WeldPercentageFloat = (CurrentValue / MaxValue) * 100.0;
                    if( WeldPercentageFloat < 1.f && WeldPercentageFloat > 0.f )
                    {
                        WeldPercentageFloat = 1.f;
                    }
                    else if( WeldPercentageFloat > 99.f && WeldPercentageFloat < 100.f )
                    {
                        WeldPercentageFloat = 99.f;
                    }
                    IntegrityText = int(WeldPercentageFloat) $ "%";
                    
                    BackgroundW = GUIStyle.ScreenScale(DoorWelderBG.GetSurfaceWidth() * 1.185);
                    BackgroundH = GUIStyle.ScreenScale(DoorWelderBG.GetSurfaceHeight() * 0.9);

                    Canvas.SetDrawColor(255, 255, 255, DrawToDistance(DamageDoor, 112, 0));
                    Canvas.SetPos(ScreenLoc.X - (BackgroundW / 2) , ScreenLoc.Y - (BackgroundH / 2));
                    Canvas.DrawTileStretched(DoorWelderBG, BackgroundW, BackgroundH, 0, 0, DoorWelderBG.GetSurfaceWidth(), DoorWelderBG.GetSurfaceHeight());

                    Canvas.SetDrawColor(255, 50, 50, DrawToDistance(DamageDoor, 255, 0));

                    Canvas.Font = GUIStyle.PickFont(OriginalFontScale);
                    FontScale = OriginalFontScale + 0.2;
                    
                    Canvas.TextSize(IntegrityText, TextWidth, TextHeight, FontScale, FontScale);
                    Canvas.SetDrawColor(255, 50, 50, DrawToDistance(DamageDoor, 255, 0));
                    
                    GUIStyle.DrawTextShadow(IntegrityText, ScreenLoc.X + 5, (DamageDoor.DemoWeld > 0 && !DamageDoor.bShouldExplode) ? ScreenLoc.Y - (TextHeight / 1.25f) : ScreenLoc.Y - (TextHeight / 2.f), 1, FontScale);
                    
                    IconW = GUIStyle.ScreenScale(64);
                    IconH = GUIStyle.ScreenScale(48);
                    
                    Canvas.SetPos((ScreenLoc.X - 5) - IconW, ScreenLoc.Y - (IconH/2));
                    Canvas.DrawTile(DoorWelderIcon, IconW, IconH, 0, 0, 256, 192);
                    
                    if( DamageDoor.DemoWeld > 0 && !DamageDoor.bShouldExplode )
                    {
                        CurrentValue = float(DamageDoor.DemoWeld);
                        MaxValue = float(DamageDoor.DemoWeldRequired);
                        
                        WeldPercentageFloat = (CurrentValue / MaxValue) * 100.0;
                        if( WeldPercentageFloat < 1.f && WeldPercentageFloat > 0.f )
                        {
                            WeldPercentageFloat = 1.f;
                        }
                        else if( WeldPercentageFloat > 99.f && WeldPercentageFloat < 100.f )
                        {
                            WeldPercentageFloat = 99.f;
                        }
                        IntegrityText = int(WeldPercentageFloat) $ "%";
                        
                        Canvas.SetDrawColor(OrangeColor.R, OrangeColor.G, OrangeColor.B, DrawToDistance(DamageDoor, 255, 0));
                        GUIStyle.DrawTextShadow(IntegrityText, ScreenLoc.X + 5, ScreenLoc.Y - (TextHeight / 1.25f) + TextHeight - (ScaledBorderSize*2), 1, OriginalFontScale);
                    }
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

    Y = Canvas.ClipY*0.175;
    
    Canvas.Font = GUIStyle.PickFont(TextScale);
    for( i=0; i <= 12 && i < TalkerPRIs.Length; i++ )
    {
        PlayerName = TalkerPRIs[i].GetHumanReadableName();
        
        Canvas.TextSize(PlayerName, XL, YL, TextScale, TextScale);
        
        H = YL + (ScaledBorderSize * 2);
        W = (XL + H + (ScaledBorderSize * 2)) * 1.25;
        
        X = Canvas.ClipX-W-ScaledBorderSize;
        
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

function RenderVotingOptions()
{
    local float TextWidth, TextHeight, TextScale, OriginalTextScale;
    local float X, Y;
    
    Canvas.Font = GUIStyle.PickFont(OriginalTextScale);
    
    TextScale = OriginalTextScale + 0.5;
    
    Canvas.TextSize(CurrentVoteName, TextWidth, TextHeight, TextScale, TextScale);
    Y = TextHeight;
    X = (Canvas.ClipX - TextWidth) * 0.5;
    
    GUIStyle.DrawOutlinedBox(X, Y, TextWidth + ScaledBorderSize, TextHeight + ScaledBorderSize, ScaledBorderSize, HudMainColor, HudOutlineColor);
    
    Canvas.DrawColor = WhiteColor;
    GUIStyle.DrawTextShadow(CurrentVoteName, X, Y, 1, TextScale);
    
    Y += TextHeight;
    
    TextScale = OriginalTextScale + 0.3;
    
    Canvas.DrawColor = WhiteColor;
    Canvas.TextSize(CurrentVoteStatus, TextWidth, TextHeight, TextScale, TextScale);
    
    X = (Canvas.ClipX - TextWidth) * 0.5;
    GUIStyle.DrawTextShadow(CurrentVoteStatus, X, Y, 1, TextScale);
    
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
    local int VoteTimeLeft;
    local KFPlayerInput KFInput;
    local KeyBind TempKeyBind;
    
    KFInput = KFPlayerInput(PlayerOwner.PlayerInput);
    
    VoteTimeLeft = Max(ActiveVote.VoteDuration - WorldInfo.TimeSeconds, 0);

    CurrentVoteStatus = GUIStyle.GetTimeString(VoteTimeLeft)@"-"@Class'KFCommon_LocalizedStrings'.default.YesString@"("$ActiveVote.YesVotes$")"@Class'KFCommon_LocalizedStrings'.default.NoString@"("$ActiveVote.NoVotes$")";

    KFInput.GetKeyBindFromCommand(TempKeyBind, "GBA_VoteYes");
    YesS = Class'KFCommon_LocalizedStrings'.default.YesString@"-"@Repl(KFInput.GetBindDisplayName(TempKeyBind), "XboxTypeS_", "");
    
    KFInput.GetKeyBindFromCommand(TempKeyBind, "GBA_VoteNo");
    NoS = Class'KFCommon_LocalizedStrings'.default.NoString@"-"@Repl(KFInput.GetBindDisplayName(TempKeyBind), "XboxTypeS_", "");
    
    C.Font = GUIStyle.PickFont(TextScale, FONT_NAME);
    
    C.DrawColor = MakeColor(0, 255, 0, 255);
    C.TextSize(YesS, TextWidth, TextHeight, TextScale, TextScale);
    X = (C.ClipX - TextWidth) * 0.5;
    GUIStyle.DrawTextShadow(YesS, X, Y, 1, TextScale); 

    Y += TextHeight;
    C.DrawColor = MakeColor(255, 0, 0, 255);
    C.TextSize(NoS, TextWidth, TextHeight, TextScale, TextScale);
    X = (C.ClipX - TextWidth) * 0.5;
    GUIStyle.DrawTextShadow(NoS, X, Y, 1, TextScale);         
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

// Hate this but can't add a Texture var for HUD textures to the weapons themselves.
function Texture GetClipIcon(KFWeapon Wep, bool bSingleFire)
{
    if( bSingleFire )
        return GetBulletIcon(Wep);
    else if( Wep.FireModeIconPaths[Wep.const.DEFAULT_FIREMODE] != None && Wep.FireModeIconPaths[Wep.const.DEFAULT_FIREMODE].Name == 'UI_FireModeSelect_Flamethrower' )
        return FlameTankIcon;
    
    return ClipsIcon;
}

function Texture GetBulletIcon(KFWeapon Wep)
{
    if( Wep.bUseAltFireMode )
        return GetSecondaryAmmoIcon(Wep);
    else if( Wep.IsA('KFWeap_Edged_IonThruster') )
        return BoltIcon;
    else
    {
        if( KFWeap_ThrownBase(Wep) != None && Wep.FireModeIconPaths[class'KFWeap_ThrownBase'.const.THROW_FIREMODE] != None )
        {
            Switch(Wep.FireModeIconPaths[class'KFWeap_ThrownBase'.const.THROW_FIREMODE].Name)
            {       
                case 'UI_FireModeSelect_Grenade':
                    return PipebombIcon;
            }
        }
        else if( Wep.FireModeIconPaths[Wep.const.DEFAULT_FIREMODE] != None )
        {
            Switch(Wep.FireModeIconPaths[Wep.const.DEFAULT_FIREMODE].Name)
            {
                case 'UI_FireModeSelect_Flamethrower':
                    return FlameIcon;
                case 'UI_FireModeSelect_Sawblade':
                    return SawbladeIcon;
                case 'UI_FireModeSelect_BulletSingle':
                    if( Wep.MagazineCapacity[Wep.const.DEFAULT_FIREMODE] > 1 )
                        return BulletsIcon;
                    return SingleBulletIcon;
                case 'UI_FireModeSelect_Grenade':
                    return M79Icon;
                case 'UI_FireModeSelect_MedicDart':
                    return SyringIcon;
                case 'UI_FireModeSelect_Rocket':
                    return RocketIcon;
                case 'UI_FireModeSelect_Electricity':
                    return BoltIcon;
                case 'UI_FireModeSelect_BulletBurst':
                    return BurstBulletIcon;
                case 'UI_FireModeSelect_BulletArrow':
                    return ArrowIcon;
            }
        }
    }
    
    return BulletsIcon;
}

function Texture GetSecondaryAmmoIcon(KFWeapon Wep)
{
    if( Wep.UsesSecondaryAmmo() && Wep.SecondaryAmmoTexture != None )
    {
        Switch(Wep.SecondaryAmmoTexture.Name)
        {
            case 'GasTank':
                return FlameTankIcon;
            case 'MedicDarts':
                return SyringIcon;
            case 'UI_FireModeSelect_Grenade':
                return M79Icon;
        }
    }
    else if( Wep.FireModeIconPaths[Wep.const.ALTFIRE_FIREMODE] != None )
    {
        Switch(Wep.FireModeIconPaths[Wep.const.ALTFIRE_FIREMODE].Name)
        {
            case 'UI_FireModeSelect_AutoTarget':
            case 'UI_FireModeSelect_ManualTarget':
                return AutoTargetIcon;
            case 'UI_FireModeSelect_BulletBurst':
                return BurstBulletIcon;
            case 'UI_FireModeSelect_BulletSingle':
                if( Wep.MagazineCapacity[Wep.ALTFIRE_FIREMODE] > 1 )
                    return BulletsIcon;
                else return SingleBulletIcon;
            case 'UI_FireModeSelect_Electricity':
                return BoltIcon;
            case 'UI_FireModeSelect_MedicDart':
                return SyringIcon;
        }
    }
    
    return SingleBulletIcon;
}

function byte DrawToDistance(Actor A, optional float StartAlpha=255.f, optional float MinAlpha=90.f)
{
    local float Dist, fZoom;

    Dist = VSize(A.Location - PLCameraLoc);
    if ( Dist <= HealthBarFullVisDist || PlayerOwner.PlayerReplicationInfo.bOnlySpectator )
        fZoom = 1.0;
    else fZoom = FMax(1.0 - (Dist - HealthBarFullVisDist) / (HealthBarCutoffDist - HealthBarFullVisDist), 0.0);
    
    return Clamp(StartAlpha * fZoom, MinAlpha, StartAlpha);
}

simulated function bool DrawFriendlyHumanPlayerInfo( KFPawn_Human KFPH )
{
    local float Percentage;
    local float BarHeight, BarLength;
    local vector ScreenPos, TargetLocation;
    local KFPlayerReplicationInfo KFPRI;
    local float FontScale;
    local float ResModifier;
    local float PerkIconPosX, PerkIconPosY, SupplyIconPosX, SupplyIconPosY, PerkIconXL, BarY;
    local color CurrentArmorColor, CurrentHealthColor;
    local byte FadeAlpha, PerkLevel;
    local class<ClassicPerk_Base> PerkClass;
    local FontRenderInfo MyFontRenderInfo;

    MyFontRenderInfo = Canvas.CreateFontRenderInfo(true);
    ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;
    KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

    if( KFPRI == None )
        return false;

    BarLength = FMin(PlayerStatusBarLengthMax * (Canvas.ClipX / 1024.f), PlayerStatusBarLengthMax) * ResModifier;
    BarHeight = FMin(8.f * (Canvas.ClipX / 1024.f), 8.f) * ResModifier;

    TargetLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,2.5f) );
    ScreenPos = Canvas.Project( TargetLocation );
    if( ScreenPos.X < 0 || ScreenPos.X > Canvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.ClipY )
        return false;
        
    FadeAlpha = DrawToDistance(KFPH);

    //Draw player name (Top)
    Canvas.Font = GUIStyle.PickFont(FontScale);
    FontScale *= FriendlyHudScale;

    //Player name text
    Canvas.DrawColor = WhiteColor;
    Canvas.DrawColor.A = FadeAlpha;
    GUIStyle.DrawTextShadow(KFPRI.PlayerName, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - 3.5f, 1, FontScale, MyFontRenderInfo);
    
    //Info Color
    switch(PlayerInfoType)
    {
        case INFO_CLASSIC:
            CurrentArmorColor = BlueColor;
            CurrentHealthColor = RedColor;
            break;
        case INFO_LEGACY:
            CurrentArmorColor = ClassicArmorColor;
            CurrentHealthColor = ClassicHealthColor;
            break;
        case INFO_MODERN:
            CurrentArmorColor = ArmorColor;
            CurrentHealthColor = HealthColor;
            break;    
    }
    
    CurrentArmorColor.A = FadeAlpha;
    CurrentHealthColor.A = FadeAlpha;
    
    BarY = ScreenPos.Y + BarHeight + (36 * FontScale * ResModifier);
        
    //Draw armor bar
    Percentage = FMin(float(KFPH.Armor) / float(KFPH.MaxArmor), 100);
    DrawPlayerInfo(KFPH, Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), BarY, CurrentArmorColor, PlayerInfoType == INFO_CLASSIC);

    if( PlayerInfoType == INFO_CLASSIC )
        BarY += BarHeight + 5;
    else BarY += BarHeight;
    
    //Draw health bar
    Percentage = FMin(float(KFPH.Health) / float(KFPH.HealthMax), 100);
    DrawPlayerInfo(KFPH, Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), BarY, CurrentHealthColor, PlayerInfoType == INFO_CLASSIC, true);

    BarY += BarHeight;
    
    PerkClass = class<ClassicPerk_Base>(KFPRI.CurrentPerkClass);
    if( PerkClass == None )
        return false;
        
    PerkLevel = KFPRI.GetActivePerkLevel();

    //Draw perk level and name text
    Canvas.DrawColor = WhiteColor;
    Canvas.DrawColor.A = FadeAlpha;
    GUIStyle.DrawTextShadow(PerkLevel@PerkClass.static.GetPerkName(), ScreenPos.X - (BarLength * 0.5f), BarY, 1, FontScale, MyFontRenderInfo);

    // drop shadow for perk icon
    Canvas.DrawColor = PlayerBarShadowColor;
    Canvas.DrawColor.A = FadeAlpha;
    PerkIconXL = PlayerStatusIconSize * ResModifier;
    PerkIconPosX = ScreenPos.X - (BarLength * 0.5f) - PerkIconXL + 1;
    PerkIconPosY = ScreenPos.Y + (PerkIconXL/2) - (BarHeight/2) + (PlayerInfoType == INFO_CLASSIC ? 6 : 1);
    SupplyIconPosX = ScreenPos.X + (BarLength * 0.5f) + 1;
    SupplyIconPosY = PerkIconPosY + 4 * ResModifier;
    DrawPerkIcons(KFPH, PerkIconXL, PerkIconPosX, PerkIconPosY, SupplyIconPosX, SupplyIconPosY, true);

    //draw perk icon
    Canvas.DrawColor = PerkClass.static.GetPerkColor(PerkLevel);
    Canvas.DrawColor.A = FadeAlpha;
    PerkIconPosX = ScreenPos.X - (BarLength * 0.5f) - PerkIconXL;
    PerkIconPosY = ScreenPos.Y + (PerkIconXL/2) - (BarHeight/2) + (PlayerInfoType == INFO_CLASSIC ? 5 : 0);
    SupplyIconPosX = ScreenPos.X + (BarLength * 0.5f);
    SupplyIconPosY = PerkIconPosY + 4 * ResModifier;
    DrawPerkIcons(KFPH, PerkIconXL, PerkIconPosX, PerkIconPosY, SupplyIconPosX, SupplyIconPosY, false);

    return true;
}

simulated function DrawPerkIcons(KFPawn_Human KFPH, float PerkIconXL, float PerkIconPosX, float PerkIconPosY, float SupplyIconPosX, float SupplyIconPosY, bool bDropShadow)
{
    local byte PrestigeLevel;
    local KFPlayerReplicationInfo KFPRI;
    local color TempColor;
    local float ResModifier;
    local byte FadeAlpha;

    KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);
    if( KFPRI == None )
        return;

    if( class<ClassicPerk_Base>(KFPRI.CurrentPerkClass) == None )
        return;
        
    PrestigeLevel = KFPRI.GetActivePerkPrestigeLevel();
    ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;
    FadeAlpha = Canvas.DrawColor.A;

    if (KFPRI.CurrentVoiceCommsRequest == VCT_NONE && KFPRI.CurrentPerkClass != none && PrestigeLevel > 0)
    {
        Canvas.SetPos(PerkIconPosX, PerkIconPosY);
        Canvas.DrawTile(KFPRI.CurrentPerkClass.default.PrestigeIcons[PrestigeLevel - 1], PerkIconXL, PerkIconXL, 0, 0, 256, 256);
    }

    if (PrestigeLevel > 0)
    {
        Canvas.SetPos(PerkIconPosX + (PerkIconXL * (1 - PrestigeIconScale)) / 2, PerkIconPosY + PerkIconXL * 0.05f);
        Canvas.DrawTile(KFPRI.GetCurrentIconToDisplay(), PerkIconXL * PrestigeIconScale, PerkIconXL * PrestigeIconScale, 0, 0, 256, 256);
    }
    else
    {
        Canvas.SetPos(PerkIconPosX, PerkIconPosY);
        Canvas.DrawTile(KFPRI.GetCurrentIconToDisplay(), PerkIconXL, PerkIconXL, 0, 0, 256, 256);
    }

    if (KFPRI.PerkSupplyLevel > 0 && KFPRI.CurrentPerkClass.static.GetInteractIcon() != none)
    {
        if (!bDropShadow)
        {
            if (KFPRI.PerkSupplyLevel == 2)
            {
                if (KFPRI.bPerkPrimarySupplyUsed && KFPRI.bPerkSecondarySupplyUsed)
                {
                    TempColor = SupplierActiveColor;
                }
                else if (KFPRI.bPerkPrimarySupplyUsed || KFPRI.bPerkSecondarySupplyUsed)
                {
                    TempColor = SupplierHalfUsableColor;
                }
                else
                {
                    TempColor = SupplierUsableColor;
                }
            }
            else if (KFPRI.PerkSupplyLevel == 1)
            {
                TempColor = KFPRI.bPerkPrimarySupplyUsed ? SupplierActiveColor : SupplierUsableColor;
            }

            Canvas.DrawColor = TempColor;
            Canvas.DrawColor.A = FadeAlpha;
        }

        Canvas.SetPos(SupplyIconPosX, SupplyIconPosY);
        Canvas.DrawTile(KFPRI.CurrentPerkClass.static.GetInteractIcon(), (PlayerStatusIconSize * 0.75) * ResModifier, (PlayerStatusIconSize * 0.75) * ResModifier, 0, 0, 256, 256);
    }
}

simulated function DrawPlayerInfo( KFPawn_Human P, float BarPercentage, float BarLength, float BarHeight, float XPos, float YPos, Color BarColor, optional bool bDrawOutline, optional bool bDrawingHealth )
{
    if( bDrawOutline )
    {
        Canvas.SetDrawColor(185, 185, 185, 255);
        GUIStyle.DrawBoxHollow(XPos - 2, YPos - 2, BarLength + 4, BarHeight + 4, 1);
        
        Canvas.SetPos(XPos, YPos);
        Canvas.DrawColor = PlayerBarBGColor;
        Canvas.DrawTileStretched(PlayerStatusBarBGTexture, BarLength, BarHeight, 0, 0, 32, 32);
        
        Canvas.SetPos(XPos, YPos);
        Canvas.DrawColor = BarColor;
        Canvas.DrawTileStretched(PlayerStatusBarBGTexture, BarLength * BarPercentage, BarHeight, 0, 0, 32, 32);
    }
    else DrawKFBar(BarPercentage, BarLength, BarHeight, XPos, YPos, BarColor);
    
    if( bDrawRegenBar && bDrawingHealth && ClassicHumanPawn(P) != None && P.Health<P.HealthMax && ClassicHumanPawn(P).RepRegenHP>0 )
    {
        if( !bDrawOutline )
        {
            YPos += 1;
            BarLength -= 2.0;
            BarHeight -= 2.0;
        }
        
        // Draw to-regen bar.
        XPos+=(BarLength * BarPercentage);
        BarPercentage = FMin(float(ClassicHumanPawn(P).RepRegenHP) / float(P.HealthMax),1.f-BarPercentage);

        Canvas.SetDrawColor(255,128,128,255);
        Canvas.SetPos(XPos, YPos);
        Canvas.DrawTileStretched(PlayerStatusBarBGTexture, BarLength * BarPercentage, BarHeight, 0, 0, 32, 32);
    }
}

function DrawHiddenHumanPlayerIcon( PlayerReplicationInfo PRI, vector IconWorldLocation, float NormalizedAngle)
{
    local vector ScreenPos;
    local float IconSizeMult;
    local KFPlayerReplicationInfo KFPRI;
    local Texture2D PlayerIcon;
    local float ResModifier;
    local Color PerkColor, IconColor;
    local byte PerkLevel;

    ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;

    KFPRI = KFPlayerReplicationInfo(PRI);
    if( KFPRI == None )
        return;

    ScreenPos = Canvas.Project(IconWorldLocation + class'KFPawn_Human'.default.CylinderComponent.CollisionHeight * vect(0, 0, 2));

    IconSizeMult = (PlayerStatusIconSize * 0.8) * ResModifier;
    ScreenPos.X -= IconSizeMult;
    ScreenPos.Y -= IconSizeMult;

    if (NormalizedAngle > 0)
    {
        if (ScreenPos.X < 0 || ScreenPos.X > Canvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.ClipY )
        {
            if (KFPRI.CurrentVoiceCommsRequest != VCT_NONE)
            {
                IconColor = WhiteColor;
                IconColor.A = Clamp(Sin(WorldInfo.TimeSeconds * 8) * 200 + 255, 0, 255);
                
                ScreenPos.X = Canvas.ClipX - ScreenPos.x;
                ScreenPos = GetClampedScreenPosition(ScreenPos);
                
                Canvas.DrawColor = IconColor;
                Canvas.SetPos(ScreenPos.X - (IconSizeMult * VoiceCommsIconHighlightScale / 2), ScreenPos.Y - (IconSizeMult * VoiceCommsIconHighlightScale / 2));
                Canvas.DrawTile(IconHighLightTexture, IconSizeMult + (IconSizeMult * VoiceCommsIconHighlightScale), IconSizeMult + (IconSizeMult * VoiceCommsIconHighlightScale), 0, 0, 128, 128);
            }
            else return;
        }
    }
    else if (KFPRI.CurrentVoiceCommsRequest != VCT_NONE)
    {
        IconColor = WhiteColor;
        IconColor.A = Clamp(Sin(WorldInfo.TimeSeconds * 8) * 200 + 255, 0, 255);
        
        ScreenPos = GetClampedScreenPosition(ScreenPos);
        
        Canvas.DrawColor = IconColor;
        Canvas.SetPos(ScreenPos.X - (IconSizeMult * VoiceCommsIconHighlightScale / 2), ScreenPos.Y - (IconSizeMult * VoiceCommsIconHighlightScale / 2));
        Canvas.DrawTile(IconHighLightTexture, IconSizeMult + (IconSizeMult * VoiceCommsIconHighlightScale), IconSizeMult + (IconSizeMult * VoiceCommsIconHighlightScale), 0, 0, 128, 128);
    }
    else return;

    PerkLevel = KFPRI.GetActivePerkLevel();
    PlayerIcon = PlayerOwner.GetTeamNum() == 0 ? KFPRI.GetCurrentIconToDisplay() : GenericHumanIconTexture;
    
    if( class<ClassicPerk_Base>(KFPRI.CurrentPerkClass) != None )
    {
        PerkColor = class<ClassicPerk_Base>(KFPRI.CurrentPerkClass).static.GetPerkColor(PerkLevel);
        PerkColor.A = 192;
    }
    else PerkColor = MakeColor(255, 255, 255, 192);

    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.SetPos(ScreenPos.X + 1, ScreenPos.Y + 1);
    Canvas.DrawTile(PlayerIcon, IconSizeMult, IconSizeMult, 0, 0, 256, 256);

    if( KFPRI.CurrentVoiceCommsRequest == VCT_NONE )
        Canvas.DrawColor = PerkColor;
    else Canvas.SetDrawColor(255, 255, 255, 192);
    
    Canvas.SetPos( ScreenPos.X, ScreenPos.Y );
    Canvas.DrawTile( PlayerIcon, IconSizeMult, IconSizeMult, 0, 0, 256, 256 );
}

function DrawRhythmCounter()
{
    local float RhythmX, RhythmY, RhythmW, RhythmH, IconX, IconY, IconW, IconH, CountX, CountY, FontScaler, XL, YL, ProgressX, ProgressY, ProgressW, ProgressH;
    local string S;
    
    RhythmW = Canvas.ClipX*0.0775;
    RhythmH = (Canvas.ClipX*0.05)-(ScaledBorderSize*4);
    
    RhythmX = (Canvas.ClipX*0.5) - (RhythmW/2);
    RhythmY = Canvas.ClipY * 0.125;
    
    GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, RhythmX, RhythmY+(ScaledBorderSize*4), RhythmW, RhythmH, HudMainColor, false, false, true, true);
    GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*4, RhythmX, RhythmY, RhythmW, ScaledBorderSize*4, MakeColor(60, 60, 60, 255), true, true, false, false);
    
    IconH = RhythmH * 0.6;
    IconW = IconH;
    
    IconX = RhythmX + ScaledBorderSize;
    IconY = RhythmY + (RhythmH/2) - (IconH/1.5f) + (ScaledBorderSize*2);
    
    Canvas.DrawColor = class'HUD'.default.WhiteColor;
    Canvas.SetPos(IconX, IconY);
    Canvas.DrawRect(IconW, IconH, RhythmHUDIcon);
    
    S = CurrentRhythmCount$"X";
    
    Canvas.Font = GUIStyle.PickFont(FontScaler);
    FontScaler += 0.5;
    
    Canvas.TextSize(S, XL, YL, FontScaler, FontScaler);
    
    CountX = RhythmX + (RhythmW - XL - (ScaledBorderSize*4));
    CountY = RhythmY + (RhythmH/2) - (YL/1.5f) + (ScaledBorderSize*2);
    
    Canvas.SetPos(CountX, CountY);
    Canvas.DrawText(S,, FontScaler, FontScaler);
    
    ProgressH = RhythmH * 0.175;
    ProgressW = (RhythmW * 0.95) - (ScaledBorderSize*4);
    
    ProgressX = RhythmX + (RhythmW/2) - (ProgressW/2);
    ProgressY = (RhythmY+RhythmH) - ProgressH;
    
    GUIStyle.DrawRoundedBox(ScaledBorderSize, ProgressX, ProgressY, ProgressW, ProgressH, DefaultHudMainColor);
    GUIStyle.DrawRoundedBox(ScaledBorderSize, ProgressX, ProgressY, ProgressW*(float(CurrentRhythmCount) / float(CurrentRhythmMax)), ProgressH, MakeColor(173, 17, 22, 255));
}

function UpdateRhythmCounter(int Current, int Max)
{
    CurrentRhythmCount = Min(Current, Max);
    if( Max != CurrentRhythmMax )
        CurrentRhythmMax = Max;
}

function RenderKillMsg()
{
    local float Sc,PDSc,CurrentSc,XL,YL,TextXL,TextYL,PDYL,T,Y;
    local string S;
    local int i;
    local KFInterface_MapObjective MapObjective;
    
    Canvas.Font = GUIStyle.PickFont(Sc);
    Canvas.TextSize("A",XL,YL,Sc,Sc);
    
    PDSc = Sc*1.375f;
    Canvas.TextSize("A",XL,PDYL,PDSc,PDSc);

    MapObjective = KFInterface_MapObjective(KFGRI.CurrentObjective);
    if( MapObjective == None )
        MapObjective = KFInterface_MapObjective(KFGRI.PreviousObjective);
        
    if( MapObjective != None && (MapObjective.IsActive() || ((MapObjective.IsComplete() || MapObjective.HasFailedObjective()) && KFGRI.bWaveIsActive)) )
        Y = Canvas.ClipY*0.235;
    else Y = Canvas.ClipY*0.15;
    
    for( i=0; i<KillMessages.Length; ++i )
    {
        T = WorldInfo.TimeSeconds-KillMessages[i].MsgTime;

        if( KillMessages[i].bDamage )
            S = "-"$KillMessages[i].Counter$" HP "$KillMessages[i].Name;
        else if( KillMessages[i].bLocal )
            S = "+"$KillMessages[i].Counter@KillMessages[i].Name$(KillMessages[i].Counter>1 ? " kills" : " kill");
        else if( KillMessages[i].bPlayerDeath )
            S = (KillMessages[i].bSuicide ? "" : KillMessages[i].Name)$" <Icon>UI_PerkIcons_TEX.UI_PerkIcon_ZED</Icon> "$(KillMessages[i].OwnerPRI!=None ? KillMessages[i].OwnerPRI.GetHumanReadableName() : "Someone");
        else S = (KillMessages[i].OwnerPRI!=None ? KillMessages[i].OwnerPRI.GetHumanReadableName() : "Someone")$" +"$KillMessages[i].Counter@KillMessages[i].Name$(KillMessages[i].Counter>1 ? " kills" : " kill");
        
        CurrentSc = KillMessages[i].bPlayerDeath ? PDSc : Sc;
        
        if( T>6.f )
        {
            KillMessages[i].CurrentXPosition -= RenderDelta*400.f;
            
            Canvas.TextSize(GUIStyle.StripTextureFromString(S),TextXL,TextYL,CurrentSc,CurrentSc);
            if( (KillMessages[i].CurrentXPosition+TextXL) <= 0.f )
            {
                KillMessages.Remove(i--,1);
                continue;
            }
        }
        else
        {
            KillMessages[i].CurrentXPosition += RenderDelta*200.f;
            KillMessages[i].CurrentXPosition = FMin(KillMessages[i].CurrentXPosition, KillMessages[i].XPosition);
        }
        
        Canvas.DrawColor = KillMessages[i].MsgColor;
        GUIStyle.DrawTexturedString(S, KillMessages[i].CurrentXPosition, Y, CurrentSc,, true);
        Y+=KillMessages[i].bPlayerDeath ? PDYL : YL;
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

function AddPlayerDeathMessage(class<Pawn> Victim, Pawn Killer, PlayerReplicationInfo PRI, bool FriendlyKill)
{
    local FKillMessageType Msg;
    
    if( Killer == None || Victim == None )
        return;
    
    Msg.bPlayerDeath = true;
    Msg.Type = Victim;
    Msg.OwnerPRI = PRI;
    Msg.MsgTime = WorldInfo.TimeSeconds;
    Msg.Name = FriendlyKill ? Killer.GetHumanReadableName() : GetNameOf(Killer.Class);
    Msg.bSuicide = !FriendlyKill && Victim == Killer.Class;
    Msg.MsgColor = MakeColor(0, 162, 232, 255);
    Msg.XPosition = GUIController.ScreenSize.X*0.015;
    
    KillMessages.AddItem(Msg);
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
    KillMessages[i].XPosition = GUIController.ScreenSize.X*0.015;
}

function AddNumberMsg( int Amount, vector Pos, class<KFDamageType> Type )
{
    local vector RandVect;
    local EDamageOverTimeGroup DotType;
    
    RandVect.X = RandRange(-64, 64);
    RandVect.Y = RandRange(-64, 64);
    RandVect.Z = RandRange(-64, 64);

    DamagePopups[NextDamagePopupIndex].Damage = Amount;
    DamagePopups[NextDamagePopupIndex].HitTime = WorldInfo.TimeSeconds;
    DamagePopups[NextDamagePopupIndex].HitLocation = Pos;
    DamagePopups[NextDamagePopupIndex].RandVect = RandVect;
    
    if( Type == None )
        DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_Unspecified];
    else
    {
        DotType = Type.default.DoT_Type;
        if( DotType == DOT_Fire )
            DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_Fire];
        else if( DotType == DOT_Toxic )
            DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_Toxic];
        else if( DotType == DOT_Bleeding )
            DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_Bleeding];
        else if( Type.default.EMPPower > 0.f )
            DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_EMP];
        else if( Type.default.FreezePower > 0.f )
            DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_Freeze];
        else if( class<KFDT_Explosive_FlashBangGrenade>(Type) != None )
            DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_Flashbang];
        else if ( Amount < 100 )
            DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_Generic];
        else if ( Amount >= 175 )
            DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_High];
        else DamagePopups[NextDamagePopupIndex].FontColor = DamageMsgColors[DMG_Medium];
    }
    
    if( ++NextDamagePopupIndex >= DAMAGEPOPUP_COUNT)
        NextDamagePopupIndex=0;
}

function DrawDamage()
{
    local int i, Vel;
    local float TimeSinceHit, TextWidth, TextHeight, Sc, TextX, TextY;
    local vector HBScreenPos;
    local string S;

    Canvas.Font = GUIStyle.PickFont(Sc, FONT_NAME);
    
    for( i=0; i < DAMAGEPOPUP_COUNT ; i++ ) 
    {
        TimeSinceHit = `TimeSince(DamagePopups[i].HitTime);
        if( TimeSinceHit > DamagePopupFadeOutTime || ( Normal(DamagePopups[i].HitLocation - PLCameraLoc) dot Normal(PLCameraDir) < 0.1 ) ) //don't draw if player faced back to the hit location
            continue;
            
        S = string(DamagePopups[i].Damage);
            
        Canvas.TextSize(S,TextWidth,TextHeight,Sc,Sc);
        Vel = RenderDelta*900.f;

        if ( i % 2 == 0 )
            DamagePopups[i].RandVect.X *= -1.f;
        
        DamagePopups[i].HitLocation += DamagePopups[i].RandVect*RenderDelta;
        if( (TimeSinceHit/DamagePopupFadeOutTime) < 0.035f )
            DamagePopups[i].RandVect.Z += Vel*2;
        else DamagePopups[i].RandVect.Z -= Vel;
        
        HBScreenPos = Canvas.Project(DamagePopups[i].HitLocation);
        
        TextX = HBScreenPos.X-(TextWidth*0.5f);
        TextY = HBScreenPos.Y-(TextHeight*0.5f);
        if( TextX < 0 || TextX > Canvas.ClipX || TextY < 0 || TextY > Canvas.ClipY )
            continue;

        Canvas.DrawColor = DamagePopups[i].FontColor;
        Canvas.DrawColor.A = 255 * Cos(0.5f * Pi * TimeSinceHit/DamagePopupFadeOutTime);
        
        GUIStyle.DrawTextShadow(S, TextX, TextY, 1, Sc);
    }
}

function DrawXPEarned(float X, float Y)
{
    local int i;
    local float EndTime, TextWidth, TextHeight, Sc, FadeAlpha;
    local string S;

    Canvas.Font = GUIStyle.PickFont(Sc);
    
    for( i=0; i<XPEARNED_COUNT; i++ ) 
    {
        EndTime = `RealTimeSince(XPPopups[i].StartTime);
        if( EndTime > XPFadeOutTime )
            continue;
            
        S = "+"$string(XPPopups[i].XP)@"XP";
        Canvas.TextSize(S,TextWidth,TextHeight,Sc,Sc);

        if( XPPopups[i].bInit )
        {
            XPPopups[i].XPos = X;
            XPPopups[i].YPos = Y-(TextHeight*0.5f);
            XPPopups[i].bInit = false;
        }
        
        if( XPPopups[i].XPos > 0.f && XPPopups[i].XPos < Canvas.ClipX )
            XPPopups[i].XPos += Asin(2 * Pi * EndTime/XPFadeOutTime) * (i % 2 == 0 ? -XPPopups[i].RandX : XPPopups[i].RandX);
        else XPPopups[i].XPos = FClamp(XPPopups[i].XPos, 0, Canvas.ClipX);
        
        XPPopups[i].YPos -= (RenderDelta*62.f) * XPPopups[i].RandY;

        FadeAlpha = 255 * Cos(0.5f * Pi * EndTime/XPFadeOutTime);
        if( XPPopups[i].Icon != None )
        {
            Canvas.DrawColor = PlayerBarShadowColor;
            Canvas.DrawColor.A = FadeAlpha;
            
            Canvas.SetPos(XPPopups[i].XPos+1, XPPopups[i].YPos+1);
            Canvas.DrawRect(TextHeight*1.25f, TextHeight*1.25f, XPPopups[i].Icon);
            
            Canvas.DrawColor = XPPopups[i].IconColor;
            Canvas.DrawColor.A = FadeAlpha;
            
            Canvas.SetPos(XPPopups[i].XPos, XPPopups[i].YPos);
            Canvas.DrawRect(TextHeight*1.25f, TextHeight*1.25f, XPPopups[i].Icon);
            
            Canvas.SetDrawColor(255, 255, 255, FadeAlpha);
            GUIStyle.DrawTextShadow(S, XPPopups[i].XPos+(TextHeight*1.25f)+(ScaledBorderSize*2), XPPopups[i].YPos, 1, Sc);
        }
        else
        {
            Canvas.SetDrawColor(255, 255, 255, FadeAlpha);
            GUIStyle.DrawTextShadow(S, XPPopups[i].XPos, XPPopups[i].YPos, 1, Sc);
        }
    }
}

function NotifyXPEarned( int XP, Texture2D Icon, Color IconColor )
{
    XPPopups[NextXPPopupIndex].XP = XP;
    XPPopups[NextXPPopupIndex].StartTime = WorldInfo.RealTimeSeconds;
    XPPopups[NextXPPopupIndex].RandX = 2.f * FRand();
    XPPopups[NextXPPopupIndex].RandY = 1.f + FRand();
    XPPopups[NextXPPopupIndex].Icon = Icon;
    XPPopups[NextXPPopupIndex].IconColor = IconColor;
    XPPopups[NextXPPopupIndex].bInit = true;
    
    if( ++NextXPPopupIndex >= XPEARNED_COUNT)
        NextXPPopupIndex=0;
}

function string GetSpeedStr()
{
    local int Speed;
    local string S;
    local vector Velocity2D;

    if ( KFPawn(PlayerOwner.Pawn) == None )
        return S;

    Velocity2D = PlayerOwner.Pawn.Velocity;
    Velocity2D.Z = 0;
    Speed = VSize(Velocity2D);
    S = string(Speed) $ "/" $ int(PlayerOwner.Pawn.GroundSpeed);

    if ( Speed >= int(KFPawn(PlayerOwner.Pawn).SprintSpeed) ) 
        Canvas.SetDrawColor(0, 100, 255);
    else if ( Speed >= int(PlayerOwner.Pawn.GroundSpeed) )
        Canvas.SetDrawColor(0, 206, 0);
    else Canvas.SetDrawColor(255, 64, 64);

    return S;
}

function DrawSpeedMeter()
{
    local float FontScalar, XL, YL;
    local string S;
    
    S = GetSpeedStr() $ " ups";
    
    Canvas.Font = GUIStyle.PickFont(FontScalar);
    Canvas.TextSize(S,XL,YL,FontScalar,FontScalar);
    
    GUIStyle.DrawTextShadow(S, Canvas.ClipX - XL + (ScaledBorderSize*2), Canvas.ClipY * 0.80, 1, FontScalar);
}

function DrawMedicWeaponRecharge()
{
    local KFWeap_MedicBase KFWMB;
    local float IconBaseX, IconBaseY, IconHeight, IconWidth;
    local float IconRatioY, ChargePct, ChargeBaseY, WeaponBaseX;
    local color ChargeColor;
    
    if (PlayerOwner.Pawn.InvManager == None)
        return;

    IconRatioY = Canvas.ClipY / 1080.0;
    IconHeight = MedicWeaponHeight * IconRatioY;
    IconWidth = IconHeight / 2.0;

    IconBaseX = (Canvas.ClipX * 0.85) - IconWidth;
    IconBaseY = Canvas.ClipY * 0.8125;
    
    WeaponBaseX = IconBaseX;

    Canvas.EnableStencilTest(false);
    foreach PlayerOwner.Pawn.InvManager.InventoryActors(class'KFWeap_MedicBase', KFWMB)
    {
        if (KFWMB == PlayerOwner.Pawn.Weapon || !KFWMB.bRechargeHealAmmo)
            continue;
            
        GUIStyle.DrawRoundedBox(ScaledBorderSize*2, WeaponBaseX, IconBaseY, IconWidth, IconHeight, MedicWeaponBGColor);
        
        ChargePct = float(KFWMB.AmmoCount[1]) / float(KFWMB.MagazineCapacity[1]);
        ChargeBaseY = IconBaseY + IconHeight * (1.0 - ChargePct);
        ChargeColor = (KFWMB.HasAmmo(1) ? MedicWeaponChargedColor : MedicWeaponNotChargedColor);
        GUIStyle.DrawRoundedBox(ScaledBorderSize*2, WeaponBaseX, ChargeBaseY, IconWidth, IconHeight * ChargePct, ChargeColor);
        
        Canvas.DrawColor = WeaponIconColor;
        Canvas.SetPos(WeaponBaseX + IconWidth, IconBaseY);
        Canvas.DrawRotatedTile(KFWMB.WeaponSelectTexture, MedicWeaponRot, IconHeight, IconWidth, 0, 0, KFWMB.WeaponSelectTexture.GetSurfaceWidth(), KFWMB.WeaponSelectTexture.GetSurfaceHeight(), 0, 0);
        
        WeaponBaseX -= IconWidth * 1.2;
    }
    Canvas.EnableStencilTest(true);
}

function DrawMedicWeaponLockOn(KFWeap_MedicBase KFW)
{
    local KFPawn CurrentActor;
    local color IconColor;
    local vector ScreenPos;
    local float IconSize, RealIconSize;

    if (KFW.LockedTarget != None)
    {
        CurrentActor = KFPawn(KFW.LockedTarget);
        IconColor = MedicLockOnColor;
    }
    else if (KFW.PendingLockedTarget != None)
    {
        CurrentActor = KFPawn(KFW.PendingLockedTarget);
        IconColor = MedicPendingLockOnColor;
    }

    if (CurrentActor == None)
    {
        OldTarget = None;
        return;
    }
        
    if (CurrentActor != OldTarget)
    {
        LockOnStartTime = WorldInfo.RealTimeSeconds;
        LockOnEndTime = WorldInfo.RealTimeSeconds+0.15;
        OldTarget = CurrentActor;
    }

    ScreenPos = Canvas.Project(CurrentActor.Mesh.GetPosition() + (CurrentActor.CylinderComponent.CollisionHeight * vect(0,0,1.25)));
    if (ScreenPos.X < 0 || ScreenPos.X > Canvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.ClipY)
        return;

    IconSize = WorldInfo.static.GetResolutionBasedHUDScale() * MedicLockOnIconSize;
    RealIconSize = FInterpEaseInOut(IconSize*2, IconSize, GUIStyle.TimeFraction(LockOnStartTime, LockOnEndTime, WorldInfo.RealTimeSeconds), 2.5);
    
    Canvas.DrawColor = IconColor;
    Canvas.SetPos(ScreenPos.X - (RealIconSize / 2.0), ScreenPos.Y - (RealIconSize / 2.0));
    Canvas.DrawRect(RealIconSize, RealIconSize, MedicLockOnIcon);
}

function DrawWeaponPickupInfo()
{
    local vector ScreenPos;
    local bool bHasAmmo, bHasSingleForDual, bCanCarry;
    local Inventory Inv;
    local KFInventoryManager KFIM;
    local string AmmoText, WeightText;
    local class<KFWeapon> KFWC;
    local int Weight;
    local color CanCarryColor;
    local FontRenderInfo FRI;
    local float FontScale, ResModifier, IconSize;
    local float AmmoTextWidth, WeightTextWidth, TextWidth, TextHeight, TextYOffset, SecondaryBGWidth, SecondaryBGHeight;
    local float InfoBaseX, InfoBaseY;
    local float BGX, BGY, BGWidth, BGHeight;
    local string S;

    ScreenPos = Canvas.Project(WeaponPickup.Location + vect(0,0,25));
    if (ScreenPos.X < 0 || ScreenPos.X > Canvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.ClipY)
        return;
        
    bHasAmmo = WeaponPickup.MagazineAmmo[0] >= 0;

    if (bHasAmmo)
    {
        AmmoText = WeaponPickup.MagazineAmmo[0] $ "/" $ WeaponPickup.SpareAmmo[0];

        if (WeaponPickup.MagazineAmmo[1] >= 0 && WeaponPickup.SpareAmmo[1] >= 0)
            AmmoText @= "(" $ WeaponPickup.MagazineAmmo[1] $ "/" $ WeaponPickup.SpareAmmo[1] $ ")";
        else if (WeaponPickup.MagazineAmmo[1] >= 0)
            AmmoText @= "(" $ WeaponPickup.MagazineAmmo[1] $ ")";
        else if (WeaponPickup.SpareAmmo[1] >= 0)
            AmmoText @= "(" $ WeaponPickup.SpareAmmo[1] $ ")";
    }
    else AmmoText = "---";

    KFWC = class<KFWeapon>(WeaponPickup.InventoryClass);
    if (KFWC.default.DualClass != None && PlayerOwner.Pawn != None && PlayerOwner.Pawn.InvManager != None)
    {
        Inv = PlayerOwner.Pawn.InvManager.FindInventoryType(KFWC);
        if (KFWeapon(Inv) != None)
            bHasSingleForDual = true;
    }

    if (bHasSingleForDual)
    {
        Weight = KFWC.default.DualClass.default.InventorySize +
            KFWC.default.DualClass.static.GetUpgradeWeight(Max(WeaponPickup.UpgradeLevel, KFWeapon(Inv).CurrentWeaponUpgradeIndex)) -
            KFWeapon(Inv).GetModifiedWeightValue();
    }
    else Weight = KFWC.default.InventorySize + KFWC.static.GetUpgradeWeight(WeaponPickup.UpgradeLevel);

    WeightText = string(Weight);
    if (WeaponPickup.UpgradeLevel > 0)
        WeightText @= "(+" $ WeaponPickup.UpgradeLevel $ ")";

    if (PlayerOwner.Pawn != None && KFInventoryManager(PlayerOwner.Pawn.InvManager) != None)
    {
        KFIM = KFInventoryManager(PlayerOwner.Pawn.InvManager);
        if (KFIM.CanCarryWeapon(KFWC, WeaponPickup.UpgradeLevel))
        {
            if (KFWC.default.DualClass != None)
                bCanCarry = !KFIM.ClassIsInInventory(KFWC.default.DualClass, Inv);
            else bCanCarry = !KFIM.ClassIsInInventory(KFWC, Inv);
        }
    }
    else bCanCarry = true;

    CanCarryColor = (bCanCarry ? WeaponIconColor : WeaponOverweightIconColor);

    FRI = Canvas.CreateFontRenderInfo(true);

    ResModifier = WorldInfo.static.GetResolutionBasedHUDScale();
    Canvas.Font = GUIStyle.PickFont(FontScale);

    if (bHasAmmo)
    {
        Canvas.TextSize(AmmoText, AmmoTextWidth, TextHeight, FontScale, FontScale);
        Canvas.TextSize(WeightText, WeightTextWidth, TextHeight, FontScale, FontScale);
        TextWidth = FMax(AmmoTextWidth, WeightTextWidth);
    }
    else Canvas.TextSize(WeightText, TextWidth, TextHeight, FontScale, FontScale);

    IconSize = WeaponIconSize * ResModifier;
    InfoBaseX = ScreenPos.X - ((IconSize * 1.5 + TextWidth) * 0.5);
    InfoBaseY = ScreenPos.Y;
    TextYOffset = (IconSize - TextHeight) * 0.5;

    BGWidth = IconSize * 2.0 + TextWidth;
    BGX = InfoBaseX - (IconSize * 0.25);
    if (bHasAmmo)
    {
        BGHeight = (IconSize * 2.5) * 1.25;
        BGY = InfoBaseY - (BGHeight * 0.125);
    }
    else
    {
        BGHeight = IconSize * 1.5;
        BGY = InfoBaseY + IconSize * 1.5 - (BGHeight * 0.125);
    }

    GUIStyle.DrawRoundedBox(ScaledBorderSize*2, BGX, BGY, BGWidth, BGHeight, HudMainColor);

    if (bHasAmmo)
    {
        Canvas.DrawColor = WeaponIconColor;
        Canvas.SetPos(InfoBaseX, InfoBaseY);
        Canvas.DrawTile(WeaponAmmoIcon, IconSize, IconSize, 0, 0, 256, 256);
    
        Canvas.DrawColor = WhiteColor;
        Canvas.SetPos(InfoBaseX + IconSize * 1.5, InfoBaseY + TextYOffset);
        Canvas.DrawText(AmmoText, , FontScale, FontScale, FRI);
    }

    Canvas.DrawColor = CanCarryColor;
    Canvas.SetPos(InfoBaseX, InfoBaseY + IconSize * 1.5);
    Canvas.DrawTile(WeaponWeightIcon, IconSize, IconSize, 0, 0, 256, 256);

    Canvas.DrawColor = WhiteColor;
    Canvas.SetPos(InfoBaseX + IconSize * 1.5, InfoBaseY + IconSize * 1.5 + TextYOffset);
    Canvas.DrawText(WeightText, , FontScale, FontScale, FRI);
    
    if( WeaponPickup.OwnerController != None )
    {
        S = WeaponPickup.OwnerController.PlayerReplicationInfo.GetHumanReadableName();
        Canvas.TextSize(S, TextWidth, TextHeight, FontScale, FontScale);
        
        SecondaryBGWidth = TextWidth * 1.125;
        SecondaryBGHeight = TextHeight * 1.125;
        
        BGY += BGHeight + (TextHeight/2);
        BGX += (BGWidth/2) - (SecondaryBGWidth/2);
        
        GUIStyle.DrawRoundedBox(ScaledBorderSize*2, BGX, BGY, SecondaryBGWidth, SecondaryBGHeight, HudMainColor);
        
        Canvas.DrawColor = WhiteColor;
        Canvas.SetPos(BGX + (SecondaryBGWidth/2) - (TextWidth/2), BGY + (SecondaryBGHeight/2) - (TextHeight/2));
        Canvas.DrawText(S, , FontScale, FontScale, FRI);
    }
}

exec function SetShowScores(bool bNewValue)
{
    bShowScores = bNewValue;
    if( Scoreboard!=None )
        Scoreboard.SetVisibility(bShowScores);
}

function DrawTraderIndicator()
{
    local KFTraderTrigger T;
    
    if( KFGRI == None || (KFGRI.OpenedTrader == None && KFGRI.NextTrader == None) )
        return;
    
    T = KFGRI.OpenedTrader != None ? KFGRI.OpenedTrader : KFGRI.NextTrader;
    if( T != None )
        DrawDirectionalIndicator(T.Location, bLightHUD ? TraderArrowLight : TraderArrow, Canvas.ClipY/33.f,, HudOutlineColor, class'KFGFxHUD_TraderCompass'.default.TraderString, true);
}

final function Vector DrawDirectionalIndicator(Vector Loc, Texture Mat, float IconSize, optional float FontMult=1.f, optional Color DrawColor=WhiteColor, optional string Text, optional bool bDrawBackground)
{
    local rotator R;
    local vector V,X;
    local float XS,YS,FontScalar,BoxW,BoxH,BoxX,BoxY;
    local Canvas.FontRenderInfo FI;
    local bool bWasStencilEnabled;

    FI.bClipText = true;
    Canvas.Font = GUIStyle.PickFont(FontScalar, FONT_NAME);
    FontScalar *= FontMult;
    
    X = PLCameraDir;
    
    // First see if on screen.
    V = Loc - PLCameraLoc;
    if( (V Dot X)>0.997 ) // Front of camera.
    {
        V = Canvas.Project(Loc+vect(0,0,1.055));
        if( V.X>0 && V.Y>0 && V.X<Canvas.ClipX && V.Y<Canvas.ClipY ) // Within screen bounds.
        {
            Canvas.EnableStencilTest(true);
            
            Canvas.DrawColor = PlayerBarShadowColor;
            Canvas.DrawColor.A = DrawColor.A;
            Canvas.SetPos(V.X-(IconSize*0.5)+1,V.Y-IconSize+1);
            Canvas.DrawRect(IconSize, IconSize, Mat);

            Canvas.DrawColor = DrawColor;
            Canvas.SetPos(V.X-(IconSize*0.5),V.Y-IconSize);
            Canvas.DrawRect(IconSize, IconSize, Mat);
            
            if( Text != "" )
            {
                Canvas.TextSize(Text,XS,YS,FontScalar,FontScalar);
                
                if( bDrawBackground )
                {
                    BoxW = XS+8.f;
                    BoxH = YS+8.f;
                    
                    BoxX = V.X - (BoxW*0.5);
                    BoxY = V.Y - IconSize - BoxH;
                    
                    GUIStyle.DrawOutlinedBox(BoxX, BoxY, BoxW, BoxH, FMax(ScaledBorderSize * 0.5, 1.f), HudMainColor, HudOutlineColor);
                   
                    Canvas.DrawColor = WhiteColor;
                    Canvas.SetPos(BoxX + (BoxW/2) - (XS/2), BoxY + (BoxH/2) - (YS/2));
                    Canvas.DrawText(Text,, FontScalar, FontScalar, FI);
                }
                else
                {
                    Canvas.DrawColor = WhiteColor;
                    GUIStyle.DrawTextShadow(Text, V.X-(XS*0.5), V.Y-IconSize-YS-4.f, 1, FontScalar);
                }
            }
            
            Canvas.EnableStencilTest(false);
            return V;
        }
    }
    
    bWasStencilEnabled = Canvas.bStencilEnabled;
    if( bWasStencilEnabled )
        Canvas.EnableStencilTest(false);
    
    // Draw the material towards the location.
    // First transform offset to local screen space.
    V = (Loc - PLCameraLoc) << PLCameraRot;
    V.X = 0;
    V = Normal(V);

    // Check pitch.
    R.Yaw = rotator(V).Pitch;
    if( V.Y>0 ) // Must flip pitch
        R.Yaw = 32768-R.Yaw;
    R.Yaw+=16384;

    // Check screen edge location.
    V = FindEdgeIntersection(V.Y,-V.Z,IconSize);
    
    // Draw material.
    Canvas.DrawColor = PlayerBarShadowColor;
    Canvas.DrawColor.A = DrawColor.A;
    Canvas.SetPos(V.X+1,V.Y+1);
    Canvas.DrawRotatedTile(Mat,R,IconSize,IconSize,0,0,Mat.GetSurfaceWidth(),Mat.GetSurfaceHeight());
            
    Canvas.DrawColor = DrawColor;
    Canvas.SetPos(V.X,V.Y);
    Canvas.DrawRotatedTile(Mat,R,IconSize,IconSize,0,0,Mat.GetSurfaceWidth(),Mat.GetSurfaceHeight());
    
    if( bWasStencilEnabled )
        Canvas.EnableStencilTest(true);
    
    return V;
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
            GetTraderVoiceClass();

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
    GUIStyle.DrawTextShadow(CurrentTraderName, Canvas.ClipY / 256 - PortraitWidth * PortraitX + 0.5 * (PortraitWidth - XL), 0.5 * (Canvas.ClipY + PortraitHeight) + 0.06 * PortraitHeight, 1, FontScalar);
}

simulated function Tick( float Delta )
{
    if( bDisplayingProgress )
    {
        bDisplayingProgress = false;
        if( VisualProgressBar<LevelProgressBar )
            VisualProgressBar = FMin(VisualProgressBar+Delta,LevelProgressBar);
        else if( VisualProgressBar>LevelProgressBar )
            VisualProgressBar = FMax(VisualProgressBar-Delta,LevelProgressBar);
    }

    if ( PortraitTime > WorldInfo.TimeSeconds )
        PortraitX = FMax(0, PortraitX - 3 * Delta);
    else if ( bDrawingPortrait )
    {
        PortraitX = FMin(1, PortraitX + 3 * Delta);

        if ( PortraitX == 1 )
            bDrawingPortrait = false;
    }
    
    Super.Tick(Delta);
}

function DrawMessageText(HudLocalizedMessage LocalMessage, float ScreenX, float ScreenY)
{
    local class<ClassicLocalMessage> ClassicMessage;
    
    ClassicMessage = class<ClassicLocalMessage>(LocalMessage.Message);
    if( ClassicMessage != None && ClassicMessage.default.bComplexString )
        ClassicMessage.static.RenderComplexMessage(Canvas, ScreenX, ScreenY, LocalMessage.StringMessage, LocalMessage.Switch, LocalMessage.OptionalObject);
    else Super.DrawMessageText(LocalMessage, ScreenX, ScreenY);
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
        return;

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
        HexClr = KFLocalMessageClass.static.GetHexColor(Switch);
    else if(InMessageClass == class'GameMessage')
        HexClr = class 'KFLocalMessage'.default.ConnectionColor;
    
    TempS = "#{"$HexClr$"}"$MessageString$"<LINEBREAK>";
    if( ClassicPlayerOwner.LobbyMenu != None )
        ClassicPlayerOwner.LobbyMenu.ChatBox.AddText(TempS);
    
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
            return Font'KFClassicMode_Assets.Font.KFNormalFont';
    }
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
    if( !bProgressDC )
        ProgressMsgTime = WorldInfo.TimeSeconds+4.f;
    bProgressDC = bDis;
    if( bDis )
        LocalPlayer(KFPlayerOwner.Player).ViewportClient.ViewportConsole.OutputText(Repl(S,"|","\n"));
}

function RenderProgress()
{
    local float X,Y,XL,YL,Sc,TY,TX,BoxX,BoxW,TextX;
    local int i;
    
    Canvas.Font = GUIStyle.PickFont(Sc);
    Sc += 0.125f;
    
    if( bProgressDC )
        Canvas.SetDrawColor(255,80,80,255);
    else Canvas.SetDrawColor(255,255,255,255);
    Y = Canvas.ClipY*0.1;

    for( i=0; i<ProgressLines.Length; ++i )
    {
        Canvas.TextSize("<"@ProgressLines[i]@">",XL,YL,Sc,Sc);
        TX = FMax(TX,XL);
    }
    TY = YL*ProgressLines.Length;
    
    X = (Canvas.ClipX/2) - (TX/2);
    
    BoxX = X+(ScaledBorderSize*2);
    BoxW = TX-(ScaledBorderSize*4);
    
    Canvas.DrawColor = HudMainColor;
    Canvas.SetPos(BoxX, Y);
    GUIStyle.DrawWhiteBox(BoxW, TY);
    
    GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, X, Y, ScaledBorderSize*2, TY, HudOutlineColor, true, false, true, false);
    GUIStyle.DrawRoundedBoxEx(ScaledBorderSize*2, X+TX-(ScaledBorderSize*2), Y, ScaledBorderSize*2, TY, HudOutlineColor, false, true, false, true);

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

function bool NotifyInputKey(int ControllerId, Name Key, EInputEvent Event, float AmountDepressed, bool bGamepad)
{
    local int i;
    
    for( i=(HUDWidgets.Length-1); i>=0; --i )
    {
        if( HUDWidgets[i].bVisible && HUDWidgets[i].NotifyInputKey(ControllerId, Key, Event, AmountDepressed, bGamepad) )
            return true;
    }
    
    return false;
}

function bool NotifyInputAxis(int ControllerId, name Key, float Delta, float DeltaTime, optional bool bGamepad)
{
    local int i;
    
    for( i=(HUDWidgets.Length-1); i>=0; --i )
    {
        if( HUDWidgets[i].bVisible && HUDWidgets[i].NotifyInputAxis(ControllerId, Key, Delta, DeltaTime, bGamepad) )
            return true;
    }
    
    return false;
}

function bool NotifyInputChar(int ControllerId, string Unicode)
{
    local int i;
    
    for( i=(HUDWidgets.Length-1); i>=0; --i )
    {
        if( HUDWidgets[i].bVisible && HUDWidgets[i].NotifyInputChar(ControllerId, Unicode) )
            return true;
    }
    
    return false;
}

simulated function Destroyed()
{
    Super.Destroyed();
    NotifyLevelChange();
    ResetConsole();
}

function ResetConsole()
{
    if( OrgConsole == None || ClientViewport.ViewportConsole == OrgConsole )
        return;
        
    ClientViewport.ViewportConsole = OrgConsole;
    OrgConsole.OnReceivedNativeInputKey = OrgConsole.InputKey;
    OrgConsole.OnReceivedNativeInputChar = OrgConsole.InputChar;
}

simulated function NotifyLevelChange( optional bool bMapswitch )
{
    if( bMapswitch )
        SetTimer(0.5,false,'PendingMapSwitch');
        
    if( OnlineSub!=None )
    {
        OnlineSub.ClearOnInventoryReadCompleteDelegate(SearchInventoryForNewItem);
        OnlineSub = None;
    }
}

simulated function PendingMapSwitch()
{
    ClassicPlayerOwner.ClientNotifyDisconnect();
    
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
                NewItems[0].Item = OnlineSub.ItemPropertiesList[j].Name$" ["$RarityStr(OnlineSub.ItemPropertiesList[j].Rarity)$"]";
                NewItems[0].MsgTime = WorldInfo.TimeSeconds;
                
                if( OnlineSub.ItemPropertiesList[j].Rarity >= ITR_Legendary )
                    ClassicPlayerOwner.ServerItemDropGet(NewItems[0].Item);
                    
                ClassicPlayerOwner.PlayAKEvent(AkEvent'WW_UI_Menu.Play_UI_Drop');
            }
        }
    }
    bLoadedInitItems = true;
}

simulated final function string RarityStr( byte R )
{
    switch( R )
    {
    case ITR_Common:                return "Common";
    case ITR_Uncommon:              return "Uncommon";
    case ITR_Rare:                  return "Rare";
    case ITR_Legendary:             return "Legendary";
    case ITR_ExceedinglyRare:       return "Exceedingly Rare";
    case ITR_Mythical:              return "Mythical";
    default:                        return "Very Common";
    }
}

simulated final function DrawItemsList()
{
    local int i;
    local float T,FontScale,XS,YS,YSize,XPos,YPos,BT,OT;
    local Color BackgroundColor,OutlineColor,TextColor;
    
    FontScale = Canvas.ClipY / 660.f;
    Canvas.Font = GUIStyle.PickFont(FontScale);
    Canvas.TextSize("ABC",XS,YSize,FontScale,FontScale);
    YSize*=2.f;
    YPos = Canvas.ClipY*0.7 - YSize;
    XPos = Canvas.ClipX - YSize*0.15;
    
    for( i=0; i<NewItems.Length; ++i )
    {
        T = WorldInfo.TimeSeconds-NewItems[i].MsgTime;
        BT = T;
        OT = T;
        
        if( T>=10.f )
        {
            NewItems.Remove(i--,1);
            continue;
        }
        if( T>9.f )
        {
            T = 255.f * (10.f-T);
            TextColor = MakeColor(255,255,255,T);
            
            BT = HudMainColor.A * (10.f-BT);
            BackgroundColor = MakeColor(HudMainColor.R, HudMainColor.G, HudMainColor.B, BT);
            
            OT = HudOutlineColor.A * (10.f-OT);
            OutlineColor = MakeColor(HudOutlineColor.R, HudOutlineColor.G, HudOutlineColor.B, OT);
        }
        else 
        {
            TextColor = MakeColor(255,255,255,255);
            BackgroundColor = HudMainColor;
            OutlineColor = HudOutlineColor;
        }
        
        Canvas.TextSize(NewItems[i].Item,XS,YS,FontScale,FontScale);
        GUIStyle.DrawOutlinedBox(XPos-(XS+(ScaledBorderSize*2)), YPos-(ScaledBorderSize*0.5), XS+(ScaledBorderSize*4), YSize+(ScaledBorderSize*2), 1, BackgroundColor, OutlineColor);
        
        XS = XPos-XS;
        
        Canvas.DrawColor = TextColor;
        Canvas.SetPos(XS, YPos);
        Canvas.DrawText("New Item:",, FontScale, FontScale);
        Canvas.SetPos(XS, YPos+(YSize*0.5));
        Canvas.DrawText(NewItems[i].Item,, FontScale, FontScale);

        YPos-=YSize;
    }
}

simulated function CheckForItems()
{
    if( KFGRI!=none )
        KFGRI.ProcessChanceDrop();
    SetTimer(260+FRand()*220.f,false,'CheckForItems');
}

function SetFinalCountdown(bool B, int CountdownTime)
{
    if( B )
    {
        FinalCountTime = CountdownTime + 1;
        SetTimer(1, true, nameOf(FinalCountdown));
        FinalCountdown();
    }
    else
    {
        FinalCountTime = 0;
        ClearTimer(nameOf(FinalCountdown));
    }
    
    bFinalCountdown = B;
}

function FinalCountdown()
{
    FinalCountTime -= 1;
    if( FinalCountTime == 0 )
        ClearTimer(nameOf(FinalCountdown));
}

function CheckAndDrawRemainingZedIcons()
{
    if( !bDisableLastZEDIcons )
        Super.CheckAndDrawRemainingZedIcons();
}

function DrawZedIcon( Pawn ZedPawn, vector PawnLocation, float NormalizedAngle )
{
    DrawDirectionalIndicator(PawnLocation + (ZedPawn.CylinderComponent.CollisionHeight * vect(0, 0, 1)), GenericZedIconTexture, PlayerStatusIconSize * (WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale) * 0.5f,,, GetNameOf(ZedPawn.Class));
}

defaultproperties
{
    MaxNonCriticalMessages=2
    
    HUDClass=class'ClassicMoviePlayer_HUD'
    ConsoleClass=class'UI_Console'

    ChatBoxClass=class'UI_MainChatBox'
    SpectatorInfoClass=class'UIR_SpectatorInfoBox'
    ScoreboardClass=class'KFScoreBoard'
    VoiceCommsClass=class'UIR_VoiceComms'
    
    DefaultHudMainColor=(R=0,B=0,G=0,A=195)
    DefaultHudOutlineColor=(R=200,B=15,G=15,A=195)
    DefaultFontColor=(R=255,B=50,G=50,A=255)
    
    BlueColor=(R=0,B=255,G=0,A=255)
    
    MedicLockOnIcon=Texture2D'UI_SecondaryAmmo_TEX.UI_FireModeSelect_ManualTarget'
    MedicLockOnIconSize=40
    MedicLockOnColor=(R=0,G=255,B=255,A=192)
    MedicPendingLockOnColor=(R=92,G=92,B=92,A=192)

    MaxWeaponPickupDist=700
    WeaponPickupScanRadius=75
    ZedScanRadius=200
    WeaponAmmoIcon=Texture2D'UI_Menus.TraderMenu_SWF_I10B'
    WeaponWeightIcon=Texture2D'UI_Menus.TraderMenu_SWF_I26'
    WeaponIconSize=32
    WeaponIconColor=(R=192,G=192,B=192,A=255)
    WeaponOverweightIconColor=(R=255,G=0,B=0,A=192)
    
    MedicWeaponRot=(Yaw=16384)
    MedicWeaponHeight=88
    MedicWeaponBGColor=(R=0,G=0,B=0,A=128)
    MedicWeaponNotChargedColor=(R=224,G=0,B=0,A=128)
    MedicWeaponChargedColor=(R=0,G=224,B=224,A=128)
    
    TraderArrow=Texture2D'UI_LevelChevrons_TEX.UI_LevelChevron_Icon_03'
    TraderArrowLight=Texture2D'UI_Objective_Tex.UI_Obj_World_Loc'
    VoiceChatIcon=Texture2D'UI_HUD.voip_icon'
    RhythmHUDIcon=Texture2D'WeeklyObjective_UI.UI_Weeklies_Zombies'
    
    InventoryFadeTime=1.25
    InventoryFadeInTime=0.1
    InventoryFadeOutTime=0.15
    
    InventoryX=0.35
    InventoryY=0.025
    InventoryBoxWidth=0.1
    InventoryBoxHeight=0.075
    BorderSize=0.005
    
    PerkIconSize=16
    
    DamagePopupFadeOutTime=2.25
    XPFadeOutTime=1.0
    
    QuickSyringeDisplayTime=5.0
    QuickSyringeFadeInTime=1.0
    QuickSyringeFadeOutTime=0.5    
    
    NonCriticalMessageDisplayTime=3.0
    NonCriticalMessageFadeInTime=0.65
    NonCriticalMessageFadeOutTime=0.5
    
    BattlePhaseColors.Add((R=0,B=0,G=150,A=175))
    BattlePhaseColors.Add((R=255,B=18,G=176,A=175))
    BattlePhaseColors.Add((R=255,B=18,G=96,A=175))
    BattlePhaseColors.Add((R=173,B=17,G=22,A=175))
    BattlePhaseColors.Add((R=0,B=0,G=0,A=175))
    
    DamageMsgColors[DMG_Fire]=(R=206,G=103,B=0,A=255)
    DamageMsgColors[DMG_Toxic]=(R=58,G=232,B=0,A=255)
    DamageMsgColors[DMG_Bleeding]=(R=255,G=100,B=100,A=255)
    DamageMsgColors[DMG_EMP]=(R=32,G=138,B=255,A=255)
    DamageMsgColors[DMG_Freeze]=(R=0,G=183,B=236,A=255)
    DamageMsgColors[DMG_Flashbang]=(R=195,G=195,B=195,A=255)
    DamageMsgColors[DMG_Generic]=(R=206,G=64,B=64,A=255)
    DamageMsgColors[DMG_High]=(R=0,G=206,B=0,A=255)
    DamageMsgColors[DMG_Medium]=(R=206,G=206,B=0,A=255)
    DamageMsgColors[DMG_Unspecified]=(R=150,G=150,B=150,A=255)
    
    NewLineSeparator="|"
    
    NotificationBackground=Texture2D'KFClassicMode_Assets.HUD.Med_border_SlightTransparent'
    NotificationWidth=250.0f
    NotificationHeight=70.f
    NotificationShowTime=0.3
    NotificationHideTime=0.5
    NotificationHideDelay=3.5
    NotificationBorderSize=7.0
    NotificationIconSpacing=10.0
    NotificationPhase=PHASE_DONE
}