class HttpDataLink extends DataLink
    Config(ClassicMode);

var() config string HttpHostname;
var private array<AchievementPack> PendingPacks;

function RetrieveAchievementState(const out UniqueNetId OwnerSteamId, out array<AchievementPack> Packs) 
{
    local array<string> QueryParts;
    local string Query, SteamIdString;
    local AchievementPack Ach;
    local HttpRequestInterface HttpRequest;

    SteamIdString = class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(OwnerSteamId);
    foreach Packs(Ach) 
    {
        PendingPacks.AddItem(Ach);

        QueryParts.Length= 0;
        QueryParts.AddItem("action=get");
        QueryParts.AddItem("key=serverachievements/" $ SteamIdString $ "/" $ Ach.AttrId());

        JoinArray(QueryParts, Query, "&");

        HttpRequest = class'HttpFactory'.static.CreateRequest();
        HttpRequest.SetVerb("POST")
            .SetHeader("Content-Type", "application/x-www-form-urlencoded")
            .SetContentAsString(Query)
            .SetURL("http://" $ HttpHostname)
            .SetProcessRequestCompleteDelegate(retrieveRequestComplete)
            .ProcessRequest();
    }
}

function SaveAchievementState(const out UniqueNetId OwnerSteamId, const out array<AchievementPack> Packs) 
{
    local array<byte> ObjectState;
    local array<string> QueryParts;
    local string Query, SteamIdString;
    local AchievementPack Ach;
    local HttpRequestInterface HttpRequest;

    SteamIdString = class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(OwnerSteamId);
    foreach Packs(Ach) 
    {
        Ach.serialize(ObjectState);

        QueryParts.Length= 0;
        QueryParts.AddItem("action=save");
        QueryParts.AddItem("key=serverachievements/" $ steamIdString $ "/" $ Ach.AttrId());
        QueryParts.AddItem("value=" $ ByteArrayToHexString(ObjectState));

        JoinArray(QueryParts, Query, "&");

        HttpRequest = class'HttpFactory'.static.CreateRequest();
        HttpRequest.SetVerb("POST")
                .SetHeader("Content-Type", "application/x-www-form-urlencoded")
                .SetContentAsString(Query)
                .SetURL("http://" $ HttpHostname)
                .SetProcessRequestCompleteDelegate(SaveRequestComplete)
                .ProcessRequest();
    }
}

private function saveRequestComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface InHttpResponse, bool bDidSucceed) 
{
    if (!bDidSucceed) 
    {
        //<TODO Use FileDataLink to save data locally if server is unreacable
        `Warn("Error saving achievement to http server '" $ HttpHostname $ "'.  Response code= " $ InHttpResponse.GetResponseCode(), true, GetPackageName());
        `Warn(InHttpResponse.GetContentAsString(), true, GetPackageName());
    }
}

private function retrieveRequestComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface InHttpResponse, bool bDidSucceed) 
{
    local array<byte> ObjectState;

    if (bDidSucceed) 
    {
        HexStringToByteArray(InHttpResponse.GetContentAsString(), ObjectState);
        PendingPacks[0].Serialize(ObjectState);
    } 
    else 
    {
        ///<TODO Read data from local file if retrieve request fail
        `Warn("Error retriving achievement data from http server '" $ HttpHostname $ "'.  Response code= " $ InHttpResponse.GetResponseCode(), true, GetPackageName());
        `Warn(InHttpResponse.GetContentAsString(), true, GetPackageName());
    }
    
    PendingPacks.Remove(0, 1);
}
