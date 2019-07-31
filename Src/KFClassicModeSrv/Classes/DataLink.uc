/**
 * Abstract class providing a link to a data container
 */
class DataLink extends Object
    abstract;

/**
 * Retrieve serialized data from disk and restore achieveemnt state
 * @param ownerSteamId          SteamID of the player owning the achievement packs
 * @param packs                 Achievement packs to deserialize
 */
function RetrieveAchievementState(const out UniqueNetId OwnerSteamId, out array<AchievementPack> Packs);

/**
 * Serialize and save the the achievement state to disk
 * @param ownerSteamId          SteamID of the player owning the achievement packs
 * @param packs                 Achievement packs to save to disk
 */
function SaveAchievementState(const out UniqueNetId OwnerSteamId, const out array<AchievementPack> Packs);

static function string ByteArrayToHexString(const out array<byte> ByteArray) 
{
    local byte it, LowBits, HighBits;
    local string Result;

    foreach ByteArray(it) 
    {
        LowBits = it & 0xf;
        HighBits = (it >> 4) & 0xf;

        Result $= (Chr(HighBits + (HighBits < 10 ? 48 : 55)) $ Chr(LowBits + (LowBits < 10 ? 48 : 55)));
    }

    return Result;
}

static function HexStringToByteArray(string StringValue, out array<byte> ByteArray) 
{
    local string Next;

    while(Len(StringValue) != 0) 
    {
        Next = Left(StringValue, 2);
        ByteArray.AddItem(hexCharToInt(Right(Next, 1)) | (hexCharToInt(Left(Next, 1)) << 4));
        StringValue = Mid(StringValue, 2);
    }
}

static function int HexCharToInt(string HexChar) 
{
    if (HexChar >= "a" && HexChar <= "f") 
    {
        return Asc(HexChar) - 87;
    } 
    else if (HexChar >= "A" && HexChar <= "F") 
    {
        return Asc(HexChar) - 55;
    } 
    else if (HexChar >= "0" && HexChar <= "9") 
    {
        return Asc(HexChar) - 48;
    }
}