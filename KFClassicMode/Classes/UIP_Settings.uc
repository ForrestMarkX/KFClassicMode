Class UIP_Settings extends KFGUI_MultiComponent;

var KFGUI_ComponentList SettingsBox;
var KFGUI_Button KeyBindButton;
var KFGUI_TextLable KeyBindLabel,ResetColorLabel;
var name CurKeybind;
var bool bSetKeybind,bDelayedSet;

function InitMenu()
{
	Super.InitMenu();

	// Client settings
	SettingsBox = KFGUI_ComponentList(FindComponentID('SettingsBox'));
	
	AddCheckBox("Light HUD","Show a light version of the HUD.",'bLight',KFHUDInterface(GetPlayer().myHUD).bLightHUD);
	AddCheckBox("Show Weapon Info","Show current weapon ammunition status.",'bWeapons',!KFHUDInterface(GetPlayer().myHUD).bHideWeaponInfo);
	AddCheckBox("Show Personal Info","Display health and armor on the HUD.",'bPersonal',!KFHUDInterface(GetPlayer().myHUD).bHidePlayerInfo);
	AddCheckBox("Show Score","Check to show scores on the HUD.",'bScore',!KFHUDInterface(GetPlayer().myHUD).bHideDosh);
	AddCheckBox("Show Kill Counter","Tally specimen kills on the HUD.",'bTallySpecimenKills',!ClassicPlayerController(GetPlayer()).bHideKillMsg);
	
	AddButton("Reset","Reset HUD Colors","Resets the color settings for the HUD.",'ResetColors',ResetColorLabel);
	KeyBindButton = AddButton("","Toggle Behindview keybind:","With this desired button you can toggle your behindview (click to change it)",'KB',KeyBindLabel);
	InitBehindviewKey();
}
final function InitBehindviewKey()
{
	local PlayerInput IN;
	local int i;

	CurKeybind = '';

	// Check what keys now using!
	IN = Owner.BackupInput;
	for( i=0; i<IN.Bindings.Length; ++i )
	{
		if( IN.Bindings[i].Command~="Camera FirstPerson" )
		{
			CurKeybind = IN.Bindings[i].Name;
			break;
		}
	}
	KeyBindButton.ButtonText = (CurKeybind!='' ? string(CurKeybind) : "<Not set>");
}
final function KFGUI_CheckBox AddCheckBox( string Cap, string TT, name IDN, bool bDefault )
{
	local KFGUI_CheckBox CB;
	
	CB = KFGUI_CheckBox(SettingsBox.AddListComponent(class'KFGUI_CheckBox'));
	CB.LableString = Cap;
	CB.ToolTip = TT;
	CB.bChecked = bDefault;
	CB.InitMenu();
	CB.ID = IDN;
	CB.OnCheckChange = CheckChange;
	return CB;
}
final function KFGUI_Button AddButton( string ButtonText, string Cap, string TT, name IDN, out KFGUI_TextLable Label )
{
	local KFGUI_Button CB;
	local KFGUI_MultiComponent MC;
	
	MC = KFGUI_MultiComponent(SettingsBox.AddListComponent(class'KFGUI_MultiComponent'));
	MC.InitMenu();
	Label = new(MC) class'KFGUI_TextLable';
	Label.SetText(Cap);
	Label.XSize = 0.60;
	Label.FontScale = 1;
	Label.AlignY = 1;
	MC.AddComponent(Label);
	CB = new(MC) class'KFGUI_Button';
	CB.XPosition = 0.77;
	CB.XSize = 0.15;
	CB.ButtonText = ButtonText;
	CB.ToolTip = TT;
	CB.ID = IDN;
	CB.OnClickLeft = ButtonClicked;
	CB.OnClickRight = ButtonClicked;
	MC.AddComponent(CB);

	return CB;
}

function CheckChange( KFGUI_CheckBox Sender )
{
	local ClassicPlayerController PC;

	PC = ClassicPlayerController(GetPlayer());
	switch( Sender.ID )
	{
	case 'bLight':
		KFHUDInterface(PC.myHUD).bLightHUD = Sender.bChecked;
		break;
	case 'bWeapons':
		KFHUDInterface(PC.myHUD).bHideWeaponInfo = !Sender.bChecked;
		break;
	case 'bPersonal':
		KFHUDInterface(PC.myHUD).bHidePlayerInfo = !Sender.bChecked;
		break;
	case 'bScore':
		KFHUDInterface(PC.myHUD).bHideDosh = !Sender.bChecked;
		break;
	case 'bTallySpecimenKills':
		PC.bHideKillMsg = !Sender.bChecked;
		break;
	}
	
	KFHUDInterface(PC.myHUD).SaveConfig();
	PC.SaveConfig();
}
function ButtonClicked( KFGUI_Button Sender )
{
	local ClassicPlayerController PC;

	PC = ClassicPlayerController(GetPlayer());
	switch( Sender.ID )
	{
	case 'KB':
		KeyBindButton.ButtonText = "Press a button";
		KeyBindButton.SetDisabled(true);
		GrabKeyFocus();
		bSetKeybind = true;
		bDelayedSet = false;
		SetTimer(0.4,false);
		break;
	case 'ResetColors':
		KFHUDInterface(PC.myHUD).ResetHUDColors();
		if( PC.ColorSettingMenu != None )
		{
			PC.ColorSettingMenu.MainHudSlider.SetDefaultColor(KFHUDInterface(GetPlayer().myHUD).HudMainColor);
			PC.ColorSettingMenu.OutlineSlider.SetDefaultColor(KFHUDInterface(GetPlayer().myHUD).HudOutlineColor);
			PC.ColorSettingMenu.FontSlider.SetDefaultColor(KFHUDInterface(GetPlayer().myHUD).FontColor);
		}
		break;
	}
}
function Timer()
{
	bDelayedSet = false;
}
function bool NotifyInputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed, bool bGamepad )
{
	if( Event==IE_Pressed && !bDelayedSet && InStr(Caps(string(Key)),"MOUSE")==-1 )
	{
		if( Key!='Escape' )
			BindNewKey(Key,"Camera FirstPerson");
		ReleaseKeyFocus();
	}
	return true;
}
function LostKeyFocus()
{
	KeyBindButton.SetDisabled(false);
	bSetKeybind = false;
	InitBehindviewKey();
}
final function BindNewKey( name Key, string Cmd )
{
	local PlayerController PC;

	PC = GetPlayer();
	if (PC != None && PC.PlayerInput != None)
	{
		PC.PlayerInput.SetBind(Key, Cmd);
	}
}

function DrawMenu()
{
	Canvas.SetDrawColor(250,250,250,255);
	Canvas.SetPos(0.f,0.f);
	Canvas.DrawTileStretched(Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER],CompPos[2],CompPos[3],0,0,128,128);
}

defaultproperties
{
	Begin Object Class=KFGUI_ComponentList Name=ClientSettingsBox
		XPosition=0.05
		YPosition=0.05
		XSize=0.95
		YSize=0.95
		ID="SettingsBox"
		ListItemsPerPage=16
	End Object
	
	Components.Add(ClientSettingsBox)
}