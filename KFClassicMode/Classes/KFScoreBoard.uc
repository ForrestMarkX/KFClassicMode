class KFScoreBoard extends KFGUI_Page;

const BORDERTHICKNESS = 2;

var transient float PerkXPos, PlayerXPos, StateXPos, TimeXPos, HealXPos, KillsXPos, AssistXPos, CashXPos, DeathXPos, PingXPos;

var int PlayerIndex;
var KFPlayerReplicationInfo RightClickPlayer;
var editinline export KFGUI_RightClickMenu PlayerContext;
var KFGUI_List PlayersList;
var transient int InitAdminSize;
var Texture2D DefaultAvatar;

var KFGameReplicationInfo KFGRI;
var array<KFPlayerReplicationInfo> KFPRIArray;

var KFGUI_Tooltip ToolTipItem;

var transient bool bHasSelectedPlayer,bMeAdmin;

struct FAdminCmdType
{
	var string Cmd,Info;
};
var array<FAdminCmdType> AdminCommands;

function InitMenu()
{
	Super.InitMenu();
	PlayersList = KFGUI_List(FindComponentID('PlayerList'));
}

function ShowMenu()
{
	local KFPlayerController PC;
	local int i;
	local bool bAdmin;

	PC = KFPlayerController(GetPlayer());
	PC.IgnoreLookInput(true);
	
	Owner.bAbsorbInput = false;
	
	bAdmin = PC!=None && (PC.WorldInfo.NetMode!=NM_Client || (PC.PlayerReplicationInfo!=None && PC.PlayerReplicationInfo.bAdmin));
	if( PC!=None && (InitAdminSize!=AdminCommands.Length || !bAdmin) )
	{
		InitAdminSize = (bAdmin ? AdminCommands.Length : 0);
		PlayerContext.ItemRows.Length = 4+InitAdminSize;
		for( i=0; i<InitAdminSize; ++i )
			PlayerContext.ItemRows[4+i].Text = AdminCommands[i].Info;
	} 
}

function CheckAvatar(KFPlayerReplicationInfo KFPRI)
{
	local Texture2D Avatar;
	
	if( KFPRI.Avatar == None || KFPRI.Avatar == DefaultAvatar )
	{
		Avatar = FindAvatar(KFPRI.UniqueId);
		if( Avatar == None )
			Avatar = DefaultAvatar;
			
		KFPRI.Avatar = Avatar;
	}
}

function CloseMenu()
{
	Owner.bAbsorbInput = true;
	GetPlayer().IgnoreLookInput(false);
	
	Owner.bNoInputReset = true;
	SetTimer(0.1, false, 'ResetInputVar');
	
	KFGRI = None;
	KFPRIArray.Length = 0;
	RightClickPlayer = None;
	bHasSelectedPlayer = false;
}

function ResetInputVar()
{
	Owner.bNoInputReset = false;
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
		
function String FormatTime( int Seconds )
{
    local int Minutes, Hours;
    local String Time;

    if( Seconds > 3600 )
    {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

        Time = Hours$":";
	}
	Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    if( Minutes >= 10 )
        Time = Time $ Minutes $ ":";
    else
        Time = Time $ "0" $ Minutes $ ":";

    if( Seconds >= 10 )
        Time = Time $ Seconds;
    else
        Time = Time $ "0" $ Seconds;

    return Time;
}	

function DrawMenu()
{
    local string S;
    local PlayerController PC;
    local KFPlayerReplicationInfo KFPRI;
    local PlayerReplicationInfo PRI;
    local float XPos, YPos, YL, FontScalar, XPosCenter, DefFontHeight;
    local int i, j, NumSpec, NumPlayer, NumAlivePlayer, Width, NextScoreboardRefresh;

	PC = GetPlayer();
	if( KFGRI==None )
	{
		KFGRI = KFGameReplicationInfo(PC.WorldInfo.GRI);
		if( KFGRI==None )
			return;
	}
	bMeAdmin = PC!=None && (PC.WorldInfo.NetMode!=NM_Client || (PC.PlayerReplicationInfo!=None && PC.PlayerReplicationInfo.bAdmin));

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
	Canvas.DrawColor = MakeColor (255, 0, 0, 255);
	
	// Server Name
	
	XPos = XPosCenter;
	YPos += DefFontHeight;
	
	S = KFGRI.ServerName;
	Owner.CurrentStyle.DrawCenteredText(S, XPos, YPos, FontScalar);

	// Deficulty | Wave | MapName

	XPos = XPosCenter;
	YPos += DefFontHeight;

	S = " " $Class'KFCommon_LocalizedStrings'.Static.GetDifficultyString (KFGRI.GameDifficulty) $"  |  WAVE " $KFGRI.WaveNum $"  |  " $class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(PC.WorldInfo.GetMapName(true));
	Owner.CurrentStyle.DrawCenteredText(S, XPos, YPos, FontScalar);
	
	// Time Elapsed

	XPos = XPosCenter;
	YPos += DefFontHeight;
	
	S = "Elapsed Time: "$FormatTime(KFGRI.ElapsedTime);
	Owner.CurrentStyle.DrawCenteredText(S, XPos, YPos, FontScalar);
	
	Width = Canvas.ClipX * 0.625;

	XPos = (Canvas.ClipX - Width) * 0.5;
	YPos += DefFontHeight * 2.0;

	Canvas.DrawColor = MakeColor (250, 250, 250, 255);

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
	Canvas.DrawText ("PERK", , FontScalar, FontScalar);

	Canvas.SetPos (XPos + KillsXPos, YPos);
	Canvas.DrawText ("KILLS", , FontScalar, FontScalar);

	Canvas.SetPos (XPos + AssistXPos, YPos);
	Canvas.DrawText ("ASSISTS", , FontScalar, FontScalar);

	Canvas.SetPos (XPos + CashXPos, YPos);
	Canvas.DrawText ("DOSH", , FontScalar, FontScalar);

	Canvas.SetPos (XPos + StateXPos, YPos);
	Canvas.DrawText ("STATE", , FontScalar, FontScalar);
	
	Canvas.SetPos (XPos + PlayerXPos, YPos);
	Canvas.DrawText ("PLAYER", , FontScalar, FontScalar);

	Canvas.SetPos (XPos + PingXPos, YPos);
	Canvas.DrawText ("PING", , FontScalar, FontScalar);
	
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
	local Texture PerkIcon, PerkStarIcon;
	local byte PerkLevel;
	local bool bIsZED;
	local int Ping;
	
	YOffset *= 1.05;
	KFPRI = KFPRIArray[Index];
	
	CheckAvatar(KFPRI);
	
	if( KFGRI.bVersusGame )
		bIsZED = KFTeamInfo_Zeds(KFPRI.Team) != None;
		
	bFocus = bFocus || (bHasSelectedPlayer && RightClickPlayer==KFPRI);
	
    C.Font = Owner.CurrentStyle.PickFont(FontScalar);
	
	if (PlayerIndex == Index)
	{
		if( bFocus )
			C.SetDrawColor(0, 83, 255, 150);
		else C.SetDrawColor (51, 30, 101, 150);
	}
	else 
	{
		if( bFocus )
			C.SetDrawColor(0, 83, 255, 150);
		else C.SetDrawColor (30, 30, 30, 150);
	}
	C.SetPos(0.f,YOffset);
	Owner.CurrentStyle.DrawWhiteBox(Width,Height);
	
	if( KFGRI.bVersusGame )
		C.DrawColor = KFPRI.GetTeamNum() == 0 ? MakeColor(200, 0, 0, 200) : MakeColor(0, 71, 200, 200);
	else C.DrawColor = MakeColor(120, 120, 0, 200);
	Owner.CurrentStyle.DrawBoxHollow(0.f,YOffset,Width,Height,BORDERTHICKNESS);
	
	C.SetDrawColor(250,250,250,255);
	
	C.TextSize("ABC", XL, YL, FontScalar, FontScalar);
	TextYOffset = YOffset + (Height / 2) - (YL / 1.75f);

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
			DrawPerkWithStars(C,PerkXPos,YOffset+(BORDERTHICKNESS / 2),Height-(BORDERTHICKNESS * 2),PerkLevel,PerkIcon,PerkStarIcon);
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
		C.SetDrawColor(255,255,255,255);
		C.SetPos(PlayerXPos - (Height * 1.075), YOffset + (Height / 2) - ((Height - 6) / 2));
		C.DrawTile(KFPRI.Avatar,Height - 6,Height - 6,0,0,KFPRI.Avatar.SizeX,KFPRI.Avatar.SizeY);
		Owner.CurrentStyle.DrawBoxHollow(PlayerXPos - (Height * 1.075), YOffset + (Height / 2) - ((Height - 6) / 2), Height - 6, Height - 6, 1);
	} 

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
		StrValue = "$"$int(KFPRI.Score);
		if(KFPRI.Score >= 1000)
		{
			StrValue = "$"@string(int(KFPRI.Score/1000.f))$"K" ;
		}
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
		Ping = int(KFPRI.Ping * `PING_SCALE);
		
		if (Ping <= 100)
			C.SetDrawColor(0,250,0,255);
		else if (Ping <= 200)
			C.SetDrawColor(250,250,0,255);
		else C.SetDrawColor(250,100,100,255);
		
		S = string(Ping);
	}

	C.SetPos (PingXPos, TextYOffset);
	C.DrawText (S, , FontScalar, FontScalar);
}

final function DrawPerkWithStars( Canvas C, float X, float Y, float Scale, int Stars, Texture PerkIcon, Texture StarIcon )
{
	local byte i;

	C.SetPos(X,Y);
	C.DrawTile(PerkIcon, Scale, Scale, 0, 0, PerkIcon.GetSurfaceWidth(), PerkIcon.GetSurfaceHeight());
	
	if( Stars==0 || StarIcon==None )
		return;
		
	Y+=Scale*0.9f;
	X+=Scale*0.8f;
	Scale*=0.2f;
	
	while( Stars>0 )
	{
		if( (X+Scale) >= PlayerXPos )
		{
			break;
		}
		
		for( i=1; i<=Min(5,Stars); ++i )
		{
			C.SetPos(X,Y-(i*Scale*0.8f));
			C.DrawTile(StarIcon, Scale, Scale, 0, 0, StarIcon.GetSurfaceWidth(), StarIcon.GetSurfaceHeight());
		}
		
		X+=Scale;
		Stars-=5;
	}
}

function ShowPlayerTooltip( int Index )
{
	local KFPlayerReplicationInfo PRI;
	local string S, HealthString;
	
	PRI = KFPRIArray[Index];
	if( PRI!=None )
	{
		if( ToolTipItem==None )
		{
			ToolTipItem = New(None)Class'KFGUI_Tooltip';
			ToolTipItem.Owner = Owner;
			ToolTipItem.ParentComponent = Self;
			ToolTipItem.InitMenu();
		}
		HealthString = GetPlayer().PlayerReplicationInfo.GetTeamNum() != PRI.GetTeamNum() ? "Unknown" : (PRI.PlayerHealthPercent<=0 ? "0" : string(PRI.PlayerHealth));
		S = "Player: "$PRI.PlayerName$"<SEPERATOR>Health: "$HealthString;
		if( KFGRI.bVersusGame )
			S = S$"<SEPERATOR>Team: "$PRI.Team.GetHumanReadableName();
		if( PRI.bAdmin )
			S = S$"<SEPERATOR> Admin";
		S = S$"<SEPERATOR>(Right click for options)";
		ToolTipItem.SetText(S);
		ToolTipItem.ShowMenu();
		ToolTipItem.CompPos[0] = Owner.MousePosition.X;
		ToolTipItem.CompPos[1] = Owner.MousePosition.Y;
		ToolTipItem.GetInputFocus();
	}
}

function ClickedPlayer( int Index, bool bRight, int MouseX, int MouseY )
{
	local PlayerController PC;
	local int i;

	if( !bRight || Index<0 )
		return;
	bHasSelectedPlayer = true;
	RightClickPlayer = KFPRIArray[Index];
	
	// Check what items to disable.
	PC = GetPlayer();
	PlayerContext.ItemRows[0].bDisabled = (PlayerIndex==Index || !PC.IsSpectating());
	PlayerContext.ItemRows[1].bDisabled = RightClickPlayer.bBot;
	PlayerContext.ItemRows[2].bDisabled = (PlayerIndex==Index || RightClickPlayer.bBot);
	PlayerContext.ItemRows[2].Text = (PlayerContext.ItemRows[2].bDisabled || PC.IsPlayerMuted(RightClickPlayer.UniqueId)) ? "Unmute player" : "Mute player";

	if( PlayerIndex==Index ) // Selected self.
	{
		for( i=4; i<PlayerContext.ItemRows.Length; ++i )
			PlayerContext.ItemRows[i].bDisabled = true;
	}
	else
	{
		for( i=4; i<PlayerContext.ItemRows.Length; ++i )
			PlayerContext.ItemRows[i].bDisabled = false;
	}

	PlayerContext.OpenMenu(Self);
}

function HidRightClickMenu( KFGUI_RightClickMenu M )
{
	bHasSelectedPlayer = false;
}
function SelectedRCItem( int Index )
{
	local PlayerController PC;
	local KFPlayerReplicationInfo KFPRI;
	local ViewTargetTransitionParams TransitionParams;
	local String S;

	PC = GetPlayer();
	KFPRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
	switch( Index )
	{
	case 0: // Spectate this player.
		TransitionParams.BlendTime = 0.35;
		TransitionParams.BlendFunction = VTBlend_Cubic;
		TransitionParams.BlendExp = 2.f;
		TransitionParams.bLockOutgoing = false;
	
		PC.SetViewTarget( RightClickPlayer, TransitionParams );
		PC.ClientSetViewTarget( RightClickPlayer, TransitionParams );
		break;
	case 1: // Steam profile.
		OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem()).ShowProfileUI(0,,RightClickPlayer.UniqueId);
		break;
	case 2: // Mute voice.
		if( !PC.IsPlayerMuted(RightClickPlayer.UniqueId) )
		{
			PC.ClientMessage("You've muted "$RightClickPlayer.PlayerName);
			PC.ClientMutePlayer(RightClickPlayer.UniqueId);
		}
		else
		{
			PC.ClientMessage("You've unmuted "$RightClickPlayer.PlayerName);
			PC.ClientUnmutePlayer(RightClickPlayer.UniqueId);
		}
		break;
	case 3: // Vote kick.
		KFPRI.ServerStartKickVote(RightClickPlayer, KFPRI);
		break;
	default:
		if( Index>=5 )
		{
			S = "Admin ";
			PC.ConsoleCommand(S$AdminCommands[Index-5].Cmd@RightClickPlayer.PlayerName);
		}
	}
}

final function Texture2D FindAvatar( UniqueNetId ClientID )
{
	local string S;
	
	S = KFPlayerController(GetPlayer()).GetSteamAvatar(ClientID);
	if( S=="" )
		return None;
	return Texture2D(FindObject(S,class'Texture2D'));
}

defaultproperties
{
	Begin Object Class=KFGUI_List Name=PlayerList
		XSize=0.625
		OnDrawItem=DrawPlayerEntry
		OnClickedItem=ClickedPlayer
		ID="PlayerList"
		bClickable=true
		OnMouseRest=ShowPlayerTooltip
		ListItemsPerPage=16
	End Object
	Components.Add(PlayerList)
	
	Begin Object Class=KFGUI_RightClickMenu Name=PlayerContextMenu
		ItemRows.Add((Text="Spectate this player"))
		ItemRows.Add((Text="View player Steam profile"))
		ItemRows.Add((Text="Mute Player"))
		ItemRows.Add((Text="Vote Kick Player"))
		ItemRows.Add((bSplitter=true))
		OnSelectedItem=SelectedRCItem
		OnBecameHidden=HidRightClickMenu
	End Object
	PlayerContext=PlayerContextMenu
	
	DefaultAvatar=Texture2D'UI_HUD.ScoreBoard_Standard_SWF_I26'
	
	AdminCommands.Add((Info="Kick Player",Cmd="Kick"))
	AdminCommands.Add((Info="Ban Player",Cmd="KickBan"))
}