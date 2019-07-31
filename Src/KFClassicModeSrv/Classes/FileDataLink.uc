class FileDataLink extends DataLink;

function RetrieveAchievementState(const out UniqueNetId OwnerSteamId, out array<AchievementPack> Packs) 
{
    local array<byte> ObjectState;
    local string SteamIdString;
    local AchievementPack Ach;
    local LocalDataStore DataStore;

    SteamIdString = class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(OwnerSteamId);
    DataStore = new(None, SteamIdString) class'LocalDataStore';
    
    foreach Packs(Ach) 
    {
        ObjectState = DataStore.GetValue(Ach.AttrId());
        Ach.Deserialize(ObjectState);
    }
}

function SaveAchievementState(const out UniqueNetId OwnerSteamId, const out array<AchievementPack> Packs) 
{
    local array<byte> ObjectState;
    local string SteamIdString;
    local AchievementPack Ach;
    local LocalDataStore DataStore;

    SteamIdString = class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(OwnerSteamId);
    DataStore = new(None, SteamIdString) class'LocalDataStore';
    
    foreach Packs(Ach) 
    {
        Ach.Serialize(ObjectState);
        DataStore.SaveValue(Ach.AttrId(), ObjectState);
    }

    DataStore.SaveConfig();
}