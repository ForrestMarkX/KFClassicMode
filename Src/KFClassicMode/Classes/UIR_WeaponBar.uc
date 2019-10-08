class UIR_WeaponBar extends KFGUI_ProgressBar;

var string CaptionOverride;
var Color TextColor;

var bool bHighlighted;
var protectedwrite Color OriginalBarColor;
var Color HighlightColor, UpgradeColor;

function InitMenu()
{
    Super.InitMenu();
    OriginalBarColor = BarColor;
}

function SetHighlight(bool bValue, optional bool bUpgraded)
{
    bHighlighted = bValue;
    if( bUpgraded )
        BarColor = UpgradeColor;
    else if( !bHighlighted )
        BarColor = OriginalBarColor;
    else BarColor = HighlightColor;
}

function DrawMenu()
{
    local float FontScale,XL,YL;
    
    Super.DrawMenu();
    
    if( !bTextureInit )
    {
        GetStyleTextures();
    }
    
    Canvas.Font = Owner.CurrentStyle.PickFont(FontScale);
    Canvas.TextSize(CaptionOverride,XL,YL,FontScale,FontScale);
    Canvas.DrawColor = TextColor;
    Canvas.SetPos((CompPos[2]*0.5)-(XL*0.5),(CompPos[3]*0.5)-(YL*0.5));
    Canvas.DrawText(CaptionOverride,,FontScale,FontScale);
}

function GetStyleTextures()
{
    if( !Owner.bFinishedReplication )
    {
        return;
    }
    
    BarBack = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER_TRANSPARENT];
    BarTop = Owner.CurrentStyle.ProgressBarTextures[`PROGRESS_BAR_NORMAL];
    
    bTextureInit = true;
}

defaultproperties
{
     HighlightColor=(B=128,G=192,R=128,A=255)
     UpgradeColor=(B=0,G=255,R=255,A=255)
     TextColor=(B=192,G=192,R=192,A=255)
     BarColor=(B=128,G=128,R=128,A=255)
     bShowValue=False
}
