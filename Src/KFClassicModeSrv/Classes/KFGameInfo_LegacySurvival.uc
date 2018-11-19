class KFGameInfo_LegacySurvival extends KFGameInfo_Survival;

var config bool bSavedGametypes;

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

function int GetLivingPlayerCount()
{
    local KFPlayerController P;
    local int UsedLivingHumanPlayersCount;
 
    foreach WorldInfo.AllControllers(class'KFPlayerController', P)
    {
        if( P != None && P.Pawn != None && P.Pawn.IsAliveAndWell() )
        {
            UsedLivingHumanPlayersCount++;
        }
    }
 
    return UsedLivingHumanPlayersCount;
}

// Objective maps break when using a gameinfo that isn't the default
function bool IsMapObjectiveEnabled()
{
	return false;
}

defaultproperties
{
}
