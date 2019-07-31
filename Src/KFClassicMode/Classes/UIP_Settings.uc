Class UIP_Settings extends KFGUI_MultiComponent;

var KFGUI_ComponentList SettingsBox;
var KFGUI_TextLable ResetColorLabel,PerkStarsLabel,PerkStarsRowLabel,ControllerTypeLabel,PlayerInfoTypeLabel;
var KFGUI_EditBox PerkStarsBox, PerkRowsBox;
var KFGUI_ComboBox ControllerBox;

var KFHUDInterface HUD;
var ClassicPlayerController PC;

function InitMenu()
{
    local string S;
    
    PC = ClassicPlayerController(GetPlayer());
    HUD = KFHUDInterface(PC.myHUD);
    
    Super.InitMenu();

    // Client settings
    SettingsBox = KFGUI_ComponentList(FindComponentID('SettingsBox'));
    
    AddCheckBox("Light HUD","Show a light version of the HUD.",'bLight',HUD.bLightHUD);
    AddCheckBox("Show weapon info","Show current weapon ammunition status.",'bWeapons',!HUD.bHideWeaponInfo);
    AddCheckBox("Show personal info","Display health and armor on the HUD.",'bPersonal',!HUD.bHidePlayerInfo);
    AddCheckBox("Show score","Check to show scores on the HUD.",'bScore',!HUD.bHideDosh);
    AddCheckBox("Show kill counter","Tally specimen kills on the HUD.",'bTallySpecimenKills',!PC.bHideKillMsg);
    AddCheckBox("Show damage counter","Tally specimen damage on the HUD.",'bHideDamageMsg',!PC.bHideDamageMsg);
    AddCheckBox("Show player deaths","Shows when a player dies.",'bHidePlayerDeathMsg',!PC.bHidePlayerDeathMsg);
    AddCheckBox("Show hidden player icons","Shows the hidden player icons.",'bDisableHiddenPlayers',!HUD.bDisableHiddenPlayers);
    AddCheckBox("Show damage messages","Shows the damage popups when damaging ZEDs.",'bEnableDamagePopups',HUD.bEnableDamagePopups);
    AddCheckBox("Show regen on player info","Shows the bar next to players health when healed.",'bDrawRegenBar',HUD.bDrawRegenBar);
    AddCheckBox("Show player speed","Shows how fast you are moving.",'bShowSpeed',HUD.bShowSpeed);
    AddCheckBox("Show pickup information","Shows a UI with infromation on pickups.",'bDisablePickupInfo',!HUD.bDisablePickupInfo);
    AddCheckBox("Show lockon target","Shows who you have targeted with a medic gun.",'bDisableLockOnUI',!HUD.bDisableLockOnUI);
    AddCheckBox("Show medicgun recharge info","Shows what the recharge info is on various medic weapons.",'bDisableRechargeUI',!HUD.bDisableRechargeUI);
    AddCheckBox("Show last remaining ZED icons","Shows the last remaining ZEDs as icons.",'bDisableLastZEDIcons',!HUD.bDisableLastZEDIcons);
    AddCheckBox("Show XP earned","Shows when you earn XP.",'bShowXPEarned',HUD.bShowXPEarned);
    AddCheckBox("Disable classic trader voice","Disable the classic trader voice and portrait.",'bDisableClassicTrader',PC.bDisableClassicTrader);
    AddCheckBox("Disable classic music","Disable the classic music.",'bDisableClassicMusic',PC.bDisableClassicMusic);
    AddCheckBox("Enable B&W ZED Time","Enables the black and white fade to ZED Time.",'bEnableBWZEDTime',PC.bEnableBWZEDTime);
    AddCheckBox("Enable Modern Scoreboard","Makes the scoreboard look more modern.",'bModernScoreboard',HUD.bModernScoreboard);
    AddCheckBox("Disallow others to pickup your weapons","Disables other players ability to pickup your weapons.",'bDisallowOthersToPickupWeapons',PC.bDisallowOthersToPickupWeapons);
    AddCheckBox("Disable console replacment","Disables the console replacment.",'bNoConsoleReplacement',HUD.bNoConsoleReplacement);
    
    /*
    PerkStarsBox = AddEditBox("Max Perk Stars","How many perk stars to show.",'MaxPerkStars',string(HUD.MaxPerkStars),PerkStarsLabel);
    PerkStarsBox.bIntOnly = true;
    
    PerkRowsBox = AddEditBox("Max Stars Per-Row","How many perk stars to draw per row.",'MaxStarsPerRow',string(HUD.MaxStarsPerRow),PerkStarsRowLabel);
    PerkRowsBox.bIntOnly = true;
    */
    
    ControllerBox = AddComboBox("Controller Type","What controller type to use for GUI elements.",'ControllerType',ControllerTypeLabel);
    ControllerBox.Values.AddItem("Xbox One");
    ControllerBox.Values.AddItem("Playstation 4");
    ControllerBox.SetValue(PC.ControllerType ~= "UI_Controller" ? "Xbox One" : "Playstation 4");    
    
    switch(HUD.PlayerInfoType)
    {
        case INFO_CLASSIC:
            S = "Classic";
            break;
        case INFO_LEGACY:
            S = "Legacy";
            break;
        case INFO_MODERN:
            S = "Modern";
            break;
    }
    
    ControllerBox = AddComboBox("Player Info Type","What style to draw the player info system in.",'PlayerInfo',PlayerInfoTypeLabel);
    ControllerBox.Values.AddItem("Classic");
    ControllerBox.Values.AddItem("Legacy");
    ControllerBox.Values.AddItem("Modern");
    ControllerBox.SetValue(S);
    
    AddButton("Reset","Reset HUD Colors","Resets the color settings for the HUD.",'ResetColors',ResetColorLabel);
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
final function KFGUI_EditBox AddEditBox( string Cap, string TT, name IDN, string DefaultValue, out KFGUI_TextLable Label )
{
    local KFGUI_EditBox EB;
    local KFGUI_MultiComponent MC;
    
    MC = KFGUI_MultiComponent(SettingsBox.AddListComponent(class'KFGUI_MultiComponent'));
    MC.InitMenu();
    Label = new(MC) class'KFGUI_TextLable';
    Label.SetText(Cap);
    Label.XSize = 0.60;
    Label.FontScale = 1;
    Label.AlignY = 1;
    MC.AddComponent(Label);
    EB = new(MC) class'KFGUI_EditBox';
    EB.XPosition = 0.77;
    EB.YPosition = 0.5;
    EB.XSize = 0.15;
    EB.YSize = 1;
    EB.ToolTip = TT;
    EB.bDrawBackground = true;
    EB.ID = IDN;
    EB.OnChange = OnTextChanged;
    EB.SetText(DefaultValue);
    EB.bNoClearOnEnter = true;
    MC.AddComponent(EB);

    return EB;
}
final function KFGUI_ComboBox AddComboBox( string Cap, string TT, name IDN, out KFGUI_TextLable Label )
{
    local KFGUI_ComboBox CB;
    local KFGUI_MultiComponent MC;
    
    MC = KFGUI_MultiComponent(SettingsBox.AddListComponent(class'KFGUI_MultiComponent'));
    MC.InitMenu();
    Label = new(MC) class'KFGUI_TextLable';
    Label.SetText(Cap);
    Label.XSize = 0.60;
    Label.FontScale = 1;
    Label.AlignY = 1;
    MC.AddComponent(Label);
    CB = new(MC) class'KFGUI_ComboBox';
    CB.XPosition = 0.77;
    CB.XSize = 0.15;
    CB.ToolTip = TT;
    CB.ID = IDN;
    CB.OnComboChanged = OnComboChanged;
    MC.AddComponent(CB);

    return CB;
}

function OnComboChanged(KFGUI_ComboBox Sender)
{
    switch( Sender.ID )
    {
    case 'ControllerType':
        PC.ControllerType = Sender.GetCurrent() ~= "Xbox One" ? "UI_Controller" : "UI_Controller_Orbis";
        break;
    case 'PlayerInfo':
        switch(Sender.GetCurrent())
        {
            case "Classic":
                HUD.PlayerInfoType = INFO_CLASSIC;
                break;
            case "Legacy":
                HUD.PlayerInfoType = INFO_LEGACY;
                break;
            case "Modern":
                HUD.PlayerInfoType = INFO_MODERN;
                break;
        }
    
        break;
    }
    
    HUD.SaveConfig();
    PC.SaveConfig();
}

function OnTextChanged(KFGUI_EditBox Sender)
{
    switch( Sender.ID )
    {
    case 'MaxPerkStars':
        HUD.MaxPerkStars = int(Sender.TextStr);
        break;
    case 'MaxStarsPerRow':
        HUD.MaxStarsPerRow = int(Sender.TextStr);
        break;
    }
    
    HUD.SaveConfig();
}

function CheckChange( KFGUI_CheckBox Sender )
{
    local MusicGRI MGRI;
    local KFMapInfo KFMI;
    local KFGameReplicationInfo GRI;
    local KFPawn_Monster MPawn;
    local bool bHideKillMsg, bHideDamageMsg, bEnableDamagePopups, bHidePlayerDeathMsg;
    
    bHideKillMsg = PC.bHideKillMsg;
    bHideDamageMsg = PC.bHideDamageMsg;
    bHidePlayerDeathMsg = PC.bHidePlayerDeathMsg;
    bEnableDamagePopups = HUD.bEnableDamagePopups;

    switch( Sender.ID )
    {
    case 'bLight':
        HUD.bLightHUD = Sender.bChecked;
        break;
    case 'bWeapons':
        HUD.bHideWeaponInfo = !Sender.bChecked;
        break;
    case 'bPersonal':
        HUD.bHidePlayerInfo = !Sender.bChecked;
        break;
    case 'bScore':
        HUD.bHideDosh = !Sender.bChecked;
        break;
    case 'bTallySpecimenKills':
        PC.bHideKillMsg = !Sender.bChecked;
        break;       
    case 'bHideDamageMsg':
        PC.bHideDamageMsg = !Sender.bChecked;
        break;        
    case 'bHidePlayerDeathMsg':
        PC.bHidePlayerDeathMsg = !Sender.bChecked;
        break;    
    case 'bEnableBWZEDTime':
        PC.bEnableBWZEDTime = Sender.bChecked;
        break;    
    case 'bDisableHiddenPlayers':
        HUD.bDisableHiddenPlayers = !Sender.bChecked;
        break;    
    case 'bDisallowOthersToPickupWeapons':
        PC.bDisallowOthersToPickupWeapons = Sender.bChecked;
        PC.SetServerIgnoreDrops(PC.bDisallowOthersToPickupWeapons);
        break;
    case 'bEnableDamagePopups':
        HUD.bEnableDamagePopups = Sender.bChecked;
        break;    
    case 'bDrawRegenBar':
        HUD.bDrawRegenBar = Sender.bChecked;
        break;    
    case 'bShowSpeed':
        HUD.bShowSpeed = Sender.bChecked;
        break;    
    case 'bDisableClassicTrader':
        PC.bDisableClassicTrader = Sender.bChecked;
        break;        
    case 'bDisableClassicMusic':
        PC.bDisableClassicMusic = Sender.bChecked;
        
        MGRI = class'MusicGRI'.static.FindMusicGRI(PC.WorldInfo);
        if( MGRI != None )
        {
            KFMI = KFMapInfo(PC.WorldInfo.GetMapInfo());
            GRI = KFGameReplicationInfo(PC.WorldInfo.GRI);
            if( PC.bDisableClassicMusic )
            {
                KFMI.ActionMusicTracks = MGRI.OriginalActionMusicTracks;
                KFMI.AmbientMusicTracks = MGRI.OriginalAmbientMusicTracks;
                
                MGRI.ForceStopMusic();
                
                if( GRI.IsBossWave() )
                {
                    foreach PC.WorldInfo.DynamicActors(class'KFPawn_Monster',MPawn)
                    {
                        if( MPawn.IsA('KFPawn_ZedHans') )
                        {
                            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss1]);
                            break;
                        }
                        else if( MPawn.IsA('KFPawn_ZedPatriarch') )
                        {
                            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss2]);
                            break;
                        }
                        else if( MPawn.IsA('KFPawn_ZedMatriarch') )
                        {
                            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss3]);
                            break;
                        }
                        else if( MPawn.IsA('KFPawn_ZedFleshpoundKing') )
                        {
                            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss4]);
                            break;
                        }
                        else if( MPawn.IsA('KFPawn_ZedBloatKing') )
                        {
                            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss5]);
                            break;
                        }
                    }
                }
                else GRI.PlayNewMusicTrack(false, !GRI.bWaveIsActive);
            }
            else 
            {
                KFMI.ActionMusicTracks = MGRI.ClassicActionMusicTracks;
                KFMI.AmbientMusicTracks = MGRI.ClassicAmbientMusicTracks;
                
                GRI.MusicComp.StopEvents();
                
                if( GRI.IsBossWave() )
                    MGRI.PlayNewMusicTrack();
                else MGRI.SelectNewTrack();
            }
        }
        
        break;    
    case 'bDisableLastZEDIcons':
        HUD.bDisableLastZEDIcons = !Sender.bChecked;
        break;    
    case 'bDisablePickupInfo':
        HUD.bDisablePickupInfo = !Sender.bChecked;
        break;    
    case 'bDisableLockOnUI':
        HUD.bDisableLockOnUI = !Sender.bChecked;
        break;   
    case 'bDisableRechargeUI':
        HUD.bDisableRechargeUI = !Sender.bChecked;
        break;    
    case 'bModernScoreboard':
        HUD.bModernScoreboard = Sender.bChecked;
        break;    
    case 'bShowXPEarned':
        HUD.bShowXPEarned = Sender.bChecked;
        break;    
    case 'bNoConsoleReplacement':
        HUD.bNoConsoleReplacement = Sender.bChecked;
        
        if( HUD.bNoConsoleReplacement )
            HUD.ResetConsole();
        else HUD.CreateAndSetConsoleReplacment();
        
        break;
    }
    
    if( bHideKillMsg != PC.bHideKillMsg || bHideDamageMsg != PC.bHideDamageMsg || bEnableDamagePopups != HUD.bEnableDamagePopups || bHidePlayerDeathMsg != PC.bHidePlayerDeathMsg )
        PC.ServerSetSettings(PC.bHideKillMsg, PC.bHideDamageMsg, !HUD.bEnableDamagePopups, PC.bHidePlayerDeathMsg);
        
    HUD.SaveConfig();
    PC.SaveConfig();
}
function ButtonClicked( KFGUI_Button Sender )
{
    switch( Sender.ID )
    {
    case 'ResetColors':
        HUD.ResetHUDColors();
        if( PC.ColorSettingMenu != None )
        {
            PC.ColorSettingMenu.MainHudSlider.SetDefaultColor(HUD.HudMainColor);
            PC.ColorSettingMenu.OutlineSlider.SetDefaultColor(HUD.HudOutlineColor);
            PC.ColorSettingMenu.FontSlider.SetDefaultColor(HUD.FontColor);
        }
        break;
    }
}

defaultproperties
{
    Begin Object Class=KFGUI_ComponentList Name=ClientSettingsBox
        ID="SettingsBox"
        ListItemsPerPage=16
    End Object
    
    Components.Add(ClientSettingsBox)
}