Class UI_LobbyMenu extends KFGUI_Page;

var KFGUI_Button MenuButton,OptionsButton,ViewMapButton,ReadyButton,DisconnectButton,GearButton;
var KFGUI_Frame MenuBar, MapInfo, StoryBoxBackground, BGPerkEffects, BGPerk, PlayerPortrait;//, PlayerPortraitB;
var KFGUI_TextLable MapLabel, DifficultyLabel, TimeoutLabel, WaveLabel;
var KFGUI_TextScroll MOTDText;
var KFGUI_List PlayersList;
var KFGUI_Page MainMenu;
var KFGUI_Image WaveB;
var UIR_ChatBox ChatBox;

var KFPlayerReplicationInfo RightClickPlayer;
var editinline export KFGUI_RightClickMenu PlayerContext;

var Texture ItemBoxTexture, ItemBarTexture, CheckBoxTexture, CheckMarkTexture;
var array<KFPlayerReplicationInfo> KFPRIArray;

var OnlineSubsystem OnlineSub;
var KFGameReplicationInfo KFGRI;
var ClassicPlayerController PC;
var KFPlayerReplicationInfo KFPRI;

var transient int NumButtons, FinalCountTime, OldLobbyTimeout, OldPRILength;
var transient bool bOldReady, bFinalCountdown, bMOTDReceived, bSetGRIInfo, bViewMapClicked, bClosed;

var string WaitingForServerStatus;
var string WaitingForOtherPlayers;
var string AutoCommence;

function InitMenu()
{
	Super.InitMenu();
	
	PlayerContext.OnSelectedItem = SelectedRCItem;
	PlayerContext.ItemRows.Length = 4;
	PlayerContext.ItemRows[0].Text = class'KFGFxWidget_BaseParty'.default.MuteString;
	PlayerContext.ItemRows[1].Text = class'KFGFxWidget_BaseParty'.default.AddFriendString;
	PlayerContext.ItemRows[2].Text = class'KFGFxWidget_BaseParty'.default.ViewProfileString;
	PlayerContext.ItemRows[3].Text = class'KFGFxWidget_BaseParty'.default.VoteKickString;
	
	MOTDText = KFGUI_TextScroll(FindComponentID('MOTDText'));
	
	PlayersList = KFGUI_List(FindComponentID('PlayerList'));
	PlayersList.OnClickedItem = ClickedPlayer;
	
	MenuBar = KFGUI_Frame(FindComponentID('MenuBar'));
	MapInfo = KFGUI_Frame(FindComponentID('MapInfo'));
	StoryBoxBackground = KFGUI_Frame(FindComponentID('StoryBoxBackground'));
	BGPerkEffects = KFGUI_Frame(FindComponentID('BGPerkEffects'));
	BGPerk = KFGUI_Frame(FindComponentID('BGPerk'));
	//PlayerPortraitB = KFGUI_Frame(FindComponentID('PlayerPortraitB'));
	PlayerPortrait = KFGUI_Frame(FindComponentID('PlayerPortrait'));
	
	WaveB = KFGUI_Image(FindComponentID('WaveB'));
	
	/*
	GearButton = KFGUI_Button(FindComponentID('CharacterB'));
	GearButton.OnClickLeft = ButtonClicked;
	GearButton.OnClickRight = ButtonClicked;
	*/
	
	MapLabel = KFGUI_TextLable(FindComponentID('CurrentMapL'));
	DifficultyLabel = KFGUI_TextLable(FindComponentID('DifficultyL'));
	TimeoutLabel = KFGUI_TextLable(FindComponentID('TimeOutCounter'));
	WaveLabel = KFGUI_TextLable(FindComponentID('WaveL'));
	
	ChatBox = UIR_ChatBox(FindComponentID('ChatBox'));

	DisconnectButton = AddMenuButton('Disconnect',"Disconnect","Disconnects you from the server");
	ReadyButton = AddMenuButton('Ready',"Ready","");
	ViewMapButton = AddMenuButton('ViewMap',"View Map","Closed the lobby menu and allows you to view the map");
	OptionsButton = AddMenuButton('Options',"Options","Opens the settings menu");
	GearButton = AddMenuButton('CharacterB',"Gear","Opens the Gear menu to change characters");
	MenuButton = AddMenuButton('MainMenu',"Main Menu","Opens the main menu for perk changes");
	
	ReadyButton.GamepadButtonName = "XboxTypeS_Y";
}

function bool ReceievedControllerInput(int ControllerId, name Key, EInputEvent Event)
{
	switch(Key)
	{
		case 'XboxTypeS_Y':
			if( Event == IE_Pressed )
			{
				PC.PlayAKEvent(AkEvent'WW_UI_Menu.Play_PARTYWIDGET_READYUP_BUTTON_CLICK');
				ReadyButton.HandleMouseClick(false);
			}
			return true;
	}
	
	return false;
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
		TimeoutLabel.TextColor = TimeoutLabel.default.TextColor;
		ClearTimer(nameOf(FinalCountdown));
	}
	
	bFinalCountdown = B;
}

function FinalCountdown()
{
	FinalCountTime -= 1;
	PC.PlayAKEvent(AkEvent'WW_UI_Menu.Play_PARTYWIDGET_COUNTDOWN');
	
	if( FinalCountTime == 0 )
	{
		ClearTimer(nameOf(FinalCountdown));
	}
}

function Timer()
{
	local int i, WaveMax;
	local string S;
	local KFPlayerReplicationInfo PRI;
	
	if( OnlineSub == None )
	{
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	}
		
	if( PC == None )
	{
		PC = ClassicPlayerController(GetPlayer());
	}
		
	if( KFPRI == None )
	{
		KFPRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
	}
	
	if( !bTextureInit )
	{
		GetStyleTextures();
	}
		
	if( !bMOTDReceived && PC.bMOTDReceived )
	{
		bMOTDReceived = true;
		MOTDText.SetText(PC.ServerMOTD);
	}
	
	if( KFGRI == None )
	{
		KFGRI = KFGameReplicationInfo(PC.WorldInfo.GRI);
		return;
	}
	
	if( !bSetGRIInfo )
	{
		bSetGRIInfo = true;
		
		WaveMax = KFGRI.WaveMax-1;
		
		if( KFGameReplicationInfo_Endless(KFGRI) != None )
			S = string(KFGRI.WaveNum);
		else S = string(KFGRI.WaveNum) $ "/" $ string(WaveMax);
		
		MapLabel.SetText("Current Map:"@class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(PC.WorldInfo.GetMapName(true)));
		DifficultyLabel.SetText("Difficulty Level:"@Class'KFCommon_LocalizedStrings'.Static.GetDifficultyString(KFGRI.GameDifficulty));
		WaveLabel.SetText(S);
	}
		
	KFPRIArray.Length = 0;
	for( i=0; i<KFGRI.PRIArray.Length; ++i )
	{
		PRI = KFPlayerReplicationInfo(KFGRI.PRIArray[i]);
		if( PRI==None || PRI.bOnlySpectator )
			continue;
			
		KFPRIArray.AddItem(PRI);
	}
	PlayersList.ChangeListSize(KFPRIArray.Length);
	
	if( KFPRI==None )
		return;
		
	if( KFGRI != None && KFGRI.bMatchHasBegun && KFPRI.bHasSpawnedIn )
	{
		if( PC.CurrentChatBox != None )
		{
			PC.CurrentChatBox.ChatBoxText.FadeStartTime = PC.WorldInfo.TimeSeconds;
			PC.CurrentChatBox.ChatBoxText.SetVisibility(true);
		}
	
		DoClose();
		return;
	}

	if( bOldReady != KFPRI.bReadyToPlay )
	{
		bOldReady = KFPRI.bReadyToPlay;
		ReadyButton.ButtonText = (bOldReady ? "Un-Ready" : "Ready");
		
		if( MainMenu != None && KFPRI.bReadyToPlay )
		{
			MainMenu.DoClose();
		}
		
		MenuButton.SetDisabled( KFPRI.bReadyToPlay );
		GearButton.SetDisabled( KFPRI.bReadyToPlay );
	}
}

function DrawMenu()
{
	local byte Glow;
	local int LobbyTimeout, Min, Time;
	
	Super.DrawMenu();
	
	if ( KFPRI != None && KFPRI.bOnlySpectator )
	{
		TimeoutLabel.SetText("You are a spectator.");
	}
	else
	{
		if ( KFGRI==None )
		{
			TimeoutLabel.SetText(WaitingForServerStatus);
		}
		else
		{
			LobbyTimeout = bFinalCountdown ? FinalCountTime : KFGRI.RemainingTime;
			if( bFinalCountdown )
			{
				Glow = Clamp(Sin(PC.WorldInfo.TimeSeconds * 8) * 200 + 255, 0, 255);
				TimeoutLabel.TextColor = MakeColor(255, Glow, Glow, 255);
			}
			else if( LobbyTimeout <= 0 )
			{
				TimeoutLabel.SetText(WaitingForOtherPlayers);
				return;
			}
			
			Min = LobbyTimeout / 60;
			Time = LobbyTimeout - (Min * 60);
			
			TimeoutLabel.SetText(AutoCommence$":" @ (Min >= 10 ? string(Min) : "0" $ Min) $ ":" $ (Time >= 10 ? string(Time) : "0" $ Time));
		}
	}
}

function ShowMenu()
{
	local KFHUDInterface HUD;
	
	Super.ShowMenu();
	
	Timer();
	SetTimer(0.01,true);
	
	bViewMapClicked = false;
	bClosed = false;
	PC.LobbyMenu = self;
	PC.ClientGotoState( 'PlayerWaiting' );
	
	KFPRIArray.Length = 0;
	OldPRILength = 0;
	
	ViewMapButton.SetDisabled( true );
	
	/*
	if( PC.WorldInfo.GRI != None )
	{
		ViewMapButton.SetDisabled( PC.WorldInfo.GRI.bMatchHasBegun );
	}
	*/
	
	//CheckForCustomizationPawn();
	
	HUD = KFHUDInterface(PC.myHUD);
	if( HUD != None )
	{
		if( HUD.SpectatorInfo != None )
			HUD.SpectatorInfo.SetVisibility(false);
	}
}

function CloseMenu()
{
	Super.CloseMenu();
	bClosed = true;
}

function CheckForCustomizationPawn()
{
	if( PC.Pawn == None || (!PC.Pawn.IsAliveAndWell() && KFPawn_Customization(PC.Pawn) == None) )
	{
		PC.SpawnMidGameCustomizationPawn();
	}	
}

function ButtonClicked( KFGUI_Button Sender )
{
	switch( Sender.ID )
	{
	case 'MainMenu':
		MainMenu = Owner.OpenMenu(PC.MidGameMenuClass);
		break;
	case 'ViewMap':
		bViewMapClicked = true;
		CloseAndEnableInput();
		break;
	case 'Ready':
		if( KFGRI.bMatchHasBegun )
		{
			KFPRI.SetPlayerReady(true);
			CloseAndEnableInput();
		}
		else
		{
			KFPRI.SetPlayerReady(!KFPRI.bReadyToPlay);
		}
		
		break;	
	case 'CharacterB':
	case 'Options':
		if( MainMenu != None )
		{
			MainMenu.DoClose();
		}
		
		Owner.OpenMenu(PC.FlashUIClass);
		PC.MyGFxManager.OpenMenu(Sender.ID == 'Options' ? UI_OptionsSelection : UI_Gear);
		DoClose();
		break;
	case 'Disconnect':
		PC.ConsoleCommand("DISCONNECT");
		break;
	}
}

function CloseAndEnableInput()
{
	if( !KFGRI.bMatchIsOver && KFGRI.bTraderIsOpen )
	{
		PC.ServerRestartPlayer();
	}
	else
	{
		PC.StartSpectate();
	}
			
	PC.MyGFxManager.CloseMenus(true);	
	PC.PlayerInput.ResetInput();
		
	Owner.CloseMenu(None, true);
	DoClose();
}

final function KFGUI_Button AddMenuButton( name ButtonID, string Text, optional string ToolTipStr )
{
	local KFGUI_Button B;
	
	B = new (Self) class'KFGUI_Button';
	B.ButtonText = Text;
	B.ToolTip = ToolTipStr;
	B.OnClickLeft = ButtonClicked;
	B.OnClickRight = ButtonClicked;
	B.ID = ButtonID;
	B.XPosition = 0.895-(NumButtons*0.1);
	B.XSize = 0.099;
	B.YPosition = 0.15;
	B.YSize = 0.75;
	
	++NumButtons;
	
	MenuBar.AddComponent(B);
	return B;
}

function DrawPlayerEntry( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
	local byte PerkLevel;
	local float FontScalar, TextYOffset, XL, YL, PerkXL, PerkYL, NameXPos, AvatarXPos, AvatarYPos, ImageBorder;
	local KFPlayerReplicationInfo PRI;
	local string S;
	local Texture PerkIcon, PerkStarIcon, VoiceChatIcon;
	
	if( KFPRIArray.Length <= 0 )
		return;
	
	PRI = KFPRIArray[Index];
	if( PRI == None || PRI.bIsInactive )
		return;
	
	YOffset *= 1.05;
	NameXPos = Width * 0.2;
	ImageBorder = Owner.CurrentStyle.ScreenScale(6);
	
    C.Font = Owner.CurrentStyle.PickFont(FontScalar);
	
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
	
	C.SetPos(Width*0.925,YOffset);
	C.DrawTileStretched(CheckBoxTexture,Height,Height,0,0,CheckBoxTexture.GetSurfaceWidth(),CheckBoxTexture.GetSurfaceHeight());
	
	if( PRI.bReadyToPlay )
	{
		C.SetPos(Width*0.925,YOffset);
		C.DrawTile(CheckMarkTexture,Height,Height,0,0,CheckMarkTexture.GetSurfaceWidth(),CheckMarkTexture.GetSurfaceHeight());
	}
	
	C.TextSize("ABC", XL, YL, FontScalar, FontScalar);
	TextYOffset = YOffset + (Height / 2) - (YL / 1.75f);
	
	if( PRI.CurrentPerkClass!=None && class<ClassicPerk_Base>(PRI.CurrentPerkClass) != None )
	{
		PerkLevel = PRI.GetActivePerkLevel();

		PerkXL = Height-ImageBorder;
		PerkYL = Height-ImageBorder;
		
		class<ClassicPerk_Base>(PRI.CurrentPerkClass).static.PreDrawPerk(C, PerkLevel, PerkIcon, PerkStarIcon);
		
		C.SetPos((Height / 2) - (PerkXL / 2), YOffset + (Height / 2) - (PerkYL / 2));
		C.DrawRect(PerkXL, PerkYL, PerkIcon);
	}
	
	if( PRI.Avatar != None )
	{
		AvatarXPos = NameXPos - (Height * 1.075);
		AvatarYPos = YOffset + (Height / 2) - ((Height - ImageBorder) / 2);
	
		C.SetDrawColor(255,255,255,255);
		C.SetPos(AvatarXPos, AvatarYPos);
		C.DrawTile(PRI.Avatar,Height - ImageBorder,Height - ImageBorder,0,0,PRI.Avatar.SizeX,PRI.Avatar.SizeY);
		Owner.CurrentStyle.DrawBoxHollow(AvatarXPos, AvatarYPos, Height - ImageBorder, Height - ImageBorder, 1);
	} 
	else
	{
		if( !PRI.bBot )
			PRI.Avatar = FindAvatar(PRI.UniqueId);
	}
	
	if( PRI.VOIPStatus > 0 )
	{
		VoiceChatIcon = Texture2D'UI_HUD.voip_icon';
		
		C.SetDrawColor(255,255,255,255);
		C.SetPos(AvatarXPos - (Height * 0.75) - ImageBorder, YOffset + (Height / 2) - ((Height * 0.75) / 2));
		C.DrawTile(VoiceChatIcon,Height * 0.75,Height * 0.75,0,0,256,256);	
	}
	
	C.SetDrawColor(255, 255, 255, 255);
	C.SetPos(NameXPos, TextYOffset);
	if( Len(PRI.PlayerName) > 25 )
		S = Left(PRI.PlayerName, 25);
	else S = PRI.PlayerName;
	C.DrawText (S, , FontScalar, FontScalar);
}

final function Texture2D FindAvatar( UniqueNetId ClientID )
{
	local string S;
	
	S = KFPlayerController(GetPlayer()).GetSteamAvatar(ClientID);
	if( S=="" )
		return None;
	return Texture2D(FindObject(S,class'Texture2D'));
}

function GetStyleTextures()
{
	if( !Owner.bFinishedReplication )
	{
		return;
	}
	
	ItemBoxTexture = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_NORMAL];
	ItemBarTexture = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_NORMAL];
	CheckBoxTexture = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_DISABLED];
	CheckMarkTexture = Owner.CurrentStyle.CheckBoxTextures[`CHECKMARK_NORMAL];
	
	MenuBar.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
	MapInfo.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL_SLIGHTTRANSPARENT];
	StoryBoxBackground.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL_SLIGHTTRANSPARENT];
	BGPerkEffects.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];
	BGPerk.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];	
	//PlayerPortraitB.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];	
	
	WaveB.Image = KFHUDInterface(PC.myHUD).BioCircle;
	
	PlayersList.OnDrawItem = DrawPlayerEntry;
	
	bTextureInit = true;
}

function ClickedPlayer( int Index, bool bRight, int MouseX, int MouseY )
{
	local int i;
	local LocalPlayer LocPlayer;

	if( bRight || Index<0 )
		return;
	
	RightClickPlayer = KFPlayerReplicationInfo(KFGRI.PRIArray[Index]);
	LocPlayer = LocalPlayer(PC.Player);
	
	PlayerContext.ItemRows[0].Text = PC.IsPlayerMuted(RightClickPlayer.UniqueId) ? class'KFGFxWidget_BaseParty'.default.UnmuteString : class'KFGFxWidget_BaseParty'.default.MuteString;
	PlayerContext.ItemRows[1].Text = OnlineSub.IsFriend(LocPlayer.ControllerId,RightClickPlayer.UniqueId) ? class'KFGFxWidget_BaseParty'.default.RemoveFriendString : class'KFGFxWidget_BaseParty'.default.AddFriendString;

	if( RightClickPlayer == KFPRI ) // Selected self.
	{
		for( i=0; i<PlayerContext.ItemRows.Length; ++i )
			PlayerContext.ItemRows[i].bDisabled = true;
	}
	else
	{
		for( i=0; i<PlayerContext.ItemRows.Length; ++i )
			PlayerContext.ItemRows[i].bDisabled = false;
	}
	
	PlayerContext.OpenMenu(Self);
}

function SelectedRCItem( int Index )
{
	local LocalPlayer LocPlayer;
	
	switch( Index )
	{
	case 0:
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
	case 1:
		LocPlayer = LocalPlayer(PC.Player);
		if( LocPlayer == None )
		{
			return;
		}
		
		if( OnlineSub.IsFriend(LocPlayer.ControllerId,RightClickPlayer.UniqueId) )
		{
			OnlineSub.RemoveFriend( LocPlayer.ControllerId, RightClickPlayer.UniqueId );
		}
		else
		{
			OnlineSub.AddFriend( LocPlayer.ControllerId, RightClickPlayer.UniqueId );
		}
		break;
	case 2:
		OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem()).ShowProfileUI(0,,RightClickPlayer.UniqueId);
		break;
	case 3:
		KFPRI.ServerStartKickVote(RightClickPlayer, KFPRI);
		break;
	}
}

function UserPressedEsc();

defaultproperties
{
	bNoBackground=true
	
	XPosition=0
	YPosition=0
	XSize=1
	YSize=1
	
	WaitingForServerStatus="Awaiting server status..."
	WaitingForOtherPlayers="Waiting for players to be ready..."
	AutoCommence="Game will auto-commence in"
	
	Begin Object Class=KFGUI_Frame Name=MenuBar
		ID="MenuBar"
		bDrawHeader=true
		XPosition=0
		YPosition=0.96
		XSize=1
		YSize=0.04
		EdgeSize(0)=0.f
		EdgeSize(1)=0.f
		EdgeSize(2)=0.f
		EdgeSize(3)=0.f
	End Object
	Components.Add(MenuBar)
	
	Begin Object Class=KFGUI_Frame Name=MapInfo
		ID="MapInfo"
		bDrawHeader=true
		XPosition=0.489062
		YPosition=0.037851
		XSize=0.487374
		YSize=0.075000
	End Object
	Components.Add(MapInfo)
	
	Begin Object Class=KFGUI_TextLable Name=CurrentMapL
		ID="CurrentMapL"
	    YPosition=0.047179
		XPosition=0.496524
        XSize=0.36
        YSize=0.035714
		Text="LAlalala Map"
		TextColor=(R=175,G=176,B=158,A=255)
	End Object
	Components.Add(CurrentMapL)

	Begin Object Class=KFGUI_TextLable Name=DifficultyL
		ID="DifficultyL"
	    YPosition=0.077381
       	XPosition=0.496524
        XSize=0.36
        YSize=0.035714
		Text="Difficulty"
		TextColor=(R=175,G=176,B=158,A=255)
	End Object
	Components.Add(DifficultyL)
	
	Begin Object class=KFGUI_Image Name=WaveB
		ID="WaveB"
      	YPosition=0.043810
        XPosition=0.923238
        XSize=0.051642
        YSize=0.061783
	End Object
	Components.Add(WaveB)

	Begin Object Class=KFGUI_TextLable Name=WaveL
		ID="WaveL"
		Text="1/4"
        AlignX=1
		AlignY=1
        TextColor=(B=158,G=176,R=175)
      	YPosition=0.043810
        XPosition=0.923238
        XSize=0.051642
        YSize=0.061783
	End Object
	Components.Add(WaveL)
	
	Begin Object Class=KFGUI_Frame Name=StoryBoxBackground
		ID="StoryBoxBackground"
	    bDrawHeader=true
   		YPosition=0.109808
        XPosition=0.489062
        XSize=0.487374
        YSize=0.309092
	End Object
	Components.Add(StoryBoxBackground)
	
	Begin Object Class=KFGUI_TextScroll Name=MOTDText
		ID="MOTDText"
   		YPosition=0.119808
        XPosition=0.499062
        XSize=0.492374
        YSize=0.314092
		ScrollSpeed=0.025
		LineSplitter="<LINEBREAK>"
	End Object
	Components.Add(MOTDText)
	
	Begin Object class=UIR_LobbyPerkInfo Name=BGPerk
		ID="BGPerk"
    	YPosition=0.432291
        XPosition=0.489062
        XSize=0.487374
        YSize=0.138086
		WindowTitle="Current Perk"
	End Object
	Components.Add(BGPerk)
	
	Begin Object class=UIR_LobbyPerkEffects Name=BGPerkEffects
		ID="BGPerkEffects"
	    YPosition=0.568448
        XPosition=0.489062
        XSize=0.487374
        YSize=0.307442
		WindowTitle="Perk Effects"
	End Object
	Components.Add(BGPerkEffects)
	
	/*
	Begin Object class=UIR_LobbyCharacterInfo Name=PlayerPortraitB
		ID="PlayerPortraitB"
       	YPosition=0.432291
        XPosition=0.489062
        XSize=0.163305
        YSize=0.25
		WindowTitle="Current Character"
	End Object
	Components.Add(PlayerPortraitB)
	
	Begin Object Class=KFGUI_Button Name=CharacterButton
		ID="CharacterB"
		ButtonText="Gear"
		Tooltip="Open the menu to change your current character"
		XPosition=0.492522
		YPosition=0.695
		XSize=0.156368
		YSize=0.06
	End Object
	Components.Add(CharacterButton)
	*/
	
	Begin Object Class=KFGUI_List Name=PlayerBackDrop
		ID="PlayerList"
		YPosition=0.055
		XPosition=0.075
		XSize=0.35
		YSize=0.475
		ListItemsPerPage=12
		bClickable=true
	End Object
	Components.Add(PlayerBackDrop)
	
	Begin Object Class=UIR_ChatBox Name=ChatBox
		ID="ChatBox"
		XPosition=0.096279
		YPosition=0.568448
		XSize=0.307442
		YSize=0.307442
	End Object
	Components.Add(ChatBox)	
	
	Begin Object Class=KFGUI_TextLable Name=TimeOutCounter
		ID="TimeOutCounter"
		AlignX=1
		AlignY=1
		FontScale=1.35
		Text="Game will auto-commence in: "
		TextColor=(R=175,G=176,B=158,A=255)
        YPosition=0.00001
        XPosition=0.059552
        XSize=0.346719
        YSize=0.045704
    End Object
	Components.Add(TimeOutCounter)
	
	Begin Object Class=KFGUI_RightClickMenu Name=PlayerContextMenu
	End Object
	PlayerContext=PlayerContextMenu
}