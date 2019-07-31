class KFGameInfo_LegacyEndless extends KFGameInfo_Endless;

var config bool bSavedGametypes;

`include(ClassicGameInfo.uci);

function PostBeginPlay()
{
    local sGameMode GameMode;
    
    Super.PostBeginPlay();
    
    if( !bSavedGametypes )
    {
        bSavedGametypes = true;
        
        GameMode.FriendlyName = "Legacy Endless";
        GameMode.ClassNameAndPath = "KFClassicModeSrv.KFGameInfo_LegacyEndless";
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
