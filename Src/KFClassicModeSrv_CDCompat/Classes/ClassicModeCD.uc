class ClassicModeCD extends ClassicMode;

var config bool bSetupDefaults;

function SetupDefaultConfig()
{
    Super.SetupDefaultConfig();
    
    if( !bSetupDefaults )
    {
        RequirementScaling = class'ClassicMode'.default.RequirementScaling;
        ForcedMaxPlayers = class'ClassicMode'.default.ForcedMaxPlayers;
        StatAutoSaveWaves = class'ClassicMode'.default.StatAutoSaveWaves;
        MinPerkLevel = class'ClassicMode'.default.MinPerkLevel;
        MaxPerkLevel = class'ClassicMode'.default.MaxPerkLevel;
        Perks = class'ClassicMode'.default.Perks;
        CustomCharacters = class'ClassicMode'.default.CustomCharacters;
        TraderInventory = class'ClassicMode'.default.TraderInventory;
        PickupReplacments = class'ClassicMode'.default.PickupReplacments;
        
        bSetupDefaults = true;
        
        SaveConfig();
    }
}

function ModifySpawnManager()
{
	local CD_Survival CDGame;
	
	CDGame = CD_Survival(WorldInfo.Game);
	if( CDGame == None )
		return;
		
	KFGameInfo(WorldInfo.Game).SpawnManager = new(CDGame) class'KFAISpawnManager_ClassicCD';
	
	if( KFAISpawnManager_ClassicCD(CDGame.SpawnManager) != None )
		KFAISpawnManager_ClassicCD(CDGame.SpawnManager).ControllerMutator = self;
	
	CDGame.SpawnManager.Initialize();
}

defaultproperties
{
}