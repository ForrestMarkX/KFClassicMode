Class UIR_LevelRequirementsList extends KFGUI_Frame;

var KFGUI_List 			RequirementList;
var array<string> 		RequirementsText;
var ClassicPerk_Base 	CurrentSelectedPerk;

var()	float			ItemBorder;
var()	float			ItemSpacing;
var()	float			ProgressBarHeight;
var()	float			TextTopOffset;

var	Texture				ItemBackground;
var	Texture				ProgressBarBackground;
var	Texture				ProgressBarForeground;

var string				OneThousandSuffix;
var string				OneMillionSuffix;
var string				DecimalPoint;
var string				UnitDelimiter;

function InitMenu()
{
	RequirementList = KFGUI_List(FindComponentID('Requirements'));
    Super.InitMenu();
}

function ShowMenu()
{
    Super.ShowMenu();
	
    SetTimer(0.1,true);
    Timer();
}

final function string FormatNumber(int Value)
{
	if ( Value < 100000 )
	{
		return string(Value);
	}

	if ( Value < 1000000 )
	{
		return string(Value / 1000)$OneThousandSuffix;
	}

	return string(Value / 1000000)$DecimalPoint$string((Value % 1000000) / 100000)$OneMillionSuffix;
}

function DrawEffectInfo(Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus)
{
	local float AspectRatio;
	local float BorderSize;
	local float TempX, TempY, XL, YL;
	local float TempWidth, TempHeight;
	local float Sc;
	local int i;
	local string ProgressString;
	local array<string> SplitText;

	// Calculate the Aspect Ratio(Helps Widescreen)
	AspectRatio = Canvas.ClipX / Canvas.ClipY;

	// Calc BorderSize so we dont do it 10 times per draw
	BorderSize = (3.0 - AspectRatio) * ItemBorder * Width;

	// Offset for the Background
	TempX = 0.f;
	TempY = YOffset + ItemSpacing / 2.0;

	// Initialize the Canvas
	Canvas.Font = Owner.CurrentStyle.PickFont(Sc);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ItemBackground, Width, Height - ItemSpacing, 0, 0, ItemBackground.GetSurfaceWidth(), ItemBackground.GetSurfaceHeight());

	// Offset Border
	TempX += BorderSize;
	TempY += ((3.0 - AspectRatio) * BorderSize) + (TextTopOffset * Height);

	// Draw the Requirement string
	Canvas.SetDrawColor(192, 192, 192, 255);
	
	SplitText = SplitString(RequirementsText[Index], "|");
	for ( i = 0; i < SplitText.Length; i++ )
	{
		Canvas.TextSize(SplitText[i], XL, YL, Sc, Sc);
		Canvas.SetPos(TempX, TempY);
		Canvas.DrawText(SplitText[i], , Sc, Sc);
		
		TempY += (YL * 0.75);
	}

	// Get Width of Requirements Progress String
	ProgressString = FormatNumber(CurrentSelectedPerk.CurrentEXP)$" XP / "$FormatNumber(CurrentSelectedPerk.NextLevelEXP)$" XP";
	Canvas.TextSize(ProgressString, TempWidth, TempHeight, Sc, Sc);

	TempX = Width - TempWidth - BorderSize;
	TempY = YOffset + Height - TempHeight;

	// Draw the Requirement's Progress String
	Canvas.SetPos(TempX + 2.0, TempY - 2.0);
	Canvas.DrawText(ProgressString,, Sc, Sc);

	// Create gap between Progress Bar and Progress String
	TempX -= ItemSpacing;
	TempHeight = YOffset + Height - TempY - (BorderSize / 2.0) - (ItemSpacing / 2.0);

	// Draw Progress Bar
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(BorderSize, TempY);
	Canvas.DrawTileStretched(ProgressBarBackground, TempX - BorderSize, TempHeight, 0, 0, ProgressBarBackground.GetSurfaceWidth(), ProgressBarBackground.GetSurfaceHeight());
	Canvas.SetPos(BorderSize + 3.0, TempY + 3.0);
	Canvas.DrawTileStretched(ProgressBarForeground, (TempX - BorderSize - 6.0) * CurrentSelectedPerk.GetProgressPercent(), TempHeight - 6.0, 0, 0, ProgressBarForeground.GetSurfaceWidth(), ProgressBarForeground.GetSurfaceHeight());
}

function Timer()
{
	local UIP_PerkSelection SelectionParent;
	local array<string> ReqInfos;
	local int i;
	
	if( !bTextureInit )
	{
		GetStyleTextures();
	}
	
	SelectionParent = UIP_PerkSelection(ParentComponent);
	if( SelectionParent == None || CurrentSelectedPerk == SelectionParent.SelectedPerk )
		return;

	CurrentSelectedPerk = SelectionParent.SelectedPerk;
	
	for( i = 0; i < CurrentSelectedPerk.EXPActions.Length; i++ )
	{
		ReqInfos[i / 2] = ReqInfos[i / 2]$"|"$CurrentSelectedPerk.EXPActions[i];
	}
	
	RequirementsText = ReqInfos;
	RequirementList.ChangeListSize(ReqInfos.Length);
}

function GetStyleTextures()
{
	if( !Owner.bFinishedReplication )
	{
		return;
	}
	
	ItemBackground = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
	ProgressBarBackground = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER];
	ProgressBarForeground = Owner.CurrentStyle.ProgressBarTextures[`PROGRESS_BAR_NORMAL];
	
	RequirementList.OnDrawItem = DrawEffectInfo;
	
	bTextureInit = true;
}

defaultproperties
{
	ItemBorder=0.018
	ItemSpacing=0.0
	ProgressBarHeight=0.25
	TextTopOffset=-0.14
	
	OneThousandSuffix="K"
	OneMillionSuffix="M"
	
    Begin Object Class=KFGUI_List Name=RequirementList
        ID="Requirements"
        ListItemsPerPage=3
		bHideScrollbar=true
        bClickable=false
    End Object
	
	Components.Add(RequirementList)
}