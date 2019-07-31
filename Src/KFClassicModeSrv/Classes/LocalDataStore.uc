class LocalDataStore extends Object
    PerObjectConfig
    Config(ClassicAchievementsDataStore);

struct Entry 
{
    var config string Key;
    var config array<byte> Value;
};
var config array<Entry> PlayerData;

function array<byte> GetValue(string Key) 
{
    local array<byte> Empty;
    local int i;

    Empty.Length= 0;
    for( i= 0; i<PlayerData.Length; i++ ) 
    {
        if( PlayerData[i].Key == Key ) 
        {
            return PlayerData[i].Value;
        }
    }

    return Empty;
}

function SaveValue(string Key, const out array<byte> Value) 
{
    local Entry NewEntry;
    local int i;

    if( Value.Length > 0 ) 
    {
        for( i= 0; i < PlayerData.Length; i++ ) 
        {
            if( PlayerData[i].Key == Key ) 
            {
                PlayerData[i].Value= Value;
                return;
            }
        }

        NewEntry.Key = Key;
        NewEntry.Value = Value;
        
        PlayerData.AddItem(NewEntry);
    }
}