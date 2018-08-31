class UIR_WeaponBar extends KFGUI_ProgressBar;

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
	
	BarBack = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER_TRANSPARENT];
	BarTop = Owner.CurrentStyle.ProgressBarTextures[`PROGRESS_BAR_NORMAL];
	
	bTextureInit = true;
}

defaultproperties
{
     High=1000.f
	 ValueRightWidth=0.01
     bShowValue=True
}
