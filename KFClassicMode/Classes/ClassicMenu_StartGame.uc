class ClassicMenu_StartGame extends KFGFxMenu_StartGame;

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case ('missionObjectivesContainerMC'):

			if(MissionObjectiveContainer == none)
			{
				MissionObjectiveContainer = KFGFxMissionObjectivesContainer(Widget);
				MissionObjectiveContainer.SetVisible(false);
			}
			break;
	    case ('findGameContainer'):
			if ( FindGameContainer == none )
			{
			    FindGameContainer = KFGFxStartGameContainer_FindGame( Widget );
			    FindGameContainer.Initialize( self );
		    }
        break;
        case ('gameOptionsContainer'):
			if ( OptionsComponent == none )
			{
			    OptionsComponent = KFGFxStartGameContainer_Options( Widget );
			    OptionsComponent.Initialize( self );
		    }
        break;
        case ('overviewContainer'):
			if ( OverviewContainer == none )
			{
			    OverviewContainer = KFGFxStartContainer_InGameOverview( Widget );
			    OverviewContainer.Initialize( self );
			    SetOverview(true);
		    }
        break;
        case ('serverBrowserOverviewContainer'):
			if ( ServerBrowserOverviewContainer == none )
			{
			    ServerBrowserOverviewContainer = KFGFxStartContainer_ServerBrowserOverview( Widget );
			    ServerBrowserOverviewContainer.Initialize( self );
		    }
        break;
		case ('matchMakingButton'):
			MatchMakingButton = Widget;
			if(class'WorldInfo'.static.IsConsoleBuild() && ServerBrowserButton != None)
			{
				CheckGameFullyInstalled();
			}
		break;
		case ('serverBrowserButton'):
			ServerBrowserButton = Widget;
			if(class'WorldInfo'.static.IsConsoleBuild() && MatchMakingButton != None)
			{
				CheckGameFullyInstalled();
			}
		break;
	}

	return true;
}

function OnOpen()
{
	if( Manager != none )
	{
		Manager.SetStartMenuState(EStartMenuState(GetStartMenuState()));
	}
}

function OnPlayerReadiedUp();

defaultproperties
{
	SubWidgetBindings.Remove((WidgetName="overviewContainer",WidgetClass=class'KFGFxStartContainer_InGameOverview'))
	SubWidgetBindings.Add((WidgetName="overviewContainer",WidgetClass=class'ClassicStartContainer_InGameOverview'))
}



