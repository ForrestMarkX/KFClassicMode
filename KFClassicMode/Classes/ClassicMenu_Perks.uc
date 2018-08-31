class ClassicMenu_Perks extends KFGFxMenu_Perks;

var ClassicPlayerController ClassicKFPC;

function OnOpen()
{
	if( KFPC == none )
	{
		KFPC = KFPlayerController( GetPC() );
	}
	
	if( ClassicKFPC == none )
	{
		ClassicKFPC = ClassicPlayerController(GetPC());
	}
	
	LastPerkIndex = ClassicKFPC.GetPerkIndexFromClass(KFPC.CurrentPerk.Class);

	MyKFPRI = KFPlayerReplicationInfo( GetPC().PlayerReplicationInfo );
    
	UpdateSkillsHolder(KFPC.CurrentPerk.Class);
    UpdateContainers(KFPC.CurrentPerk.Class); 

    UpdateLock();
    CheckTiersForPopup();

    if(SelectionContainer != none)
    {
    	SelectionContainer.SetPerkListEnabled(!KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).bReadyToPlay);
    }

    ActionScriptVoid("updatePrompts");
}

function OneSecondLoop()
{
	if(KFPC != none)
	{
		if( PreviousPerk == KFPC.CurrentPerk.Class && LastPerkLevel != KFPC.CurrentPerk.GetLevel() )
		{
			UpdateContainers(KFPC.CurrentPerk.Class);
			PreviousPerk = KFPC.CurrentPerk.Class;
			LastPerkLevel = KFPC.CurrentPerk.GetLevel();			
			return;
		}		
	}
}

function SavePerkData()
{
	if( ClassicKFPC != none && ClassicKFPC.CanUpdatePerkInfoEx() )
  	{
		ClassicKFPC.NotifyPendingPerkChanges();
	}
}

function UpdateSkillsHolder(class<KFPerk> PerkClass)
{
	ClassicKFPC.ServerChangePerks(ClassicKFPC.PerkManager.FindPerk(PerkClass));
}

event OnClose()
{
	local bool bShouldUpdatePerk;

  	if( ClassicKFPC != none )
  	{
  		if( bModifiedPerk || bModifiedSkills )
  		{
			bShouldUpdatePerk = bModifiedPerk && LastPerkIndex != ClassicKFPC.SavedPerkIndex;

			SavePerkData();

			if( !bChangesMadeDuringLobby && (bShouldUpdatePerk || bModifiedSkills) && ClassicKFPC.CanUpdatePerkInfoEx() )
			{
				ClassicKFPC.NotifyPerkUpdated();
  			}

			if( bShouldUpdatePerk )
			{
	  			SelectionContainer.SavePerk( LastPerkIndex );
				Manager.CachedProfile.SetProfileSettingValueInt( KFID_SavedPerkIndex, LastPerkIndex );
			}

  			bModifiedPerk = false;
  			bModifiedSkills = false;
  		}
  	}

	Super(KFGFxObject_Menu).OnClose();
}

function UpdateLock()
{
	local WorldInfo TempWorldInfo;
	local KFGameReplicationInfo KFGRI;

	TempWorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if ( TempWorldInfo != none && TempWorldInfo.GRI != none )
	{
		KFGRI = KFGameReplicationInfo(TempWorldInfo.GRI);
		if ( KFGRI != none && ClassicKFPC != none )
		{
			SetBool( "locked", (KFGRI.CanChangePerks() && ClassicKFPC.WasPerkUpdatedThisRoundEx()) );
		}
	}
}

function CheckTiersForPopup();
function Callback_SkillSelectionOpened();
function UpdateSkillsUI( Class<KFPerk> PerkClass );

defaultproperties
{
	SubWidgetBindings.Remove((WidgetName="SelectionContainer",WidgetClass=class'KFGFxPerksContainer_Selection'))
	SubWidgetBindings.Add((WidgetName="SelectionContainer",WidgetClass=class'ClassicPerksContainer_Selection'))
	
	SubWidgetBindings.Remove((WidgetName="HeaderContainer",WidgetClass=class'KFGFxPerksContainer_Header'))
	SubWidgetBindings.Add((WidgetName="HeaderContainer",WidgetClass=class'ClassicPerksContainer_Header'))
	
	SubWidgetBindings.Remove((WidgetName="DetailsContainer",WidgetClass=class'KFGFxPerksContainer_Details'))
	SubWidgetBindings.Add((WidgetName="DetailsContainer",WidgetClass=class'ClassicPerksContainer_Details'))
	
	SubWidgetBindings.Remove((WidgetName="SkillsContainer",WidgetClass=class'KFGFxPerksContainer_Skills'))
	SubWidgetBindings.Add((WidgetName="SkillsContainer",WidgetClass=class'ClassicPerksContainer_Skills'))
	
	SubWidgetBindings.Remove((WidgetName="SelectedPerkSummaryContainer",WidgetClass=class'KFGFxPerksContainer_SkillsSummary'))
	SubWidgetBindings.Add((WidgetName="SelectedPerkSummaryContainer",WidgetClass=class'ClassicPerksContainer_SkillsSummary'))
}
