class ClassicPerksContainer_Selection extends KFGFxPerksContainer_Selection;

function UpdatePerkSelection(byte SelectedPerkIndex)
{
 	local int i;
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local ClassicPlayerController KFPC;
	local ClassicPerk_Base PerkClass;	

	KFPC = ClassicPlayerController( GetPC() );

	if ( KFPC!=none && KFPC.PerkManager!=None )
	{
	   	DataProvider = CreateArray();

		for (i = 0; i < KFPC.PerkList.Length; i++)
		{
			PerkClass = KFPC.PerkManager.FindPerk(KFPC.PerkList[i].PerkClass);
			
		    TempObj = CreateObject( "Object" );
		    TempObj.SetInt( "PerkLevel", PerkClass.GetLevel() );
		    TempObj.SetString( "Title",  PerkClass.static.GetPerkName() );	
			TempObj.SetString( "iconSource", "img://"$PathName(PerkClass.static.GetCurrentPerkIcon(PerkClass.GetLevel())) );
			TempObj.SetBool( "bTierUnlocked", false );
			
		    DataProvider.SetElementObject( i, TempObj );
		}	
		SetObject( "perkData", DataProvider );
		SetInt("SelectedIndex", SelectedPerkIndex);

		UpdatePendingPerkInfo(SelectedPerkIndex);
    }
}

function UpdatePendingPerkInfo(byte SelectedPerkIndex)
{
	local string PerkName;
	local ClassicPlayerController KFPC;
	local ClassicPerk_Base PerkClass;

	KFPC = ClassicPlayerController( GetPC() );
	
	if( KFPC != none && KFGRI != none )
	{
		PerkClass = KFPC.PerkManager.FindPerk(KFPC.PerkList[SelectedPerkIndex].PerkClass);
		
		if(!class'WorldInfo'.static.IsMenuLevel())
		{
			if( (!KFPC.CanUpdatePerkInfoEx() && !KFGRI.CanChangePerks()) || (KFGRI.CanChangePerks() && PerksMenu.bModifiedPerk) && KFPC.PlayerReplicationInfo.bReadyToPlay && KFPC.WorldInfo.GRI.bMatchHasBegun)
			{
				PerkName = PerkClass.static.GetPerkName();
			}
			else
			{
				PerkName = "";
			}
		}	
		
		if(KFGRI.CanChangePerks() && KFPC.CanUpdatePerkInfoEx())
		{
			SetPendingPerkChanges(PerkName, "img://"$PathName(PerkClass.static.GetCurrentPerkIcon(PerkClass.GetLevel())), ChangesAppliedOnCloseString);
		}
		else
		{
			SetPendingPerkChanges(PerkName, "img://"$PathName(PerkClass.static.GetCurrentPerkIcon(PerkClass.GetLevel())), EndOfWaveString);
		}
	}
}

function SavePerk(int PerkID)
{
	local ClassicPlayerController KFPC;

    KFPC = ClassicPlayerController(GetPC());
	if ( KFPC != none )
	{
		KFPC.ServerChangePerks(KFPC.PerkManager.FindPerk(KFPC.PerkList[PerkID].PerkClass));
		
		if( KFPC.CanUpdatePerkInfoEx() )
		{
			KFPC.SetHaveUpdatePerk(true);
		}
	}
}