class UIR_SpectatorInfoBox extends KFGUI_MultiComponent;

/*var KFGUI_Frame PlayerInfoBox, NextTargetBox, ChangeCameraBox, PrevTargetBox;
var KFGUI_TextLable PlayerInfoLabel, NextTargetLabel, ChangeCameraLabel, PrevTargetLabel;
var KFGUI_Image PlayerInfoImage;*/

var PlayerReplicationInfo SpectatedPRI;
var ClassicPlayerController KFPC;

var Texture2D LMBButton, MMBButton, RMBButton;

function InitMenu()
{
    Super.InitMenu();
    
    /*
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
    PlayerInfoImage.DrawBackground = DrawPerkBox;
    */
    
    KFPC = ClassicPlayerController(GetPlayer());
}

/*
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
*/

function bool ShouldHide()
{
    return KFPC.PlayerCamera.CameraStyle == 'Boss' || !KFPC.IsSpectating() || KFPC.LobbyMenu != None || KFGameReplicationInfo(KFPC.WorldInfo.GRI).bMatchIsOver || class'WorldInfo'.static.IsMenuLevel();
}

function SetSpectatedPRI(PlayerReplicationInfo PRI)
{
    //local KFPlayerReplicationInfo KFPRI;
    //local class<ClassicPerk_Base> PerkClass;
    //local byte PerkLevel;
    
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
    
    /*
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
    */
}

/*
function DrawSpectatorBox(Canvas C, float W, Float H)
{
    Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, 0.f, 0.f, W, H, HUDOwner.HudMainColor);
}

function DrawPerkBox(Canvas C, float W, Float H)
{
    local Color BoxColor;
    
    BoxColor = Owner.HUDOwner.HudOutlineColor;
    BoxColor.A = 255;
    
    Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, 0.f, 0.f, W, H, BoxColor);
}
*/

function DrawMenu()
{
    local float MainBoxW, MainBoxH, InfoBoxX, InfoBoxY, InfoBoxW, InfoBoxH, SubBoxW, IconX, IconY, IconH, OriginalFontScalar, FontScalar, TextX, TextY, XL, YL, PerkX, PerkY, PerkH;
    local Color BoxColor;
    local string S;
    local KFPlayerReplicationInfo KFPRI;
    local class<ClassicPerk_Base> PerkClass;
    local byte PerkLevel;
    local float BorderScale;
    
    BorderScale = Owner.HUDOwner.ScaledBorderSize*2;
    Canvas.Font = Owner.CurrentStyle.PickFont(OriginalFontScalar);
    
    BoxColor = HUDOwner.HudOutlineColor;
    BoxColor.A = 255;
    
    MainBoxW = CompPos[2];
    MainBoxH = CompPos[3] * 0.5;
    
    SubBoxW = MainBoxH + BorderScale;
    
    if( SpectatedPRI != None && SpectatedPRI != KFPC.PlayerReplicationInfo )
    {
        Owner.CurrentStyle.DrawRoundedBox(BorderScale, 0.f, 0.f, MainBoxW, MainBoxH, HUDOwner.HudMainColor);
        Owner.CurrentStyle.DrawRoundedBox(BorderScale, 0.f, 0.f, SubBoxW, MainBoxH, MakeColor(60, 60, 60, 255));
        
        KFPRI = KFPlayerReplicationInfo(SpectatedPRI);
        if( KFPRI != None )
        {
            FontScalar = OriginalFontScalar + 0.45;
            
            S = KFPRI.GetHumanReadableName();
            Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
            
            TextX = SubBoxW + BorderScale;
            TextY = (MainBoxH/2) - (YL/2);
            
            Canvas.DrawColor = Owner.HUDOwner.WhiteColor;
            Canvas.SetPos(TextX, TextY);
            Canvas.DrawText(S,, FontScalar, FontScalar);
            
            PerkClass = class<ClassicPerk_Base>(KFPRI.CurrentPerkClass);
            if( PerkClass != None )
            {
                FontScalar = OriginalFontScalar + 0.1;
                
                S = class'KFPerk'.default.LevelString@KFPRI.GetActivePerkLevel()@PerkClass.static.GetPerkName();
                Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
                
                TextX = SubBoxW + BorderScale;
                TextY += YL + (BorderScale * 2);
                
                Canvas.DrawColor = Owner.HUDOwner.WhiteColor;
                Canvas.SetPos(TextX, TextY);
                Canvas.DrawText(S,, FontScalar, FontScalar);
                
                PerkH = MainBoxH - (Owner.HUDOwner.ScaledBorderSize*2);
                
                PerkX = (SubBoxW/2) - (PerkH/2);
                PerkY = (MainBoxH/2) - (PerkH/2) - (Owner.HUDOwner.ScaledBorderSize/2);
                
                PerkLevel = KFPRI.GetActivePerkLevel();
                
                Canvas.DrawColor = PerkClass.static.GetPerkColor(PerkLevel);
                Canvas.SetPos(PerkX, PerkY);
                Canvas.DrawRect(PerkH, PerkH, PerkClass.static.GetCurrentPerkIcon(PerkLevel));
            }
        }
    }
    
    InfoBoxY = CompPos[3] * 0.55;
    InfoBoxW = MainBoxW / (3 + (Owner.HUDOwner.ScaledBorderSize/100.f));
    InfoBoxH = CompPos[3] * 0.175;
    
    SubBoxW = InfoBoxH + BorderScale;
    
    IconH = InfoBoxH - BorderScale;
    
    IconX = (SubBoxW/2) - (IconH/2);
    IconY = InfoBoxY + (InfoBoxH/2) - (IconH/2);
    
    S = class'KFGFxHUD_SpectatorInfo'.default.PrevPlayerString;
    Canvas.TextSize(S, XL, YL, OriginalFontScalar, OriginalFontScalar);
    
    TextX = SubBoxW + (Owner.HUDOwner.ScaledBorderSize*2);
    TextY = InfoBoxY + (InfoBoxH/2) - (YL/2);
    
    Owner.CurrentStyle.DrawRoundedBox(BorderScale, 0.f, InfoBoxY, InfoBoxW, InfoBoxH, HUDOwner.HudMainColor);
    Owner.CurrentStyle.DrawRoundedBox(BorderScale, 0.f, InfoBoxY, SubBoxW, InfoBoxH, BoxColor);
    
    Canvas.DrawColor = Owner.HUDOwner.WhiteColor;
    Canvas.SetPos(IconX, IconY);
    Canvas.DrawRect(IconH, IconH, LMBButton);
    
    Canvas.DrawColor = Owner.HUDOwner.WhiteColor;
    Canvas.SetPos(TextX, TextY);
    Canvas.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
    
    InfoBoxX = InfoBoxW + (Owner.HUDOwner.ScaledBorderSize*2);
    Owner.CurrentStyle.DrawRoundedBox(BorderScale, InfoBoxX, InfoBoxY, InfoBoxW, InfoBoxH, HUDOwner.HudMainColor);
    Owner.CurrentStyle.DrawRoundedBox(BorderScale, InfoBoxX, InfoBoxY, SubBoxW, InfoBoxH, BoxColor);
    
    Canvas.DrawColor = Owner.HUDOwner.WhiteColor;
    Canvas.SetPos(IconX + InfoBoxX, IconY);
    Canvas.DrawRect(IconH, IconH, MMBButton);
    
    S = class'KFGFxHUD_SpectatorInfo'.default.ChangeCameraString;
    
    Canvas.DrawColor = Owner.HUDOwner.WhiteColor;
    Canvas.SetPos(TextX + InfoBoxX, TextY);
    Canvas.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
    
    InfoBoxX *= 2;
    Owner.CurrentStyle.DrawRoundedBox(BorderScale, InfoBoxX, InfoBoxY, InfoBoxW, InfoBoxH, HUDOwner.HudMainColor);
    Owner.CurrentStyle.DrawRoundedBox(BorderScale, InfoBoxX, InfoBoxY, SubBoxW, InfoBoxH, BoxColor);
    
    Canvas.DrawColor = Owner.HUDOwner.WhiteColor;
    Canvas.SetPos(IconX + InfoBoxX, IconY);
    Canvas.DrawRect(IconH, IconH, RMBButton);
    
    S = class'KFGFxHUD_SpectatorInfo'.default.NextPlayerString;
    
    Canvas.DrawColor = Owner.HUDOwner.WhiteColor;
    Canvas.SetPos(TextX + InfoBoxX, TextY);
    Canvas.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
}

defaultproperties
{
    LMBButton=Texture2D'UI_HUD.InGameHUD_ZED_SWF_I139'
    MMBButton=Texture2D'UI_HUD.InGameHUD_ZED_SWF_I13C'
    RMBButton=Texture2D'UI_HUD.InGameHUD_ZED_SWF_I13F'
    
    XPosition=0.325
    YPosition=0.75
    XSize=0.35
    YSize=0.2
        
    /*
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
    */
}