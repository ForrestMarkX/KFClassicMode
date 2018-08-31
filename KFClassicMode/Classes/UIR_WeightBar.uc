class UIR_WeightBar extends KFGUI_Base;

var Texture BarBack;
var Texture BarTop;

var int MaxBoxes;
var int CurBoxes;
var int NewBoxes;

var string EncString;

var float CurX;
var float CurY;
var float BoxSizeX;
var float BoxSizeY;
var float Spacer;

var color CurrentColor;
var color NewColor;
var color WarnColor;

var	string EncumbranceString;

function DrawMenu()
{
	local int i;
	local float TextSizeX, TextSizeY, TextScaler;
	local float BoxW, BoxH;
	
	if( !bTextureInit )
	{
		GetStyleTextures();
		return;
	}

	CurX = 0.f;
	CurY = CompPos[3] / 2.5;

	for ( i = 0; i < MaxBoxes; i++ )
	{
		Canvas.SetPos(CurX, CurY);
		Canvas.DrawTileStretched(BarBack, BoxSizeX * Canvas.SizeX, BoxSizeY * Canvas.SizeX, 0, 0, BarBack.GetSurfaceWidth(), BarBack.GetSurfaceHeight());
		CurX += BoxSizeX * Canvas.SizeX;
	}

	EncString = EncumbranceString$":" @ CurBoxes $ "/" $ MaxBoxes;

	Canvas.Font = Owner.CurrentStyle.PickFont(TextScaler);
	Canvas.TextSize(EncString, TextSizeX, TextSizeY, TextScaler, TextScaler);
	Canvas.SetPos(0.f, CurY - TextSizeY - ((CurY - TextSizeY) / 2));
	Canvas.DrawColor = CurrentColor;
	Canvas.DrawText(EncString,,TextScaler,TextScaler);

	CurX = Spacer * Canvas.SizeX;
	CurY = (CompPos[3] / 2.5) + ((Spacer * Canvas.SizeY) * 1.5);

	BoxW = (BoxSizeX - (Spacer * 2)) * Canvas.SizeX;
	BoxH = (BoxSizeY - (Spacer * 2)) * Canvas.SizeX;
	
	for ( i = 0; i < CurBoxes && i < MaxBoxes; i++ )
	{
		Canvas.SetPos(CurX, CurY);
		Canvas.DrawTileStretched(BarTop, BoxW, BoxH, 0, 0, BarTop.GetSurfaceWidth(), BarTop.GetSurfaceHeight());
		CurX += BoxSizeX * Canvas.SizeX;
	}

	if ( NewBoxes != 0 )
	{
		if ( CurBoxes + NewBoxes <= MaxBoxes )
		{
			for ( i = 0; i < NewBoxes; i++ )
			{
				Canvas.DrawColor = NewColor;
				Canvas.SetPos(CurX, CurY);
				Canvas.DrawTileStretched(BarTop, BoxW, BoxH, 0, 0, BarTop.GetSurfaceWidth(), BarTop.GetSurfaceHeight());
				CurX += BoxSizeX * Canvas.SizeX;
			}
		}
		else
		{
			for ( i = 0; i < NewBoxes && i < (MaxBoxes - CurBoxes); i++ )
			{
				Canvas.DrawColor = WarnColor;
				Canvas.SetPos(CurX, CurY);
				Canvas.DrawTileStretched(BarTop, BoxW, BoxH, 0, 0, BarTop.GetSurfaceWidth(), BarTop.GetSurfaceHeight());
				CurX += BoxSizeX * Canvas.SizeX;
			}
		}
	}
}

function GetStyleTextures()
{
	if( !Owner.bFinishedReplication )
	{
		return;
	}
	
	BarBack = Owner.CurrentStyle.PerkBox[`PERK_BOX_UNSELECTED];
	BarTop = Owner.CurrentStyle.ProgressBarTextures[`PROGRESS_BAR_SELECTED];
	
	bTextureInit = true;
}

defaultproperties
{
	BoxSizeX=0.015
	BoxSizeY=0.015

	Spacer=0.0012

	MaxBoxes=15
	NewBoxes=0

	CurrentColor=(R=175,G=176,B=158,A=255)
	NewColor=(R=255,G=128,B=0,A=255)
	WarnColor=(R=255,G=0,B=0,A=255)

	EncumbranceString="Encumbrance Level"
}
