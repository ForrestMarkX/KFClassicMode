Class UIP_Settings extends KFGUI_MultiComponent;

var KFGUI_ComponentList SettingsBox;
var KFGUI_TextLable ResetColorLabel,PerkStarsLabel,PerkStarsRowLabel,ControllerTypeLabel;
var KFGUI_EditBox PerkStarsBox, PerkRowsBox;
var KFGUI_ComboBox ControllerBox;

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
    
    /*
    PerkStarsBox = AddEditBox("Max Perk Stars","How many perk stars to show.",'MaxPerkStars',string(KFHUDInterface(GetPlayer().myHUD).MaxPerkStars),PerkStarsLabel);
    PerkStarsBox.bIntOnly = true;
    
    PerkRowsBox = AddEditBox("Max Stars Per-Row","How many perk stars to draw per row.",'MaxStarsPerRow',string(KFHUDInterface(GetPlayer().myHUD).MaxStarsPerRow),PerkStarsRowLabel);
    PerkRowsBox.bIntOnly = true;
    */
    
    ControllerBox = AddComboBox("Controller Type","What controller type to use for GUI elements.",'ControllerType',ControllerTypeLabel);
    ControllerBox.Values.AddItem("Xbox One");
    ControllerBox.Values.AddItem("Playstation 4");
    
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
    local ClassicPlayerController PC;

    PC = ClassicPlayerController(GetPlayer());
    switch( Sender.ID )
    {
    case 'ControllerType':
        PC.ControllerType = Sender.GetCurrent() ~= "Xbox One" ? "UI_Controller" : "UI_Controller_Orbis";
        break;
    }
    
    PC.SaveConfig();
}

function OnTextChanged(KFGUI_EditBox Sender)
{
    local ClassicPlayerController PC;

    PC = ClassicPlayerController(GetPlayer());
    switch( Sender.ID )
    {
    case 'MaxPerkStars':
        KFHUDInterface(PC.myHUD).MaxPerkStars = int(Sender.TextStr);
        break;
    case 'MaxStarsPerRow':
        KFHUDInterface(PC.myHUD).MaxStarsPerRow = int(Sender.TextStr);
        break;
    }
    
    KFHUDInterface(PC.myHUD).SaveConfig();
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