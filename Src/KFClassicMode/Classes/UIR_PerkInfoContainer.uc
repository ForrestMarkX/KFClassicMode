Class UIR_PerkInfoContainer extends KFGUI_Frame;

var KFGUI_List PerkList;
var ClassicPerkManager CurrentManager;
var ClassicPerk_Base PendingPerk,OldUsedPerk;
var class<ClassicPerk_Base> PrevPendingPerk;

var float IconBorder;
var float ItemBorder;
var float TextTopOffset;
var float ItemSpacing;
var float IconToInfoSpacing;
var float ProgressBarHeight;

var string LvAbbrString;

var Texture PerkBackground;
var Texture InfoBackground;
var Texture SelectedPerkBackground;
var Texture SelectedInfoBackground;
var Texture ProgressBarBackground;
var Texture ProgressBarForeground;

function InitMenu()
{
    PerkList = KFGUI_List(FindComponentID('Perks'));
    Super.InitMenu();
}

function ShowMenu()
{
    Super.ShowMenu();
    SetTimer(0.1,true);
    Timer();
    
    UIP_PerkSelection(ParentComponent).SelectedPerk = ClassicPerk_Base(KFPlayerController(GetPlayer()).GetPerk());
}

function DrawPerkInfo( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local float TempX, TempY;
    local float IconSize, ProgressBarWidth;
    local float TempWidth, TempHeight;
    local float Sc;
    local Texture2D PerkIcon, StarIcon;
    local ClassicPerk_Base P;

    P = CurrentManager.UserPerks[Index];
    if( P == None )
        return;

    // Offset for the Background
    TempX = 0.f;
    TempY = YOffset + ItemSpacing / 2.0;
    IconSize = 0.f;

    // Initialize the Canvas
    C.Font = Owner.CurrentStyle.PickFont(Sc);
    C.SetDrawColor(255, 255, 255, 255);

    // Draw Item Background
    C.SetPos(TempX, TempY);
    if ( bFocus || P.Class == ClassicPlayerReplicationInfo(GetPlayer().PlayerReplicationInfo).CurrentPerkClass )
    {
        C.DrawTileStretched(SelectedPerkBackground, IconSize, IconSize, 0, 0, SelectedPerkBackground.GetSurfaceWidth(), SelectedPerkBackground.GetSurfaceHeight());
        C.SetPos(TempX + IconSize - 1.0, YOffset + 7.0);
        C.DrawTileStretched(SelectedInfoBackground, Width - IconSize, Height - ItemSpacing - 14, 0, 0, SelectedInfoBackground.GetSurfaceWidth(), SelectedInfoBackground.GetSurfaceHeight());
    }
    else
    {
        if( P==PendingPerk )
        {
            C.SetDrawColor(0,255,0);
        }
        
        C.DrawTileStretched(PerkBackground, IconSize, IconSize, 0, 0, PerkBackground.GetSurfaceWidth(), PerkBackground.GetSurfaceHeight());
        C.SetPos(TempX + IconSize - 1.0, YOffset + 7.0);
        C.DrawTileStretched(InfoBackground, Width - IconSize, Height - ItemSpacing - 14, 0, 0, InfoBackground.GetSurfaceWidth(), InfoBackground.GetSurfaceHeight());
    }

    // Offset and Calculate Icon's Size
    TempX += ItemBorder * Height;
    TempY += ItemBorder * Height;
    IconSize = Height - ItemSpacing - (ItemBorder * 2.0 * Height);

    // Draw Icon
    P.static.PreDrawPerk(C, P.GetLevel(), PerkIcon, StarIcon);
    
    C.SetPos(TempX, TempY);
    C.DrawTileStretched(PerkIcon, IconSize, IconSize, 0, 0, PerkIcon.GetSurfaceWidth(), PerkIcon.GetSurfaceHeight());

    TempX += IconSize + (IconToInfoSpacing * Width);
    TempY += TextTopOffset * Height;

    ProgressBarWidth = Width - TempX - (IconToInfoSpacing * Width);

    // Select Text Color
    if ( bFocus )
        C.SetDrawColor(255, 0, 0, 255);
    else C.SetDrawColor(255, 255, 255, 255);

    // Draw the Perk's Level Name
    C.TextSize(P.GetPerkName(), TempWidth, TempHeight, Sc, Sc);
    C.SetPos(TempX, TempY);
    C.DrawText(P.GetPerkName(),,Sc,Sc);

    // Draw the Perk's Level
    C.TextSize(LvAbbrString@P.GetLevel(), TempWidth, TempHeight, Sc, Sc);
    C.SetPos(TempX + ProgressBarWidth - TempWidth, TempY);
    C.DrawText(LvAbbrString@P.GetLevel(),,Sc,Sc);

    TempY += TempHeight + (0.05 * Height);

    // Draw Progress Bar
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(TempX, TempY);
    C.DrawTileStretched(ProgressBarBackground, ProgressBarWidth, ProgressBarHeight * Height, 0, 0, ProgressBarBackground.GetSurfaceWidth(), ProgressBarBackground.GetSurfaceHeight());
    C.SetPos(TempX, TempY);
    C.DrawTileStretched(ProgressBarForeground, ProgressBarWidth * P.GetProgressPercent(), ProgressBarHeight * Height, 0, 0, ProgressBarForeground.GetSurfaceWidth(), ProgressBarForeground.GetSurfaceHeight());
}

function SwitchedPerk( int Index, bool bRight, int MouseX, int MouseY )
{
    if( CurrentManager==None || Index>CurrentManager.UserPerks.Length )
        return;
    
    PlayMenuSound(MN_ClickButton);
    
    PendingPerk = CurrentManager.UserPerks[Index];
    UIP_PerkSelection(ParentComponent).SelectedPerk = PendingPerk;
}

function Timer()
{
    if( !bTextureInit )
    {
        GetStyleTextures();
    }
    
    CurrentManager = ClassicPlayerController(GetPlayer()).PerkManager;
    
    if( CurrentManager!=None )
    {
        if( PrevPendingPerk!=None )
        {
            PendingPerk = CurrentManager.FindPerk(PrevPendingPerk);
            PrevPendingPerk = None;
        }
        PerkList.ChangeListSize(CurrentManager.UserPerks.Length);
    }
}

function CloseMenu()
{
    local ClassicPlayerController PC;
    
    Super.CloseMenu();
    
    PC = ClassicPlayerController(GetPlayer());
    if( PC != None )
    {
        if( PendingPerk == PC.PendingPerk )
            return;
            
        PC.ServerChangePerks(PendingPerk);
        if( PC.CanUpdatePerkInfoEx() )
        {
            PC.SetHaveUpdatePerk(true);
        }
    }
    
    CurrentManager = None;
    PrevPendingPerk = (PendingPerk!=None ? PendingPerk.Class : None);
    PendingPerk = None;
    OldUsedPerk = None;
    SetTimer(0,false);
}

function GetStyleTextures()
{
    if( !Owner.bFinishedReplication )
    {
        return;
    }
    
    PerkBackground = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_NORMAL];
    InfoBackground = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_NORMAL];
    SelectedPerkBackground = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_NORMAL];
    SelectedInfoBackground = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_HIGHLIGHTED];
    ProgressBarBackground = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER];
    ProgressBarForeground = Owner.CurrentStyle.ProgressBarTextures[`PROGRESS_BAR_NORMAL];
    
    PerkList.OnDrawItem = DrawPerkInfo;
    PerkList.OnClickedItem = SwitchedPerk;
    
    bTextureInit = true;
}

defaultproperties
{
    IconBorder=0.05
    ItemBorder=0.11
    TextTopOffset=0.01
    ItemSpacing=0.0
    IconToInfoSpacing=0.05
    ProgressBarHeight=0.25
    LvAbbrString="Lv"
    
    Begin Object Class=KFGUI_List Name=PerksList
        ID="Perks"
        ListItemsPerPage=7
        bClickable=true
        bHideScrollbar=true
    End Object
    
    Components.Add(PerksList)
}