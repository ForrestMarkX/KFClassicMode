class UIR_TraderWeightFrame extends KFGUI_Frame;

var KFGUI_Image WeightIco;

function InitMenu()
{
	Super.InitMenu();
	WeightIco = KFGUI_Image(FindComponentID('WeightIco'));
}

function DrawMenu()
{
	Super.DrawMenu();
	
	if( !bTextureInit )
	{
		GetStyleTextures();
	}
}

function GetStyleTextures()
{
	if( !Owner.bFinishedReplication )
	{
		return;
	}
	
	FrameTex = Owner.CurrentStyle.PerkBox[`PERK_BOX_UNSELECTED];
	WeightIco.Image = KFHUDInterface(GetPlayer().myHUD).WeightIcon;
	
	bTextureInit = true;
}

defaultproperties
{
	HeaderSize(0)=0.f
	HeaderSize(1)=0.f
	EdgeSize(0)=0.f
	EdgeSize(1)=0.f
	EdgeSize(2)=0.f
	EdgeSize(3)=0.f
		
	/* Weight Icon HUD */
	Begin Object class=KFGUI_Image Name=WeightIco
		ID="WeightIco"
		YPosition=0.025
		XPosition=0
		XSize=1
		YSize=1
		bAlignCenter=true
	End Object
	Components.Add(WeightIco)
}