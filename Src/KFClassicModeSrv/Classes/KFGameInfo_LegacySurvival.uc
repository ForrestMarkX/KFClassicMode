class KFGameInfo_LegacySurvival extends KFGameInfo_Survival;

var config bool bSavedGametypes;

`include(ClassicGameInfo.uci);

function PostBeginPlay()
{
    local sGameMode GameMode;
    
    Super.PostBeginPlay();
    
    if( !bSavedGametypes )
    {
        bSavedGametypes = true;
        
        GameMode.FriendlyName = "Legacy Survival";
        GameMode.ClassNameAndPath = "KFClassicModeSrv.KFGameInfo_LegacySurvival";
        GameMode.bSoloPlaySupported = True;
        GameMode.DifficultyLevels = 4;
        GameMode.Lengths = 4;
        GameMode.LocalizeID = 0;
        
        GameModes.AddItem(GameMode);
        SaveConfig();
    }
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	// if we're in the menu level, use the menu gametype
	if ( class'WorldInfo'.static.IsMenuLevel(MapName) )
	{
        return class<GameInfo>(DynamicLoadObject("KFClassicMenu.KFGameInfo_LegacyEntry", class'Class'));
	}

	return Default.class;
}

defaultproperties
{
}
