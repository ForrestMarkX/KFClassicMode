class UIR_LobbyPerkInfo extends KFGUI_Frame;

var float IconBorder;
var float ItemBorder;
var float ItemSpacing;
var float ProgressBarHeight;
var float TextTopOffset;
var float IconToInfoSpacing;

var Texture ProgressBarBackground, ProgressBarForeground;
var Texture ItemBoxTexture, ItemBarTexture;

function DrawMenu()
{
    local float X, Y, Width, Height;
    local float TempX, TempY;
    local float TempWidth, TempHeight;
    local float IconSize, ProgressBarWidth, PerkProgress;
    local float FontScalar;
    local string PerkName, PerkLevelString;
    local KFPlayerController PC;
    local ClassicPerk_Base CurrentPerk;
    local Texture PerkIcon, PerkStarIcon;
    
    if( !bTextureInit )
    {
        GetStyleTextures();
        return;
    }
    
    Super.DrawMenu();
    
    PC = KFPlayerController(GetPlayer());
    if( PC == None )
        return;
        
    CurrentPerk = ClassicPerk_Base(PC.CurrentPerk);
    if( CurrentPerk == None )
        return;

    PerkName =  CurrentPerk.static.GetPerkName();
    PerkLevelString = "Lvl" @ CurrentPerk.GetLevel();
    PerkProgress = CurrentPerk.GetProgressPercent();

    //Get the position size etc in pixels
    Width = CompPos[2] - 10;
    Height = CompPos[3] - 37;
    
    X = 5.f;
    Y = 30.f;

    // Offset for the Background
    TempX = X;
    TempY = Y + ItemSpacing / 2.0;

    // Initialize the Canvas
    Canvas.Font = Owner.CurrentStyle.PickFont(FontScalar);
    Canvas.SetDrawColor(255, 255, 255, 255);

    // Draw Item Background
    Canvas.SetPos(TempX, TempY);

    IconSize = Height - ItemSpacing;

    // Draw Item Background
    Canvas.DrawTileStretched(ItemBoxTexture, IconSize, IconSize, 0, 0, ItemBoxTexture.GetSurfaceWidth(), ItemBoxTexture.GetSurfaceHeight());
    Canvas.SetPos(TempX + IconSize - 1.0, Y + 7.0);
    Canvas.DrawTileStretched(ItemBarTexture, Width - IconSize, Height - ItemSpacing - 14, 0, 0, ItemBarTexture.GetSurfaceWidth(), ItemBarTexture.GetSurfaceHeight());

    IconSize -= IconBorder * 2.0 * Height;

    // Draw Icon
    CurrentPerk.static.PreDrawPerk(Canvas, CurrentPerk.GetLevel(), PerkIcon, PerkStarIcon);
    
    Canvas.SetPos(TempX + IconBorder * Height, TempY + IconBorder * Height);
    Canvas.DrawTile(PerkIcon, IconSize, IconSize, 0, 0, PerkIcon.GetSurfaceWidth(), PerkIcon.GetSurfaceHeight());

    TempX += IconSize + (IconToInfoSpacing * Width);
    TempY += TextTopOffset * Height + ItemBorder * Height;

    ProgressBarWidth = Width - (TempX - X) - (IconToInfoSpacing * Width);

    // Select Text Color
    Canvas.SetDrawColor(0, 0, 0, 255);

    // Draw the Perk's Level name
    Canvas.TextSize(PerkName, TempWidth, TempHeight, FontScalar, FontScalar);
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawText(PerkName,,FontScalar,FontScalar);

    // Draw the Perk's Level
    if ( PerkLevelString != "" )
    {
        Canvas.TextSize(PerkLevelString, TempWidth, TempHeight, FontScalar, FontScalar);
        Canvas.SetPos(TempX + ProgressBarWidth - TempWidth, TempY);
        Canvas.DrawText(PerkLevelString,,FontScalar,FontScalar);
    }

    TempY += TempHeight + (0.04 * Height);

    // Draw Progress Bar
    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawTileStretched(ProgressBarBackground, ProgressBarWidth, ProgressBarHeight * Height, 0, 0, ProgressBarBackground.GetSurfaceWidth(), ProgressBarBackground.GetSurfaceHeight());
    Canvas.SetPos(TempX + 3.0, TempY + 3.0);
    Canvas.DrawTileStretched(ProgressBarForeground, (ProgressBarWidth - 6.0) * PerkProgress, (ProgressBarHeight * Height) - 6.0, 0, 0, ProgressBarForeground.GetSurfaceWidth(), ProgressBarForeground.GetSurfaceHeight());
}

function GetStyleTextures()
{
    if( !Owner.bFinishedReplication )
    {
        return;
    }
    
    ItemBoxTexture = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_NORMAL];
    ItemBarTexture = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_NORMAL];
    ProgressBarBackground = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER];
    ProgressBarForeground = Owner.CurrentStyle.ProgressBarTextures[`PROGRESS_BAR_NORMAL];
    
    bTextureInit = true;
}

defaultproperties
{
    IconBorder=0.05
    ItemBorder=0.11
    ProgressBarHeight=0.3
    IconToInfoSpacing=0.05
    TextTopOffset=0.05
    ItemSpacing=0.0
}