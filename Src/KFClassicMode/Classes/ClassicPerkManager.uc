Class ClassicPerkManager extends ReplicationInfo;

const CUR_SaveVersion=2;

var int UserDataVersion;

var int ExpUpStatus[2];
var string StrPerkName;

var array<ClassicPerk_Base> UserPerks;

var ClassicPlayerReplicationInfo PRIOwner;
var ClassicPlayerController PlayerOwner;

var bool bStatsDirty,bServerReady,bUserStatsBroken,bCurrentlyHealing;
var int PerkCheckCount;

simulated function PostBeginPlay()
{
    SetTimer(1,false,'InitPerks');
}

function bool ApplyPerkClass( class<ClassicPerk_Base> P )
{
    local int i;
    
    for( i=0; i<UserPerks.Length; ++i )
    {
        if( UserPerks[i].Class==P )
        {
            ApplyPerk(UserPerks[i]);
            return true;
        }
    }
    
    return false;
}

function bool ApplyPerkName( string S )
{
    local int i;
    
    for( i=0; i<UserPerks.Length; ++i )
    {
        if( string(UserPerks[i].Class.Name)~=S )
        {
            ApplyPerk(UserPerks[i]);
            return true;
        }
    }
    
    return false;
}

function ApplyPerk( ClassicPerk_Base P )
{
    if( P == None )
        return;
        
    bStatsDirty = true;
    PlayerOwner.ChangePerks(P, true);
}

simulated final function ClassicPerk_Base FindPerk( class<KFPerk> P, optional bool bAllowSubclass )
{
    local ClassicPerk_Base Perk;
    
    ForEach UserPerks(Perk)
    {
        if( ( bAllowSubclass && ClassIsChildOf(Perk.Class, P) ) || Perk.Class == P )
        {
            return Perk;
        }
    }
    
    return None;
}

simulated function InitPerks()
{
    local ClassicPerk_Base P;
    
    if( WorldInfo.NetMode==NM_Client )
    {
        PlayerOwner = ClassicPlayerController(GetALocalPlayerController());
        
        foreach DynamicActors(class'ClassicPerk_Base',P)
        {
            if( P.PerkManager!=Self )
                RegisterPerk(P);
        }
    }
}

function ServerInitPerks()
{
    local int i, Index;
    
    for( i=0; i<UserPerks.Length; ++i )
    {
        UserPerks[i].SetInitialLevel();
        
        Index = PlayerOwner.GetPerkIndexFromClass(UserPerks[i].Class);
        PlayerOwner.SetPerkStaticLevel(Index, UserPerks[i].GetLevel());
        PlayerOwner.PerkList[Index].PerkLevel = UserPerks[i].GetLevel();
    }
        
    bServerReady = true;
    
    if( StrPerkName!="" )
        ApplyPerkName(StrPerkName);
        
    if( PlayerOwner.CurrentPerk==None )
        ApplyPerk(UserPerks[Rand(UserPerks.Length)]);
}

simulated function RegisterPerk( ClassicPerk_Base P )
{
    local PerkInfo PerkInfo;
    
    if( UserPerks.Find(P) != INDEX_NONE )
        return;
    
    UserPerks.AddItem(P);
    P.PerkManager = Self;
    
    PerkInfo.PerkClass = P.Class;
    PlayerOwner.PerkList.AddItem(PerkInfo);
}

simulated function UnregisterPerk( ClassicPerk_Base P )
{
    local int Index;
    
    UserPerks.RemoveItem(P);
    P.PerkManager = None;
    
    Index = PlayerOwner.PerkList.Find('PerkClass', P.Class);
    if( Index != INDEX_NONE )
    {
        PlayerOwner.PerkList.Remove(Index, 1);
    }
}

function Destroyed()
{
    local int i;
    
    for( i=(UserPerks.Length-1); i>=0; --i )
    {
        UserPerks[i].PerkManager = None;
        UserPerks[i].Destroy();
    }
}

function EarnedEXP( int EXP )
{
    local ClassicPerk_Base P;
    
    P = ClassicPerk_Base(PlayerOwner.CurrentPerk);
    if( P!=None )
    {
        if( EXP>0 && P.EarnedEXP(EXP) )
        {
            bStatsDirty = true;
        }
    }
}

// Data saving.
function SaveData( KFSaveDataBase Data )
{
    local int i,o;

    Data.FlushData();
    Data.SetSaveVersion(++UserDataVersion);
    Data.SetArVer(CUR_SaveVersion);
    
    // Write character.
    if( PRIOwner!=None )
        PRIOwner.SaveCustomCharacter(Data);
    else class'ClassicPlayerReplicationInfo'.Static.DummySaveChar(Data);

    // Write selected perk.
    Data.SaveStr(PlayerOwner.CurrentPerk!=None ? string(PlayerOwner.CurrentPerk.Class.Name) : "");

    // Count how many progressed perks we have.
    o = 0;
    for( i=0; i<UserPerks.Length; ++i )
    {
        if( UserPerks[i].HasAnyProgress() )
        {
            ++o;
        }
    }
    
    // Then write count we have.
    Data.SaveInt(o);
    
    // Then perk stats.
    for( i=0; i<UserPerks.Length; ++i )
    {
        if( !UserPerks[i].HasAnyProgress() ) // Skip this perk.
            continue;

        Data.SaveStr(string(UserPerks[i].Class.Name));
        o = Data.TellOffset(); // Mark checkpoint.
        Data.SaveInt(0,1); // Reserve space for later.
        UserPerks[i].SaveData(Data);

        // Now save the skip offset for perk data incase perk gets removed from server.
        Data.SeekOffset(o);
        Data.SaveInt(Data.TotalSize(),1);
        Data.ToEnd();
    }
}

// Data loading.
function LoadData( KFSaveDataBase Data )
{
    local int i,j,l,o;
    local string S;

    Data.ToStart();
    UserDataVersion = Data.GetSaveVersion();
    
    // Read character.
    if( PRIOwner!=None )
    {
        PRIOwner.LoadCustomCharacter(Data);
    }
    else class'ClassicPlayerReplicationInfo'.Static.DummyLoadChar(Data);

    // Find selected perk.
    StrPerkName = Data.ReadStr();

    l = Data.ReadInt(); // Perk stats length.
    for( i=0; i<l; ++i )
    {
        S = Data.ReadStr();
        o = Data.ReadInt(1); // Read skip offset.
        Data.PushEOFLimit(o);
        for( j=0; j<UserPerks.Length; ++j )
        {
            if( S~=string(UserPerks[j].Class.Name) )
            {
                UserPerks[j].LoadData(Data);
                break;
            }
        }
        Data.PopEOFLimit();
        Data.SeekOffset(o); // Jump to end of this section.
    }
    bStatsDirty = false;
}

defaultproperties
{
    NetPriority=3.5
    NetUpdateFrequency=1.0
    
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
}