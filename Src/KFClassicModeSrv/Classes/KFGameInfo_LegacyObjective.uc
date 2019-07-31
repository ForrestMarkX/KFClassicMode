class KFGameInfo_LegacyObjective extends KFGameInfo_Objective;

var config bool bSavedGametypes;

`include(ClassicGameInfo.uci);

function PostBeginPlay()
{
    local sGameMode GameMode;
    
    Super.PostBeginPlay();
    
    if( !bSavedGametypes )
    {
        bSavedGametypes = true;
        
        GameMode.FriendlyName = "Legacy Objective";
        GameMode.ClassNameAndPath = "KFClassicModeSrv.KFGameInfo_LegacyObjective";
        GameMode.bSoloPlaySupported = True;
        GameMode.DifficultyLevels = 4;
        GameMode.Lengths = 4;
        GameMode.LocalizeID = 0;
        
        GameModes.AddItem(GameMode);
        SaveConfig();
    }
}

defaultproperties
{
}
