class UIR_SpectatorInfoBox extends KFGUI_MultiComponent;

var KFGUI_Frame PlayerInfoBox, NextTargetBox, ChangeCameraBox, PrevTargetBox;
var KFGUI_TextLable PlayerInfoLabel, NextTargetLabel, ChangeCameraLabel, PrevTargetLabel;
var KFGUI_Image PlayerInfoImage;

var PlayerReplicationInfo SpectatedPRI;
var ClassicPlayerController KFPC;

function InitMenu()
{
	Super.InitMenu();
	
	PlayerInfoBox = KFGUI_Frame(FindComponentID('PlayerInfoBox'));
	PlayerInfoBox.OnDrawFrame = DrawSpectatorBox;
	
	NextTargetBox = KFGUI_Frame(FindComponentID('NextTargetBox'));
	NextTargetBox.OnDrawFrame = DrawSpectatorBox;
	
	ChangeCameraBox = KFGUI_Frame(FindComponentID('ChangeCameraBox'));
	ChangeCameraBox.OnDrawFrame = DrawSpectatorBox;
	
	PrevTargetBox = KFGUI_Frame(FindComponentID('PrevTargetBox'));
	PrevTargetBox.OnDrawFrame = DrawSpectatorBox;
	
	PlayerInfoLabel = KFGUI_TextLable(FindComponentID('PlayerInfoLabel'));
	NextTargetLabel = KFGUI_TextLable(FindComponentID('NextTargetLabel'));
	ChangeCameraLabel = KFGUI_TextLable(FindComponentID('ChangeCameraLabel'));
	PrevTargetLabel = KFGUI_TextLable(FindComponentID('PrevTargetLabel'));
	
	PlayerInfoImage = KFGUI_Image(FindComponentID('PlayerInfoImage'));
	
	KFPC = ClassicPlayerController(GetPlayer());
}

function ShowMenu()
{
	local KFPlayerInput KFInput;
	local KeyBind BoundKey;
	
	Super.ShowMenu();
	
	KFInput = KFPlayerInput(KFPC.PlayerInput);
	if( KFInput == None )
		return;
				
	KFInput.GetKeyBindFromCommand(BoundKey, "SpectatePrevPlayer", false);
	NextTargetLabel.SetText(KFInput.GetBindDisplayName(BoundKey)@"Next Player");
	
	KFInput.GetKeyBindFromCommand(BoundKey, "SpectateChangeCamMode", false);
	ChangeCameraLabel.SetText(KFInput.GetBindDisplayName(BoundKey)@"Change Camera");
	
	KFInput.GetKeyBindFromCommand(BoundKey, "SpectateNextPlayer", false);
	PrevTargetLabel.SetText(KFInput.GetBindDisplayName(BoundKey)@"Previous Player");
}

function bool ShouldHide()
{
	return KFPC.PlayerCamera.CameraStyle == 'Boss' || !KFPC.IsSpectating() || KFPC.LobbyMenu != None;
}

function SetSpectatedPRI(PlayerReplicationInfo PRI)
{
	local KFPlayerReplicationInfo KFPRI;
	local class<ClassicPerk_Base> PerkClass;
	local byte PerkLevel;
	
	SpectatedPRI = PRI;
	
	if( ShouldHide() )
	{
		SetVisibility(false);
		return;
	}
	
	if( !bVisible )
	{
		SetVisibility(true);
	}
	
	if( PRI == None || PRI == KFPC.PlayerReplicationInfo )
	{
		PlayerInfoBox.SetVisibility(false);
		PlayerInfoLabel.SetVisibility(false);
		PlayerInfoImage.SetVisibility(false);
		return;
	}
	else
	{
		PlayerInfoBox.SetVisibility(true);
		PlayerInfoLabel.SetVisibility(true);
		PlayerInfoImage.SetVisibility(true);
	}
	
	PlayerInfoLabel.SetText(PRI.GetHumanReadableName());
	
	KFPRI = KFPlayerReplicationInfo(PRI);
	if( KFPRI != None )
	{
		PerkClass = class<ClassicPerk_Base>(KFPRI.CurrentPerkClass);
		if( PerkClass != None )
		{
			PerkLevel = KFPRI.GetActivePerkLevel();
			
			PlayerInfoImage.Image = PerkClass.static.GetCurrentPerkIcon(PerkLevel);
			PlayerInfoImage.ImageColor = PerkClass.static.GetPerkColor(PerkLevel);
		}
	}
}

function DrawSpectatorBox(Canvas C, float W, Float H)
{
	Owner.CurrentStyle.DrawOutlinedBox(0.f, 0.f, W, H, Owner.CurrentStyle.ScreenScale(2), Owner.HUDOwner.HudMainColor, Owner.HUDOwner.HudOutlineColor);
}

defaultproperties
{
	XPosition=0.35
	YPosition=0.65
	XSize=0.3
	YSize=0.2
		
	Begin Object Class=KFGUI_Frame Name=PlayerInfoBox
		ID="PlayerInfoBox"
		XSize=1
		YSize=0.5
		FrameOpacity=195
	End Object
	
	Begin Object Class=KFGUI_TextLable Name=PlayerInfoLabel
		ID="PlayerInfoLabel"
		XPosition=0.2
		XSize=0.8
		YSize=0.5
		FontScale=4
		AlignY=1
	End Object
	
	Begin Object Class=KFGUI_Image Name=PlayerInfoImage
		ID="PlayerInfoImage"
		YPosition=0.025
		XPosition=0.0125
		XSize=0.175
		YSize=0.45
		bAlignCenter=true
	End Object
	
	Begin Object Class=KFGUI_Frame Name=NextTargetBox
		ID="NextTargetBox"
		YPosition=0.55
		XSize=0.33
		YSize=0.275
		FrameOpacity=195
	End Object
	
	Begin Object Class=KFGUI_TextLable Name=NextTargetLabel
		ID="NextTargetLabel"
		YPosition=0.55
		XSize=0.33
		YSize=0.275
		AlignX=1
		AlignY=1
	End Object
	
	Begin Object Class=KFGUI_Frame Name=ChangeCameraBox
		ID="ChangeCameraBox"
		XPosition=0.335
		YPosition=0.55
		XSize=0.33
		YSize=0.275
		FrameOpacity=195
	End Object
	
	Begin Object Class=KFGUI_TextLable Name=ChangeCameraLabel
		ID="ChangeCameraLabel"
		XPosition=0.335
		YPosition=0.55
		XSize=0.33
		YSize=0.275
		AlignX=1
		AlignY=1
	End Object
	
	Begin Object Class=KFGUI_Frame Name=PrevTargetBox
		ID="PrevTargetBox"
		XPosition=0.67
		YPosition=0.55
		XSize=0.33
		YSize=0.275
		FrameOpacity=195
	End Object
	
	Begin Object Class=KFGUI_TextLable Name=PrevTargetLabel
		ID="PrevTargetLabel"
		XPosition=0.67
		YPosition=0.55
		XSize=0.33
		YSize=0.275
		AlignX=1
		AlignY=1
	End Object
	
	Components.Add(PlayerInfoBox)	
	Components.Add(PlayerInfoLabel)	
	Components.Add(PlayerInfoImage)	
	Components.Add(NextTargetBox)
	Components.Add(NextTargetLabel)
	Components.Add(ChangeCameraBox)
	Components.Add(ChangeCameraLabel)
	Components.Add(PrevTargetBox)
	Components.Add(PrevTargetLabel)
}