Class ClassicMode extends KFMutator
    DependsOn(ZEDReplacmentInfo)
    config(ClassicMode);
    
`include(KFClassicMode\Globals.uci);

struct AIReplacementS
{
    var class<KFPawn_Monster>   Original, Replacment;
    var bool                    bCheckChildren;
    var float                   iReplacmentChance;
    
    structdefaultproperties
    {
        iReplacmentChance=1.f
        bCheckChildren=false
    }
};

struct TraderReplacements
{
    var string Original, Replacement;
};

struct PickupReplacmentStruct
{
    var class<KFWeapon> OriginalClass, ReplacmentClass;
};

struct MapTypeInfo
{
    var string Name, Type;
    var int          MaxMonsters;
    
    structdefaultproperties
    {
        Type="None"
        MaxMonsters=32
    }
};

var array<AIReplacementS>                   AIClassList;
var array<AIReplacementS>                   LoadedAIList;
var array<string>                           ZedNames;
var ZEDReplacmentInfo                       LoadedTable;

var array< class<ClassicPerk_Base> >        LoadedPerks;

var array<PickupReplacmentStruct>           LoadedWeaponReplacements;    
var array<PickupReplacmentStruct>           DefaultWeaponReplacements;    

var bool                                    bGameHasEnded, bCheckedWave;
var int                                     LastWaveNum, NumWaveSwitches;

var ClassicPlayerStat                       ServerStatLoader;
    
var array<Object>                           ExternalObjs;

var transient KFMapInfo                     KFMI;

var array<FCustomTraderItem>                CustomItemList;
var KFGFxObject_TraderItems                 CustomTrader;

var array<FCustomCharEntry>                 CustomCharacterList;

var KFEventHelper                           EventHelper;

var array<FWebAdminConfigInfo>              WebConfigs;   

var class<MusicGRI>                         MusicReplicationInfoClass;
var MusicGRI                                MusicReplicationInfo; 

var KFPawn                                  LastHitZed;
var int                                     LastHitHP;
var ClassicPlayerController                 LastDamageDealer;
var vector                                  LastDamagePosition;
var class<KFDamageType>                     LastDamageDMGType;

var config float                            RequirementScaling, SpectatorRefireRate, SpectatorZapDamage, SpectatorHealAmount;
var config int                              ForcedMaxPlayers, StatAutoSaveWaves;
var config byte                             MinPerkLevel, MaxPerkLevel;
var config array<string>                    Perks, CustomCharacters;
var globalconfig byte                       GlobalMaxMonsters;
var globalconfig bool                       bBroadcastPickups, bDisableMusic, bDisableGameplayChanges, bDisableGunslinger, bDisableSWAT, bNoEDARs, bNoGasCrawler, bNoRioter, bNoGorefiends, bEnableTraderSpeed, bEnableCloseToTraderSpawns, bDisableUpgradeSystem, bEnabledVisibleSpectators;
var globalconfig array<MapTypeInfo>         MapTypes;
var globalconfig name                       GlobalEventName;
var globalconfig string                     ServerMOTD;
var config array<string>                    TraderInventory;
var config array<TraderReplacements>        TraderWeaponReplacments;
var config array<PickupReplacmentStruct>    PickupReplacments;
var globalconfig string                     ZEDReplacmentTable;
var config int                              iVersionNumber;

function AddMutator(Mutator M)
{
    if( M!=Self ) // Make sure we don't get added twice.
    {
        if( M.Class==Class )
            M.Destroy();
        else Super.AddMutator(M);
    }
}

function PostBeginPlay()
{
    local FCustomTraderItem         CI;
    local class<ClassicPerk_Base>   LoadedPerk;
    local string                    S, MyPerk, Item, Character;
    local xVotingHandler            MV;
    local KFGameInfo                KFGI;
    local KFCharacterInfo_Human     CH;
    local ObjectReferencer          OR;
    local Object                    O;
    local int                       i,j,Index;
    local bool                      bLock;
    
    Super.PostBeginPlay();
    
    if( bDeleteMe ) // This was a duplicate instance of the mutator.
        return;
        
    KFGI = KFGameInfo(WorldInfo.Game);
    if( KFGI != None )
    {
        if( Class.Name == 'ClassicMode' && KFGI.IsA('CD_Survival') )
        {
            KFGI.AddMutator("KFClassicModeSrv_CDCompat.ClassicModeCD", true);
            Destroy();
            return;
        }
    }
        
    SetupDefaultConfig();
    
    // Do not brew your custom mod of this package doing so will cause all package names to be downloaded with all lowercase.
    // Instead call the function below with any asset from the package you wish to be downloaded.
    AddLoadPackage(ObjectReferencer'KFClassicMode_Assets.ObjectRef.MainObj_List');
    AddLoadPackage(class'KFClassicMode.ClientPerkRepLink');
    AddLoadPackage(SoundCue'KFClassicMusic.RandomWaveMusic');
    
    ServerStatLoader = new (None) class'ClassicPlayerStat';
    
    WorldInfo.Game.HUDType = class'KFHUDInterface';
    WorldInfo.Game.DefaultPawnClass = class'ClassicHumanPawn';
    WorldInfo.Game.PlayerControllerClass = class'ClassicPlayerController';
    WorldInfo.Game.PlayerReplicationInfoClass = class'ClassicPlayerReplicationInfo';
    
    if( KFGI != None )
    {
        if( !bDisableGameplayChanges )
        {
            KFGI.GameConductorClass = class'ClassicGameConductor';
            KFGI.bDisableTeamCollision = false;
        }
        
        KFGI.DialogManagerClass = class'ClassicDialogManager';
        KFGI.KFGFxManagerClass = class'ClassicMoviePlayer_Manager';
        KFGI.CustomizationPawnClass = class'ClassicPawn_Customization';
    }
    
    WorldInfo.Spawn(class'ClientPerkRepLink', self);
    
    EventHelper = WorldInfo.Spawn(class'KFEventHelper', self);
    KFMI = KFMapInfo(WorldInfo.GetMapInfo());
    
    if( MinPerkLevel > MaxPerkLevel )
    {
        MinPerkLevel = MaxPerkLevel;
    }
    
    SetTimer(1, true, 'CheckWave');
    SetTimer(0.1, false, 'SetupClassicSystems');
    if( !bDisableGameplayChanges )
    {
        SetTimer(1, true, 'CheckC4'); 
    }
    
    if( ServerMOTD=="" )
    {
        ServerMOTD = "Message of the Day";
    }
    
    foreach TraderInventory(Item)
    {
        if( bDisableGameplayChanges )
        {
            Item = Repl(Item, "KFClassicMode.Classic", "KFGame.KF");
        }
        
        Index = TraderWeaponReplacments.Find('Original', Item);
        if( Index != INDEX_NONE )
            Item = TraderWeaponReplacments[Index].Replacement;
        
        CI.WeaponDef = class<KFWeaponDefinition>(DynamicLoadObject(Item,class'Class'));
        if( CI.WeaponDef==None )
            continue;
        CI.WeaponClass = class<KFWeapon>(DynamicLoadObject(CI.WeaponDef.default.WeaponClassPath,class'Class'));
        if( CI.WeaponClass==None )
            continue;
        
        CustomItemList.AddItem(CI);

        if( CustomTrader==None )
        {
            CustomTrader = class'ClassicPlayerReplicationInfo'.static.CreateNewList();
            SetTimer(0.1,false,'InitGRIList');
        }
        class'ClassicPlayerReplicationInfo'.static.SetWeaponInfo(WorldInfo.NetMode==NM_DedicatedServer,CustomTrader.SaleItems.Length,CI,CustomTrader);
    }
    
    foreach Perks(MyPerk)
    {
        if( bDisableGameplayChanges )
        {
            switch(MyPerk)
            {
                case "KFClassicMode.ClassicPerk_Berserker":
                    MyPerk = "KFClassicMode.ClassicPerk_Berserker_Default";
                    break;
                case "KFClassicMode.ClassicPerk_Commando":
                    MyPerk = "KFClassicMode.ClassicPerk_Commando_Default";
                    break;
                case "KFClassicMode.ClassicPerk_Support":
                    MyPerk = "KFClassicMode.ClassicPerk_Support_Default";
                    break;            
                case "KFClassicMode.ClassicPerk_Medic":
                    MyPerk = "KFClassicMode.ClassicPerk_Medic_Default";
                    break;            
                case "KFClassicMode.ClassicPerk_Demolitionist":
                    MyPerk = "KFClassicMode.ClassicPerk_Demolitionist_Default";
                    break;
                case "KFClassicMode.ClassicPerk_Firebug":
                    MyPerk = "KFClassicMode.ClassicPerk_Firebug_Default";
                    break;
                case "KFClassicMode.ClassicPerk_Sharpshooter":
                    MyPerk = "KFClassicMode.ClassicPerk_Sharpshooter_Default";
                    break;
            }
        }
    
        LoadedPerk = class<ClassicPerk_Base>(DynamicLoadObject(MyPerk,class'Class'));
        if( LoadedPerk != None )
        {
            LoadedPerks.AddItem(LoadedPerk);
        }
    }
    
    j = 0;
    foreach CustomCharacters(Character)
    {
        bLock = Left(Character,1)=="*";
        S = (bLock ? Mid(Character,1) : Character);
        CH = KFCharacterInfo_Human(DynamicLoadObject(S,class'KFCharacterInfo_Human',true));
        if( CH!=None )
        {
            CustomCharacterList.Length = j+1;
            CustomCharacterList[j].bLock = bLock;
            CustomCharacterList[j].Char = CH;
            ++j;
            continue;
        }

        OR = ObjectReferencer(DynamicLoadObject(S,class'ObjectReferencer'));
        if( OR!=None )
        {
            foreach OR.ReferencedObjects(O)
            {
                if( KFCharacterInfo_Human(O)!=None )
                {
                    CustomCharacterList.Length = j+1;
                    CustomCharacterList[j].bLock = bLock;
                    CustomCharacterList[j].Char = KFCharacterInfo_Human(O);
                    CustomCharacterList[j].Ref = OR;
                    ++j;
                }
            }
        }
    }
    
    if( ForcedMaxPlayers>0 )
    {
        SetMaxPlayers();
        SetTimer(0.001,false,'SetMaxPlayers');
    }
    
    foreach DynamicActors(class'KFClassicModeSrv.xVotingHandler',MV)
        break;
    if( MV==None )
        MV = Spawn(class'KFClassicModeSrv.xVotingHandler');
    MV.BaseMutator = Class;
    
    if( bDisableGameplayChanges )
    {
        AIClassList[0].Replacment = class'KFClassicMode.ClassicPawn_ZedClot_Cyst_Default';
        AIClassList[1].Replacment = class'KFClassicMode.ClassicPawn_ZedClot_Alpha_Default';
        AIClassList[2].Replacment = class'KFClassicMode.ClassicPawn_ZedClot_AlphaKing_Default';
        AIClassList[3].Replacment = class'KFClassicMode.ClassicPawn_ZedClot_Slasher_Default';
        AIClassList[4].Replacment = class'KFClassicMode.ClassicPawn_ZedCrawler_Default';
        AIClassList[5].Replacment = class'KFClassicMode.ClassicPawn_ZedGorefast_Default';
        AIClassList[6].Replacment = class'KFClassicMode.ClassicPawn_ZedStalker_Default';
        AIClassList[7].Replacment = class'KFClassicMode.ClassicPawn_ZedScrake_Default';
        AIClassList[8].Replacment = class'KFClassicMode.ClassicPawn_ZedFleshpound_Default';
        AIClassList[9].Replacment = class'KFClassicMode.ClassicPawn_ZedFleshpoundMini_Default';
        AIClassList[10].Replacment = class'KFClassicMode.ClassicPawn_ZedBloat_Default';
        AIClassList[11].Replacment = class'KFClassicMode.ClassicPawn_ZedSiren_Default';
        AIClassList[12].Replacment = class'KFClassicMode.ClassicPawn_ZedHusk_Default';
        AIClassList[13].Replacment = class'KFClassicMode.ClassicPawn_ZedPatriarch_Default';
        AIClassList[14].Replacment = class'KFClassicMode.ClassicPawn_ZedHans_Default';
        AIClassList[15].Replacment = class'KFClassicMode.ClassicPawn_ZedBloatKing_Default';
        AIClassList[16].Replacment = class'KFClassicMode.ClassicPawn_ZedFleshpoundKing_Default';
        AIClassList[17].Replacment = class'KFClassicMode.ClassicPawn_ZedMatriarch_Default';
    }
    
    for(i=0; i<PickupReplacments.Length; i++)
    {
        if( bDisableGameplayChanges )
        {
            Index = DefaultWeaponReplacements.Find('ReplacmentClass', PickupReplacments[i].ReplacmentClass);
            if( Index == INDEX_NONE )
                LoadedWeaponReplacements.AddItem(PickupReplacments[i]);
        }
        else LoadedWeaponReplacements.AddItem(PickupReplacments[i]);
    }
}

function InitMutator(string Options, out string ErrorMessage)
{
    local int i, j;
    local KFDifficulty_Husk HuskDif;
    local KFDifficulty_Stalker StalkerDif;
    local KFDifficulty_Crawler CrawlerDif;
    local KFDifficulty_ClotAlpha AlphaDif;
    local KFDifficulty_Gorefast GorefastDif;
    
    Super.InitMutator( Options, ErrorMessage );

    SetTimer(0.1, false, nameOf(SetDifficultyInfo));
    
    if( !bDisableGameplayChanges )
    {
        MyKFGI.MaxRespawnDosh[0] = 1000.f;
        MyKFGI.MaxRespawnDosh[1] = 950.f;
        MyKFGI.MaxRespawnDosh[2] = 1550.f;
        MyKFGI.MaxRespawnDosh[3] = 1000.f;
        
        for( i=0; i<MyKFGI.LateArrivalStarts.Length; i++ )
        {
            for( j=0; j<MyKFGI.LateArrivalStarts[i].StartingDosh.Length; j++ )
            {
                MyKFGI.LateArrivalStarts[i].StartingDosh[j] *= 0.75;
            }
        }
        
        if( MyKFGI.GameConductor != None )
        {
            MyKFGI.GameConductor.bBypassGameConductor = true;
        }
    }

    if( WorldInfo.NetMode != NM_StandAlone )
    {
        SetTimer(0.1,false,'SpawnTeamChatProxies');
        SetTimer(0.125,false,'SetupWebAdmin');
    }
    
    if( !bDisableMusic )
    {
        MusicReplicationInfo = MusicReplicationInfoClass.static.FindMusicGRI(WorldInfo);
    }
    
    if( Len(ZEDReplacmentTable) != 0 && ZEDReplacmentTable != "ExampleProfile" )
    {
        LoadInfoObject(ZEDReplacmentTable);
    }
    
    if( bNoEDARs )
    {
        HuskDif = KFDifficulty_Husk(FindObject("KFGameContent.Default__KFDifficulty_Husk",class'KFDifficulty_Husk'));
        HuskDif.ChanceToSpawnAsSpecial.Length = 0;        
        
        StalkerDif = KFDifficulty_Stalker(FindObject("KFGameContent.Default__KFDifficulty_Stalker",class'KFDifficulty_Stalker'));
        StalkerDif.ChanceToSpawnAsSpecial.Length = 0;
    }
    
    if( bNoGasCrawler )
    {
        CrawlerDif = KFDifficulty_Crawler(FindObject("KFGameContent.Default__KFDifficulty_Crawler",class'KFDifficulty_Crawler'));
        CrawlerDif.ChanceToSpawnAsSpecial.Length = 0;
    }
    
    if( bNoRioter )
    {
        AlphaDif = KFDifficulty_ClotAlpha(FindObject("KFGameContent.Default__KFDifficulty_ClotAlpha",class'KFDifficulty_ClotAlpha'));
        AlphaDif.ChanceToSpawnAsSpecial.Length = 0;
    }
    
    if( bNoGorefiends )
    {
        GorefastDif = KFDifficulty_Gorefast(FindObject("KFGameContent.Default__KFDifficulty_Gorefast",class'KFDifficulty_Gorefast'));
        GorefastDif.ChanceToSpawnAsSpecial.Length = 0;
    }
}

function SetupDefaultConfig()
{
    local array<STraderItem>        SaleItems;
    local class<KFWeaponDefinition> WepDef;
    local string                    DefPath;
    local STraderItem               TraderItem;
    local array<string>             DefaultInventory;
    local MapTypeInfo               MapInfo;
    local ZEDReplacmentInfo         DefaultProfile;
    local AIReplacement             ReplacementInfo;
    
    if( iVersionNumber <= 0 )
    {
        SaleItems = KFGFxObject_TraderItems(DynamicLoadObject(class'KFGameReplicationInfo'.default.TraderItemsPath, class'KFGFxObject_TraderItems')).SaleItems;
        foreach SaleItems(TraderItem)
        {
            WepDef = TraderItem.WeaponDef;
            DefPath = PathName(WepDef);
            
            switch(WepDef.Name)
            {
                // OFF-PERK
                case 'KFWeapDef_9mm':
                    DefPath = "KFClassicMode.ClassicWeapDef_9mm";
                    break;
                case 'KFWeapDef_9mmDual':
                    DefPath = "KFClassicMode.ClassicWeapDef_9mmDual";
                    break;
                // BERSERKER
                case 'KFWeapDef_Crovel':
                    DefPath = "KFClassicMode.ClassicWeapDef_Crovel";
                    break;
                case 'KFWeapDef_Katana':
                    DefPath = "KFClassicMode.ClassicWeapDef_Katana";
                    break;
                case 'KFWeapDef_Zweihander':
                    DefPath = "KFClassicMode.ClassicWeapDef_Zweihander";
                    break;               
                case 'KFWeapDef_FireAxe':
                    DefPath = "KFClassicMode.ClassicWeapDef_FireAxe";
                    break;                
                case 'KFWeapDef_AbominationAxe':
                    DefPath = "KFClassicMode.ClassicWeapDef_AbominationAxe";
                    break;
                // COMMANDO
                case 'KFWeapDef_Bullpup':
                    DefPath = "KFClassicMode.ClassicWeapDef_Bullpup";
                    break;
                case 'KFWeapDef_P90':
                    DefPath = "KFClassicMode.ClassicWeapDef_P90";
                    break;
                case 'KFWeapDef_AK12':
                    DefPath = "KFClassicMode.ClassicWeapDef_AK12";
                    break;
                case 'KFWeapDef_HK_UMP':
                    DefPath = "KFClassicMode.ClassicWeapDef_HK_UMP";
                    break;
                case 'KFWeapDef_SCAR':
                    DefPath = "KFClassicMode.ClassicWeapDef_SCAR";
                    break;
                case 'KFWeapDef_Stoner63A':
                    DefPath = "KFClassicMode.ClassicWeapDef_Stoner63A";
                    break;          
                case 'KFWeapDef_Thompson':
                    DefPath = "KFClassicMode.ClassicWeapDef_Thompson";
                    break;                                  
                // SUPPORT
                case 'KFWeapDef_MB500':
                    DefPath = "KFClassicMode.ClassicWeapDef_MB500";
                    break;
                case 'KFWeapDef_DoubleBarrel':
                    DefPath = "KFClassicMode.ClassicWeapDef_DoubleBarrel";
                    break;
                case 'KFWeapDef_M4':
                    DefPath = "KFClassicMode.ClassicWeapDef_M4";
                    break;
                case 'KFWeapDef_HZ12':
                    DefPath = "KFClassicMode.ClassicWeapDef_HZ12";
                    break;
                case 'KFWeapDef_Nailgun':
                    DefPath = "KFClassicMode.ClassicWeapDef_NailGun";
                    break;
                case 'KFWeapDef_ElephantGun':
                    DefPath = "KFClassicMode.ClassicWeapDef_ElephantGun";
                    break;
                case 'KFWeapDef_AA12':
                    DefPath = "KFClassicMode.ClassicWeapDef_AA12";
                    break;
                // MEDIC
                case 'KFWeapDef_MedicPistol':
                    DefPath = "KFClassicMode.ClassicWeapDef_MedicPistol";
                    break;
                case 'KFWeapDef_MedicSMG':
                    DefPath = "KFClassicMode.ClassicWeapDef_MedicSMG";
                    break;                
                case 'KFWeapDef_MedicShotgun':
                    DefPath = "KFClassicMode.ClassicWeapDef_MedicShotgun";
                    break;
                case 'KFWeapDef_MedicRifle':
                    DefPath = "KFClassicMode.ClassicWeapDef_MedicRifle";
                    break;
                case 'KFWeapDef_MP7':
                    DefPath = "KFClassicMode.ClassicWeapDef_MP7";
                    break;
                case 'KFWeapDef_MP5RAS':
                    DefPath = "KFClassicMode.ClassicWeapDef_MP5RAS";
                    break;
                case 'KFWeapDef_Kriss':
                    DefPath = "KFClassicMode.ClassicWeapDef_Kriss";
                    break;
                // DEMOLITIONIST
                case 'KFWeapDef_HX25':
                    DefPath = "KFClassicMode.ClassicWeapDef_HX25";
                    break;
                case 'KFWeapDef_C4':
                    DefPath = "KFClassicMode.ClassicWeapDef_C4";
                    break;
                case 'KFWeapDef_M79':
                    DefPath = "KFClassicMode.ClassicWeapDef_M79";
                    break;
                case 'KFWeapDef_Seeker6':
                    DefPath = "KFClassicMode.ClassicWeapDef_Seeker6";
                    break;
                case 'KFWeapDef_M16M203':
                    DefPath = "KFClassicMode.ClassicWeapDef_M16M203";
                    break;
                case 'KFWeapDef_RPG7':
                    DefPath = "KFClassicMode.ClassicWeapDef_RPG7";
                    break;
                case 'KFWeapDef_M32':
                    DefPath = "KFClassicMode.ClassicWeapDef_M32";
                    break;
                // FIREBUG
                case 'KFWeapDef_FlareGun':
                    DefPath = "KFClassicMode.ClassicWeapDef_FlareGun";
                    break;
                case 'KFWeapDef_FlareGunDual':
                    DefPath = "KFClassicMode.ClassicWeapDef_FlareGunDual";
                    break;
                case 'KFWeapDef_Mac10':
                    DefPath = "KFClassicMode.ClassicWeapDef_Mac10";
                    break;
                case 'KFWeapDef_FlameThrower':
                    DefPath = "KFClassicMode.ClassicWeapDef_FlameThrower";
                    break;
                case 'KFWeapDef_DragonsBreath':
                    DefPath = "KFClassicMode.ClassicWeapDef_DragonsBreath";
                    break;
                case 'KFWeapDef_HuskCannon':
                    DefPath = "KFClassicMode.ClassicWeapDef_HuskCannon";
                    break;
                // SHARPSHOOTER
                case 'KFWeapDef_Colt1911':
                    DefPath = "KFClassicMode.ClassicWeapDef_Colt1911";
                    break;
                case 'KFWeapDef_Colt1911Dual':
                    DefPath = "KFClassicMode.ClassicWeapDef_Colt1911Dual";
                    break;
                case 'KFWeapDef_SW500':
                    DefPath = "KFClassicMode.ClassicWeapDef_SW500";
                    break;
                case 'KFWeapDef_SW500Dual':
                    DefPath = "KFClassicMode.ClassicWeapDef_SW500Dual";
                    break;
                case 'KFWeapDef_Deagle':
                    DefPath = "KFClassicMode.ClassicWeapDef_Deagle";
                    break;
                case 'KFWeapDef_DeagleDual':
                    DefPath = "KFClassicMode.ClassicWeapDef_DeagleDual";
                    break;
                case 'KFWeapDef_Winchester1894':
                    DefPath = "KFClassicMode.ClassicWeapDef_Winchester1894";
                    break;
                case 'KFWeapDef_Crossbow':
                    DefPath = "KFClassicMode.ClassicWeapDef_Crossbow";
                    break;
                case 'KFWeapDef_CenterfireMB464':
                    DefPath = "KFClassicMode.ClassicWeapDef_CenterfireMB464";
                    break;
                case 'KFWeapDef_M14EBR':
                    DefPath = "KFClassicMode.ClassicWeapDef_M14EBR";
                    break;
                case 'KFWeapDef_M99':
                    DefPath = "KFClassicMode.ClassicWeapDef_M99";
                    break;
            }
            
            DefaultInventory.AddItem(DefPath);
        }
        
        Perks.AddItem("KFClassicMode.ClassicPerk_Berserker");
        Perks.AddItem("KFClassicMode.ClassicPerk_Commando");
        Perks.AddItem("KFClassicMode.ClassicPerk_Support");
        Perks.AddItem("KFClassicMode.ClassicPerk_Medic");
        Perks.AddItem("KFClassicMode.ClassicPerk_Demolitionist");
        Perks.AddItem("KFClassicMode.ClassicPerk_Firebug");
        Perks.AddItem("KFClassicMode.ClassicPerk_Sharpshooter");
        
        MapInfo.Name = "KF-KrampusLair";
        MapInfo.Type = "XMas";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        MapInfo.Name = "KF-TragicKingdom";
        MapInfo.Type = "Summer";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        MapInfo.Name = "KF-Airship";
        MapInfo.Type = "Summer";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        GlobalEventName = 'Default';
        ForcedMaxPlayers = 6;
        StatAutoSaveWaves = 1;
        RequirementScaling = 1.f;
        MaxPerkLevel = 6;
        MinPerkLevel = 0;
        GlobalMaxMonsters = 32;
        TraderInventory = DefaultInventory;
        bBroadcastPickups = true;
            
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 1 )
    {
        PickupReplacments = DefaultWeaponReplacements;
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 2 )
    {
        bDisableMusic = false;
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 3 )
    {
        TraderInventory.RemoveItem("KFGame.KFWeapDef_MKB42");
        TraderInventory.RemoveItem("KFGame.KFWeapDef_FNFal");
        TraderInventory.RemoveItem("KFGame.KFWeapDef_MedicRifleGrenadeLauncher");
        
        if( TraderInventory.Find("KFClassicMode.ClassicWeapDef_MKB42") == INDEX_NONE )
            TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_MKB42");
        if( TraderInventory.Find("KFClassicMode.ClassicWeapDef_FNFal") == INDEX_NONE )
            TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_FNFal");
        if( TraderInventory.Find("KFClassicMode.ClassicWeapDef_MedicRifleGrenadeLauncher") == INDEX_NONE )
            TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_MedicRifleGrenadeLauncher");
    
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 4 )
    {
        TraderInventory.RemoveItem("KFGame.KFWeapDef_Thompson");
        TraderInventory.RemoveItem("KFGame.KFWeapDef_M32");
        TraderInventory.RemoveItem("KFGame.KFWeapDef_FireAxe");
        TraderInventory.RemoveItem("KFGame.KFWeapDef_AbominationAxe");
        
        if( TraderInventory.Find("KFClassicMode.ClassicWeapDef_Thompson") == INDEX_NONE )
            TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_Thompson");
        if( TraderInventory.Find("KFClassicMode.ClassicWeapDef_M32") == INDEX_NONE )
            TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_M32");
        if( TraderInventory.Find("KFClassicMode.ClassicWeapDef_FireAxe") == INDEX_NONE )
            TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_FireAxe");
        if( TraderInventory.Find("KFClassicMode.ClassicWeapDef_AbominationAxe") == INDEX_NONE )
            TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_AbominationAxe");
    
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 5 )
    {
        if( TraderInventory.Find("KFGame.KFWeapDef_LazerCutter") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_LazerCutter");
        if( TraderInventory.Find("KFGame.KFWeapDef_MicrowaveRifle") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_MicrowaveRifle");
        if( TraderInventory.Find("KFGame.KFWeapDef_MedicBat") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_MedicBat");        
        if( TraderInventory.Find("KFGame.KFWeapDef_SealSqueal") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_SealSqueal");
            
        MapInfo.Name = "KF-SantasWorkshop";
        MapInfo.Type = "XMas";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        MapInfo.Name = "KF-SteamFortress";
        MapInfo.Type = "Summer";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        MapInfo.Name = "KF-MonsterBall";
        MapInfo.Type = "Halloween";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        DefaultProfile = New(None, "ExampleProfile") class'ZEDReplacmentInfo';
            ReplacementInfo.Original = "Cyst";
            ReplacementInfo.Replacment = "KFClassicMode.ClassicPawn_ZedCrawler";
            ReplacementInfo.bCheckChildren = true;
            ReplacementInfo.ReplacmentChance = 0.45f;
        DefaultProfile.AIReplacments.AddItem(ReplacementInfo);
        DefaultProfile.SaveConfig();
        
        ZEDReplacmentTable = "ExampleProfile";
        bDisableGameplayChanges = false;
        
        bNoEDARs = false;
        bNoGasCrawler = false;
        bNoRioter = false;
        bNoGorefiends = false;
        
        bEnableTraderSpeed = false;
        bEnableCloseToTraderSpawns = false;
        bDisableUpgradeSystem = false;
        
        bEnabledVisibleSpectators = true;
        SpectatorRefireRate = 1.f;
        SpectatorZapDamage = 25.f;
        SpectatorHealAmount = 3.f;
    
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 6 )
    {
        if( TraderInventory.Find("KFGame.KFWeapDef_NailGun_HRG") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_NailGun_HRG");
        if( TraderInventory.Find("KFGame.KFWeapDef_SW500_HRG") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_SW500_HRG");
        if( TraderInventory.Find("KFGame.KFWeapDef_SW500Dual_HRG") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_SW500Dual_HRG");        
        if( TraderInventory.Find("KFGame.KFWeapDef_ChiappaRhinoDual") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_ChiappaRhinoDual");        
        if( TraderInventory.Find("KFGame.KFWeapDef_Healthrower_HRG") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_Healthrower_HRG");
        if( TraderInventory.Find("KFGame.KFWeapDef_IonThruster") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_IonThruster");
        if( TraderInventory.Find("KFGame.KFWeapDef_ChiappaRhino") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_ChiappaRhino");        
            
        MapInfo.Name = "KF-AshwoodAsylum";
        MapInfo.Type = "Halloween";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 7 )
    {
        if( TraderInventory.Find("KFGame.KFWeapDef_HRGWinterbiteDual") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRGWinterbiteDual");
        if( TraderInventory.Find("KFGame.KFWeapDef_HRGWinterbite") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRGWinterbite");
        if( TraderInventory.Find("KFGame.KFWeapDef_HRGIncision") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRGIncision");        
        if( TraderInventory.Find("KFGame.KFWeapDef_MosinNagant") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_MosinNagant");        
        if( TraderInventory.Find("KFGame.KFWeapDef_G18") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_G18");      
            
        MapInfo.Name = "KF-Sanitarium";
        MapInfo.Type = "Halloween";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 8 )
    {
        if( TraderInventory.Find("KFGame.KFWeapDef_HRGIncendiaryRifle") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRGIncendiaryRifle");
        if( TraderInventory.Find("KFGame.KFWeapDef_CompoundBow") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_CompoundBow");     
        
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 9 )
    {
        if( TraderInventory.Find("KFGame.KFWeapDef_HRGScorcher") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRGScorcher");
        if( TraderInventory.Find("KFGame.KFWeapDef_HRG_EMP_ArcGenerator") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRG_EMP_ArcGenerator");  
        if( TraderInventory.Find("KFGame.KFWeapDef_Mine_Reconstructor") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_Mine_Reconstructor");   
        if( TraderInventory.Find("KFGame.KFWeapDef_Minigun") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_Minigun");        
        if( TraderInventory.Find("KFGame.KFWeapDef_Blunderbuss") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_Blunderbuss");          
        if( TraderInventory.Find("KFGame.KFWeapDef_HRG_Kaboomstick") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRG_Kaboomstick");           
        if( TraderInventory.Find("KFGame.KFWeapDef_Pistol_G18C") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_Pistol_G18C");           
        if( TraderInventory.Find("KFGame.KFWeapDef_Pistol_DualG18") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_Pistol_DualG18");              
        if( TraderInventory.Find("KFGame.KFWeapDef_HRGTeslauncher") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRGTeslauncher");     
        
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 10 )
    {
        if( TraderInventory.Find("KFGameContent.KFWeapDef_HRGTeslauncher") == INDEX_NONE )
            TraderInventory.AddItem("KFGameContent.KFWeapDef_HRGTeslauncher");
        
        iVersionNumber++;
    }
    
    if( iVersionNumber <= 11 )
    {
        MapInfo.Name = "KF-Elysium";
        MapInfo.Type = "Halloween";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        MapInfo.Name = "KF-HellmarkStation";
        MapInfo.Type = "Halloween";
        MapInfo.MaxMonsters = 32;
        MapTypes.AddItem(MapInfo);
        
        if( TraderInventory.Find("KFGameContent.KFWeapDef_HRGTeslauncher") != INDEX_NONE )
            TraderInventory.RemoveItem("KFGameContent.KFWeapDef_HRGTeslauncher");
        if( TraderInventory.Find("KFGame.KFWeapDef_HRGTeslauncher") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRGTeslauncher");
        if( TraderInventory.Find("KFGame.KFWeapDef_HRG_Vampire") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_HRG_Vampire");
        if( TraderInventory.Find("KFGame.KFWeapDef_Rifle_FrostShotgunAxe") == INDEX_NONE )
            TraderInventory.AddItem("KFGame.KFWeapDef_Rifle_FrostShotgunAxe");
        
        iVersionNumber++;
    }
    
    SaveConfig();
}

function LoadInfoObject(string ObjectName)
{
    local array<string> Names;
    local int           i;

    GetPerObjectConfigSections(class'ZEDReplacmentInfo', Names);
    for (i = 0; i < Names.Length; i++)
    {
        if( InStr(Names[i], ObjectName) != INDEX_NONE )
        {
            LoadedTable = New(None, Left(Names[i], InStr(Names[i], " "))) class'ZEDReplacmentInfo';
            break;
        }
    }
    
    LoadMonsterList();
}

function LoadMonsterList()
{
    local int                   i;
    local class<KFPawn_Monster> KFM, KFMO;
    
    if( LoadedAIList.Length > 0 || LoadedTable == None )
        LoadedAIList.Length = 0;
        
    LoadedAIList.Length = LoadedTable.AIReplacments.Length;
    for( i=0; i<LoadedTable.AIReplacments.Length; i++ )
    {
        KFMO = class<KFPawn_Monster>(DynamicLoadObject(ZEDNameToClass(LoadedTable.AIReplacments[i].Original), class'Class', false));
        KFM = class<KFPawn_Monster>(DynamicLoadObject(ZEDNameToClass(LoadedTable.AIReplacments[i].Replacment), class'Class', false));
        
        if( KFM != None && KFMO != None )
        {
            LoadedAIList[i].Original = KFMO;
            LoadedAIList[i].Replacment = KFM;
            LoadedAIList[i].bCheckChildren = LoadedTable.AIReplacments[i].bCheckChildren;
            LoadedAIList[i].iReplacmentChance = LoadedTable.AIReplacments[i].ReplacmentChance;
            
            AddLoadPackage(KFMO);
            AddLoadPackage(KFM);
            
            KFM.static.PreloadContent();
        }
    }
}

function SpawnTeamChatProxies()
{
    local ClassicTeamChatProxy  Proxy;
    local int                   i;
    
    if( WorldInfo.Game.GameReplicationInfo == None )
    {
        SetTimer(0.1, false, 'SpawnTeamChatProxies');
        return;
    }
    
    for( i=0; i<WorldInfo.Game.GameReplicationInfo.Teams.Length; i++ )
    {
        Proxy = WorldInfo.Spawn(class'ClassicTeamChatProxy',, name("TeamChatProxy__"$i));
        if( Proxy != None )
        {
            Proxy.PlayerReplicationInfo.Team = WorldInfo.Game.GameReplicationInfo.Teams[i];
        }
    }
}

function SetDifficultyInfo()
{
    local KFGameDifficultyInfo KFDI;
    
    if( bDisableGameplayChanges )
        return;
    
    KFDI = MyKFGI.DifficultyInfo;
    if( KFDI != None )
    {
        KFDI.Normal.DoshKillMod = 1.f;
        KFDI.Normal.StartingDosh = 250;
        
        KFDI.Hard.DoshKillMod = 0.85f;
        KFDI.Hard.StartingDosh = 250;
        
        KFDI.Suicidal.DoshKillMod = 0.65f;
        KFDI.Suicidal.StartingDosh = 150;
        
        KFDI.HellOnEarth.DoshKillMod = 0.65f;
        KFDI.HellOnEarth.StartingDosh = 100;
        
        KFDI.SetDifficultySettings(MyKFGI.GameDifficulty);
    }
}

function SetupWebAdmin()
{
    local WebServer     W;
    local WebAdmin      A;
    local ClassicWebApp xW;
    local byte          i;

    foreach AllActors(class'WebServer',W)
        break;
        
    if( W!=None )
    {
        for( i=0; (i<10 && A==None); ++i )
            A = WebAdmin(W.ApplicationObjects[i]);
        if( A!=None )
        {
            xW = new (None) class'ClassicWebApp';
            xW.MyMutator = Self;
            A.addQueryHandler(xW);
        }
        else `Log("ClassicWebAdmin ERROR: No valid WebAdmin application found!");
    }
    else `Log("ClassicWebAdmin ERROR: No WebServer object found!");
}

function SetMaxPlayers()
{
    local OnlineGameSettings GameSettings;

    WorldInfo.Game.MaxPlayers = ForcedMaxPlayers;
    WorldInfo.Game.MaxPlayersAllowed = ForcedMaxPlayers;
    if( WorldInfo.Game.GameInterface!=None )
    {
        GameSettings = WorldInfo.Game.GameInterface.GetGameSettings(WorldInfo.Game.PlayerReplicationInfoClass.default.SessionName);
        if( GameSettings!=None )
            GameSettings.NumPublicConnections = ForcedMaxPlayers;
    }
}

function bool OverridePickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup, out byte bAllowPickup)
{
    local string                     S, WeaponName;
    local bool                       Ret;
    local int                        SellPrice;
    local byte                       ItemIndex;
    local KFGameReplicationInfo      GRI;
    local class<KFWeapon>            Weapon;
    local class<KFWeaponDefinition>  WeaponDef;
    local KFInventoryManager         InvMan;
    local PlayerController           PC;
    local ClassicPlayerController    CPC;
    local STraderItem                Item;
    local ClassicDroppedPickup       Drop;
    
    Ret = Super.OverridePickupQuery(Other, ItemClass, Pickup, bAllowPickup);
    Drop = ClassicDroppedPickup(Pickup);
    if( Drop == None || Drop.DroppedPawn == Other )
        return Ret;
    
    CPC = ClassicPlayerController(Drop.OwnerController);
    if( CPC == None || CPC == Other.Controller )
        return Ret;
    
    if( Drop.bDisablePickup && CPC != Other.Controller && class<KFCarryableObject>(ItemClass) == None )
    {
        bAllowPickup = 0;
        return true;
    }
    
    if( !bBroadcastPickups || !Other.InvManager.HandlePickupQuery(ItemClass, Pickup) )
        return Ret;

    Weapon = class<KFWeapon>(ItemClass);
    if( Weapon == None )
        return Ret;
        
    GRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( GRI == None )
        return Ret;
    
    if( GRI.TraderItems.GetItemIndicesFromArche(ItemIndex, Weapon.Name) )
    {
        WeaponDef = GRI.TraderItems.SaleItems[ItemIndex].WeaponDef;
        Item = GRI.TraderItems.SaleItems[ItemIndex];
    }
    else return Ret;
        
    if( WeaponDef == None )
        return Ret;
        
    InvMan = KFInventoryManager( Other.InvManager );
    if( InvMan == None || !InvMan.CanCarryWeapon(Weapon) )
        return Ret;
        
    WeaponName = WeaponDef.static.GetItemName();
    SellPrice = InvMan.GetAdjustedSellPriceFor(Item);

    S = "%p #{DEF}picked up %o's %w #{DEF}($%$#{DEF}).";
    S = Repl(S, "%p", "#{C00101}"$class'ClassicPlayerController'.static.StripColorMessage(Other.GetHumanReadableName()));
    S = Repl(S, "%o", "#{01C001}"$class'ClassicPlayerController'.static.StripColorMessage(Drop.OwnerName));
    S = Repl(S, "%w", "#{0160C0}"$WeaponName);
    S = Repl(S, "%$", "#{C0C001}"$SellPrice);
    
    foreach WorldInfo.AllControllers(class'PlayerController', PC)
    {
        PC.ClientMessage(S);
    }
    
    return Ret;
}

function SetupMapInfo()
{
    local MapTypeInfo MapInfo;
    
    SetMaxMonsters(GlobalMaxMonsters);

    foreach MapTypes(MapInfo)
    {
        if( WorldInfo.GetMapName(true) ~= MapInfo.Name )
        {
            if( MapInfo.MaxMonsters != GlobalMaxMonsters )
            {
                SetMaxMonsters(MapInfo.MaxMonsters);
            }
        
            if( MapInfo.Type ~= "XMas" || MapInfo.Type ~= "Winter" )
            {
                EventHelper.SetEventType(EV_WINTER);
                return;
            }
            else if( MapInfo.Type ~= "Summer" || MapInfo.Type ~= "Slideshow" )
            {
                EventHelper.SetEventType(EV_SUMMER);
                return;
            }
            else if( MapInfo.Type ~= "Spring" )
            {
                EventHelper.SetEventType(EV_SPRING);
                return;
            }
            else if( MapInfo.Type ~= "Fall" || MapInfo.Type ~= "Halloween" )
            {
                EventHelper.SetEventType(EV_FALL);
                return;
            }
        }
    }

    switch(GlobalEventName)
    {
        case 'XMas':
        case 'Winter':
            EventHelper.SetEventType(EV_WINTER);
            break;
        case 'Slideshow':
        case 'Summer':
            EventHelper.SetEventType(EV_SUMMER);
            break;
        case 'Spring':
            EventHelper.SetEventType(EV_SPRING);
            break;
        case 'Fall':
        case 'Halloween':
            EventHelper.SetEventType(EV_FALL);
            break;
        default:
            EventHelper.SetEventType(EV_NORMAL);
            break;
    }
}

function SetMaxMonsters(int MaxCount)
{
    local int i,j;
    
    if( MyKFGI.SpawnManager != None )
    {
        for( i=0; i<MyKFGI.SpawnManager.PerDifficultyMaxMonsters.Length; i++ )
        {
            for( j=0; j<MyKFGI.SpawnManager.PerDifficultyMaxMonsters[i].MaxMonsters.Length; j++ )
            {
                MyKFGI.SpawnManager.PerDifficultyMaxMonsters[i].MaxMonsters[j] = Max(MyKFGI.SpawnManager.PerDifficultyMaxMonsters[i].MaxMonsters[j], MaxCount);
            }
        }
    }
}

function InitGRIList()
{
    local ClassicPlayerController PC;

    KFGameReplicationInfo(WorldInfo.GRI).TraderItems = CustomTrader;

    // Must sync up local client.
    if( WorldInfo.NetMode==NM_StandAlone )
    {
        foreach LocalPlayerControllers(class'ClassicPlayerController',PC)
            if( PC.PurchaseHelper!=None )
                PC.PurchaseHelper.TraderItems = CustomTrader;
    }
}

function bool GetNextItem( ClassicPlayerReplicationInfo PRI, int RepIndex )
{
    if( RepIndex>=CustomItemList.Length )
        return false;
    PRI.ClientAddTraderItem(RepIndex,CustomItemList[RepIndex]);
    return true;
}

function SetupClassicSystems()
{
    local int i;

    if (KFMI != none )
    {
        KFMI.bUsePresetObjectives = false;
        KFMI.bUseRandomObjectives = false;
        
        for( i=0; ArrayCount(KFMI.PresetWaveObjectives.ShortObjectives) < i; i++ )
        {
            KFMI.PresetWaveObjectives.ShortObjectives[i].PossibleObjectives.Length = 0;
        }       
        
        for( i=0; ArrayCount(KFMI.PresetWaveObjectives.MediumObjectives) < i; i++ )
        {
            KFMI.PresetWaveObjectives.MediumObjectives[i].PossibleObjectives.Length = 0;
        }       
        
        for( i=0; ArrayCount(KFMI.PresetWaveObjectives.LongObjectives) < i; i++ )
        {
            KFMI.PresetWaveObjectives.LongObjectives[i].PossibleObjectives.Length = 0;
        }
    }
    
    ModifySpawnManager();
    SetupMapInfo();
}

function ModifySpawnManager()
{
    if( MyKFGI != None )
    {
        if( KFGameInfo_Endless(MyKFGI) != None )
        {
            MyKFGI.SpawnManager = new(KFGameInfo_Endless(MyKFGI)) class'KFAISpawnManager_Endless_Classic';
            
            if( KFAISpawnManager_Endless_Classic(MyKFGI.SpawnManager) != None )
                KFAISpawnManager_Endless_Classic(MyKFGI.SpawnManager).ControllerMutator = self;
        }
        else 
        {
            MyKFGI.SpawnManager = new(MyKFGI) class'KFAISpawnManager_Classic';
            
            if( KFAISpawnManager_Classic(MyKFGI.SpawnManager) != None )
                KFAISpawnManager_Classic(MyKFGI.SpawnManager).ControllerMutator = self;
        }
        
        MyKFGI.SpawnManager.Initialize();
    }
}

static final function string GetStatFile( const out UniqueNetId UID )
{
    return Repl("../../KFGame/Script/%s.usa","%s","SR_"$class'OnlineSubsystem'.Static.UniqueNetIdToString(UID));
}

function PlayerChangeSpec( ClassicPlayerController PC, bool bSpectator )
{
    if( bSpectator==PC.PlayerReplicationInfo.bOnlySpectator || PC.NextSpectateChange>WorldInfo.TimeSeconds )
        return;
    PC.NextSpectateChange = WorldInfo.TimeSeconds+0.5;
    
    if( WorldInfo.Game.bGameEnded )
        PC.ClientMessage("Can't change spectate mode after end-game.");
    else if( WorldInfo.Game.bWaitingToStartMatch )
        PC.ClientMessage("Can't change spectate mode before game has started.");
    else if( WorldInfo.Game.AtCapacity(bSpectator,PC.PlayerReplicationInfo.UniqueId) )
        PC.ClientMessage("Can't change spectate mode because game is at its maximum capacity.");
    else if( bSpectator )
    {
        PC.NextSpectateChange = WorldInfo.TimeSeconds+2.5;
        if( PC.PlayerReplicationInfo.Team!=None )
            PC.PlayerReplicationInfo.Team.RemoveFromTeam(PC);
        PC.PlayerReplicationInfo.bOnlySpectator = true;
        if( PC.Pawn!=None )
            PC.Pawn.KilledBy(None);
        PC.Reset();
        --WorldInfo.Game.NumPlayers;
        ++WorldInfo.Game.NumSpectators;
        WorldInfo.Game.Broadcast(PC,PC.PlayerReplicationInfo.GetHumanReadableName()@"became a spectator");
    }
    else
    {
        PC.PlayerReplicationInfo.bOnlySpectator = false;
        if( !WorldInfo.Game.ChangeTeam(PC,WorldInfo.Game.PickTeam(0,PC,PC.PlayerReplicationInfo.UniqueId),false) )
        {
            PC.PlayerReplicationInfo.bOnlySpectator = true;
            PC.ClientMessage("Can't become an active player, failed to set a team.");
            return;
        }
        PC.NextSpectateChange = WorldInfo.TimeSeconds+2.5;
        ++WorldInfo.Game.NumPlayers;
        --WorldInfo.Game.NumSpectators;
        PC.Reset();
        WorldInfo.Game.Broadcast(PC,PC.PlayerReplicationInfo.GetHumanReadableName()@"became an active player");
    }
}

function bool IsFromMod(Object O)
{
    local string PackageName;
    
    if( O == None )
        return false;
    
    PackageName = string(O.GetPackageName());
    if( PackageName ~= "KFGameContent" || PackageName ~= "KFGame" )
        return false;
        
    return true;
}

function ScoreKill(Controller Killer, Controller Killed)
{
    local KFPawn_Monster KFM;
    local int i, j;
    local KFPlayerController KFPC;
    local KFPlayerReplicationInfo DamagerKFPRI;
    local float XP;
    local KFPerk InstigatorPerk;
    local ClassicPlayerController C;
    local Color SpectatorColor;
    
    KFM = KFPawn_Monster(Killed.Pawn);
    if( KFM!=None && Killed.GetTeamNum()!=0 && Killer.bIsPlayer && Killer.GetTeamNum()==0 )
    {
        if( Killer.PlayerReplicationInfo!=None )
            BroadcastKillMessage(Killed.Pawn,Killer);
            
        if( KFM.DamageHistory.Length > 0 && IsFromMod(KFM) )
        {
            for( i = 0; i<KFM.DamageHistory.Length; i++ )
            {
                DamagerKFPRI = KFPlayerReplicationInfo(KFM.DamageHistory[i].DamagerPRI);
                if( DamagerKFPRI != None )
                {
                    if( KFM.DamageHistory[i].DamagePerks.Length <= 0 )
                    {
                        continue;
                    }

                    // Distribute experience points
                    KFPC = KFPlayerController(DamagerKFPRI.Owner);
                    if( KFPC != none )
                    {
                        InstigatorPerk = KFPC.GetPerk();
                        if( InstigatorPerk.ShouldGetAllTheXP() )
                        {
                            KFPC.OnPlayerXPAdded(KFM.static.GetXPValue(MyKFGI.GameDifficulty), InstigatorPerk.Class);
                            continue;
                        }

                        XP = KFM.static.GetXPValue(MyKFGI.GameDifficulty) / KFM.DamageHistory[i].DamagePerks.Length;

                        for( j = 0; j < KFM.DamageHistory[i].DamagePerks.Length; j++ )
                        {
                            KFPC.OnPlayerXPAdded(FCeil(XP), KFM.DamageHistory[i].DamagePerks[j]);
                        }
                    }
                }
            }
        }
    }
    
    if( KFPawn_Human(Killed.Pawn) != None )
    {
        if( bEnabledVisibleSpectators && !KFGameReplicationInfo(WorldInfo.GRI).bMatchIsOver )
        {
            C = ClassicPlayerController(Killed);
            if( C != None )
            {
                SpectatorColor.R = RandRange(55, 255);
                SpectatorColor.G = RandRange(55, 255);
                SpectatorColor.B = RandRange(55, 255);
                SpectatorColor.A = 255;
                
                if( C.VisSpectator != None )
                    C.VisSpectator.Remove();
                
                C.bIsSpectating = true;

                C.VisSpectator = Spawn(Rand(1) == 0 ? class'SpectatorFlame' : class'SpectatorUFO', C,, C.Location,,, true);
                C.VisSpectator.SetPlayerOwner(C);
                C.VisSpectator.SetColor(SpectatorColor);
            }
        }
        
        foreach WorldInfo.AllControllers(class'ClassicPlayerController',C)
        {
            if( C.bClientHidePlayerDeaths )
                continue;
            C.ClientKillMessage(Killed.Pawn.Class, Killer.Pawn, Killed.PlayerReplicationInfo, Killer.PlayerReplicationInfo, Killer.bIsPlayer);
        }
    }
    
    Super.ScoreKill(Killer, Killed);
}

final function BroadcastKillMessage( Pawn Killed, Controller Killer )
{
    local ClassicPlayerController E;

    if( Killer==None || Killer.PlayerReplicationInfo==None )
        return;

    if( KFPawn_Monster(Killed) != None && (KFPawn_Monster(Killed).bLargeZed || KFInterface_MonsterBoss(Killed) != None) )
    {
        foreach WorldInfo.AllControllers(class'ClassicPlayerController',E)
        {
            E.ReceiveKillMessage(Killed.Class,true,Killer.PlayerReplicationInfo);
        }
    }
    else if( ClassicPlayerController(Killer)!=None )
        ClassicPlayerController(Killer).ReceiveKillMessage(Killed.Class);
}

function NetDamage(int OriginalDamage, out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
{
    Super.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser);

    if( LastDamageDealer!=None )
    {
        ClearTimer('CheckDamageDone');
        CheckDamageDone();
    }
    
    if( Damage>0 && InstigatedBy != None )
    {
        if( KFPawn_Monster(Injured) != None && ClassicPlayerController(InstigatedBy) != None )
        {
            LastDamageDealer = ClassicPlayerController(InstigatedBy);
            if( LastDamageDealer.bNoDamageTracking )
                return;
                
            LastHitZed = KFPawn(Injured);
            LastHitHP = LastHitZed.Health;
            LastDamagePosition = HitLocation;
            LastDamageDMGType = class<KFDamageType>(DamageType);
            SetTimer(0.1,false,'CheckDamageDone');
        }
    }
}

final function CheckDamageDone()
{
    local int Damage;

    if( LastDamageDealer!=None && LastHitZed!=None && LastHitHP!=LastHitZed.Health )
    {
        Damage = LastHitHP-Max(LastHitZed.Health,0);
        if( Damage>0 )
        {
            if( !LastDamageDealer.bClientHideDamageMsg && KFPawn_Monster(LastHitZed)!=None )
                LastDamageDealer.ReceiveDamageMessage(LastHitZed.Class,Damage);
            if( !LastDamageDealer.bClientHideNumbers )
                LastDamageDealer.ClientNumberMsg(Damage,LastDamagePosition,LastDamageDMGType);
        }
    }
    LastDamageDealer = None;
}

final function SavePlayerPerk( ClassicPlayerController PC )
{
    if( PC.PerkManager!=None && PC.PerkManager.bStatsDirty )
    {
        // Verify broken stats.
        if( PC.PerkManager.bUserStatsBroken )
        {
            PC.ClientMessage("Warning: Your stats are broken, not saving.",'Priority');
            return;
        }
        ServerStatLoader.FlushData();
        if( ServerStatLoader.LoadStatFile(PC) && ServerStatLoader.GetSaveVersion()!=PC.PerkManager.UserDataVersion )
        {
            PC.PerkManager.bUserStatsBroken = true;
            PC.ClientMessage("Warning: Your stats save data version differs from what is loaded, stat saving disabled to prevent stats loss.",'Priority');
            return;
        }
        
        // Actually save.
        ServerStatLoader.FlushData();
        PC.PerkManager.SaveData(ServerStatLoader);
        ServerStatLoader.SaveStatFile(PC);
        PC.PerkManager.bStatsDirty = false;
    }
}

function SaveAllPerks()
{
    local ClassicPlayerController PC;
    
    if( bGameHasEnded )
        return;
        
    foreach WorldInfo.AllControllers(class'ClassicPlayerController',PC)
    {
        if( PC.PerkManager!=None && PC.PerkManager.bStatsDirty )
        {
            SavePlayerPerk(PC);
        }
    }
}

function CheckC4()
{
    local KFProj_Thrown_C4  C4A;
    local int               CurCount;
    local bool              bZed;    
    local KFPawn_MOnster    KFM;
    local KFWeap_Thrown_C4  C4WeaponOwner;
    
    foreach WorldInfo.DynamicActors( class'KFProj_Thrown_C4', C4A)
    {
        if( !C4A.bHasExploded && !C4A.bHasDisintegrated && (WorldInfo.TimeSeconds - CreationTime)>3 )
        {
            C4A.PlaySoundBase( C4A.ProximityAlertAkEvent, false );
            CurCount=0;
            bZed=false;
            
            foreach C4A.OverlappingActors( class'KFPawn_Monster', KFM, 250, , false )
            {                
                if(KFM.Health>0)
                {
                    CurCount++;
                }
                
                if(KFM.Health>0 && (KFPawn_ZedHusk(KFM)!=None || KFM.Mass>=130))
                {
                    bZed=true;
                    break;
                }
            }
            
            if(CurCount>=5 || bZed)
            {
                C4A.BlinkOff();
                C4A.Detonate();
                C4WeaponOwner = KFWeap_Thrown_C4( C4A.Owner );
                
                if( C4WeaponOwner != none )
                {
                    C4WeaponOwner.RemoveDeployedCharge(, C4A);
                }
                C4A.BlinkOff();                
            }
        }
    }
}

function CheckWave()
{
    local KFGameReplicationInfo KF;
    
    if( KF==None )
    {
        KF = KFGameReplicationInfo(WorldInfo.GRI);
        if( KF==None )
            return;
    }
    if( LastWaveNum!=KF.WaveNum )
    {
        LastWaveNum = KF.WaveNum;
        NotifyWaveChange();
    }
    if( !bGameHasEnded && KF.bMatchIsOver ) // HACK, since KFGameInfo_Survival doesn't properly notify mutators of this!
    {
        SaveAllPerks();
        bGameHasEnded = true;
    }
}

function NotifyWaveChange()
{
    if( StatAutoSaveWaves>0 && ++NumWaveSwitches>=StatAutoSaveWaves )
    {
        NumWaveSwitches = 0;
        SaveAllPerks();
    }
}

function CheckPerkChange( ClassicPlayerController PC )
{
    if( PC.PendingPerk!=None )
    {
        PC.PerkManager.ApplyPerk(PC.PendingPerk);
        PC.PendingPerk = None;
    }
}

function ModifyPlayer(Pawn Other)
{
    local KFGameReplicationInfo KFGRI;
    
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( KFGRI != None && !bDisableGameplayChanges )
    {
        if( KFPawn(Other) != None )
        {
            KFPawn(Other).bIgnoreTeamCollision = KFGRI.bTraderIsOpen;
        }
    }
    
    Super.ModifyPlayer(Other);
}

function Tick(float DeltaTime)
{
    local ClassicPlayerController   ClassicPC;
    local KFGameReplicationInfo     KFGRI;
    local KFDoorActor               Door;
    
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( KFGRI != None )
    {
        if( KFGRI.bTraderIsOpen && !bCheckedWave )
        {
            foreach WorldInfo.AllControllers(class'ClassicPlayerController',ClassicPC)
            {
                CheckPerkChange(ClassicPC);
                
                if( KFPawn(ClassicPC.Pawn) != None )
                {
                    KFPawn(ClassicPC.Pawn).UpdateGroundSpeed();
                    
                    if( !bDisableGameplayChanges )
                        KFPawn(ClassicPC.Pawn).bIgnoreTeamCollision = true;
                }
            }
            
            foreach DynamicActors(class'KFDoorActor',Door)
            {
                if( Door.bIsDestroyed )
                {
                    Door.Repair(255.f);
                }
            }
            
            SetTimer(1, true, 'CheckTraderTime');
            WorldInfo.Game.BroadcastLocalizedMessage(class'KFWaitingMessage', `WM_WAVESURVIVED);
                
            bCheckedWave = true;
        }
        else if( !KFGRI.bTraderIsOpen && bCheckedWave )
        {
            foreach WorldInfo.AllControllers(class'ClassicPlayerController',ClassicPC)
            {
                if( KFPawn(ClassicPC.Pawn) != None )
                {
                    KFPawn(ClassicPC.Pawn).UpdateGroundSpeed();
                    
                    if( !bDisableGameplayChanges )
                        KFPawn(ClassicPC.Pawn).bIgnoreTeamCollision = false;
                }
                
                if( ClassicPC.bSetPerk )
                {
                    ClassicPC.bSetPerk = false;
                }
            }
                
            ClearTimer('CheckTraderTime');
            bCheckedWave = false;
        }
    }
}

function CheckTraderTime()
{
    local KFGameReplicationInfo KFGRI;
    
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( KFGRI != None )
    {
        if ( KFGRI.RemainingTime > 0 && KFGRI.RemainingTime <= 5 )
        {
            WorldInfo.Game.BroadcastLocalizedMessage(class'KFWaitingMessage', (KFGameReplicationInfo_Endless(KFGRI) != None && KFGRI.IsBossWaveNext()) ? `WM_BOSSINBOUND : (KFGRI.IsFinalWave() ? `WM_FINALWAVEINBOUND : `WM_WAVEINBOUND));
        }
    }
}

function AdjustSpawnList(out array<class<KFPawn_Monster> > SpawnList)
{
    local int i;
    
    for( i=0; i<SpawnList.Length; i++ )
    {
        if( LoadedAIList.Length != 0 )
        {
            CheckForZEDReplacment(i, LoadedAIList, SpawnList);
        }
        
        if( AIClassList.Length != 0 )
        {
            CheckForZEDReplacment(i, AIClassList, SpawnList);
        }
    }
}

function CheckForZEDReplacment(int Index, array<AIReplacementS> ReplacementList, out array<class<KFPawn_Monster> > SpawnList)
{
    local bool             bShouldReplace;
    local AIReplacementS   AIReplacement;
    
    ForEach ReplacementList(AIReplacement)
    {
        if( AIReplacement.Replacment == None || AIReplacement.Original == None )
            continue;
            
        if( FRand() <= FClamp(AIReplacement.iReplacmentChance, 0.f, 1.f) )
        {
            if( AIReplacement.bCheckChildren )
                bShouldReplace = ClassIsChildOf(SpawnList[Index], AIReplacement.Original);
            else bShouldReplace = (String(SpawnList[Index].Name) == String(AIReplacement.Original.Name));
                
            if( bShouldReplace )
                SpawnList[Index] = AIReplacement.Replacment;
        }
    }
}

function NotifyLogin(Controller NewPlayer)
{
    local ClassicPlayerReplicationInfo PRI;
    local ClassicPlayerController PC;
    
    PRI = ClassicPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo);
    if( KFPlayerController(NewPlayer) != None && PRI != None )
    {
        PRI.CustomCharList = CustomCharacterList;
        
        if( WorldInfo.NetMode!=NM_StandAlone )
        {
            PRI.OnRepNextItem = GetNextItem;
            PRI.SetTimer(0.075,true,'ReplicateTimer');
        }
        else
        {
            PRI.AllCharReceived();
        }
    }
        
    PC = ClassicPlayerController(NewPlayer);
    if( PC!=None )
    {
        SendMOTD(PC);
        PC.bDisableGameplayChanges = bDisableGameplayChanges;
        PC.bEnableTraderSpeed = bEnableTraderSpeed;
        PC.bDisableUpgrades = bDisableUpgradeSystem;
        PC.bEnabledVisibleSpectators = bEnabledVisibleSpectators;
        PC.RefireRate = SpectatorRefireRate;
        PC.ZapDamage = SpectatorZapDamage;
        PC.HealAmount = SpectatorHealAmount;
        
        if( !bGameHasEnded )
            InitializePerks(PC);
    }
    
    Super.NotifyLogin(NewPlayer);
}

function NotifyLogout(Controller Exiting)
{
    if( KFPlayerController(Exiting)!=None && Exiting.Pawn != None )
    {
        Exiting.Pawn.Destroy();
    }
    if( !bGameHasEnded && ClassicPlayerController(Exiting)!=None )
    {
        SavePlayerPerk(ClassicPlayerController(Exiting));
    }
    
    Super.NotifyLogout(Exiting);
}

function InitializePerks( ClassicPlayerController Other )
{
    local ClassicPerkManager              PM;
    local ClassicPerk_Base                P;
    local int                             i,Index;
    
    Other.OnSpectateChange = PlayerChangeSpec;
    
    PM = Other.PerkManager;
    PM.InitPerks();
    
    if( bDisableGameplayChanges )
    {
        if( !bDisableGunslinger )
        {
            Index = LoadedPerks.Find(class'KFClassicMode.ClassicPerk_Gunslinger_Default');
            if( Index == INDEX_NONE )
                LoadedPerks.AddItem(class'KFClassicMode.ClassicPerk_Gunslinger_Default');
        }
            
        if( !bDisableSWAT )
        {
            Index = LoadedPerks.Find(class'KFClassicMode.ClassicPerk_SWAT_Default');
            if( Index == INDEX_NONE )
                LoadedPerks.AddItem(class'KFClassicMode.ClassicPerk_SWAT_Default');
        }
    }
     
    for( i=0; i<LoadedPerks.Length; ++i )
    {   
        P = Spawn(LoadedPerks[i],Other);
        if( P != None )
        {
            P.MinimumLevel = MinPerkLevel;
            P.MaximumLevel = bDisableGameplayChanges ? byte(Max(25, MaxPerkLevel)) : MaxPerkLevel;
            
            P.FirstLevelExp *= RequirementScaling;
            P.LevelUpExpCost *= RequirementScaling;
            P.LevelUpIncCost *= RequirementScaling;
            
            PM.RegisterPerk(P);
        }
    }
    
    ServerStatLoader.FlushData();
    if( ServerStatLoader.LoadStatFile(Other) )
    {
        ServerStatLoader.ToStart();
        PM.LoadData(ServerStatLoader);
    }
    PM.ServerInitPerks();
}

final function SendMOTD( ClassicPlayerController PC )
{
    local string S;
    
    S = ServerMOTD;
    while( Len(S)>510 )
    {
        PC.ReceiveServerMOTD(Left(S,500),false);
        S = Mid(S,500);
    }
    PC.ReceiveServerMOTD(S,true);
}

final function AddLoadPackage( Object O )
{
    if( ExternalObjs.Find(O)==-1 )
        ExternalObjs.AddItem(O);
}

function bool CheckReplacement(Actor A)
{
    local KFWeapon KFW;
    
    if( BasicWebAdminUser(A) != None )
    {
        BasicWebAdminUser(A).PCClass = class'ClassicMessageSpectator';
        return true;
    }
    
    if( TeamChatProxy(A) != None && ClassicTeamChatProxy(A) == None )
    {
        return false;
    }
    
    KFW = KFWeapon(A);
    if( KFW != None )
    {
        KFW.DroppedPickupClass = class'ClassicDroppedPickup';
        return true;
    }
  
    return Super.CheckReplacement(A);
}

function ModifyPickupFactories()
{
    local PickupReplacmentStruct Replacment;
    
    foreach LoadedWeaponReplacements(Replacment)
    {
        ReplaceWeaponPickup(Replacment.OriginalClass, Replacment.ReplacmentClass);
    }

    Super.ModifyPickupFactories();
}

function ReplaceWeaponPickup(class<KFWeapon> OldWeaponClass, class<KFWeapon> NewWeaponClass)
{
    local KFPickupFactory       KFPF;
    local KFPickupFactory_Item  KFPFI;
    local int                   i;
    
    foreach MyKFGI.ItemPickups(KFPF)
    {
        KFPFI = KFPickupFactory_Item(KFPF);
        if( KFPFI != None )
        {
            for( i = 0; i < KFPFI.ItemPickups.Length; i++ )
            {
                if( KFPFI.ItemPickups[i].ItemClass == OldWeaponClass )
                    KFPFI.ItemPickups[i].ItemClass = NewWeaponClass;
            }
        }
    }
}

// Copy of GameInfo::ChoosePlayerStart, modified to get the closest spawn to Trader.
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
    local PlayerStart P, BestStart;
    local int BestRating, NewRating;
    local KFTraderTrigger T;
    local KFGameReplicationInfo GRI;
    local NavigationPoint Ret;
    
    Ret = Super.FindPlayerStart(Player, InTeam, incomingName);
    if( !bEnableCloseToTraderSpawns )
        return Ret;
    
    GRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( GRI == None )
        return Ret;
        
    T = GRI.OpenedTrader != None ? GRI.OpenedTrader : GRI.NextTrader;
    if( T == None )
        return Ret;

    foreach WorldInfo.AllNavigationPoints(class'PlayerStart', P)
    {
        if( !P.bEnabled )
            continue;
            
        NewRating = VSizeSq(P.Location - T.Location);
        if( NewRating < BestRating )
        {
            BestRating = NewRating;
            BestStart = P;
        }
    }
    return BestStart;
}

function string ZEDNameToClass(string ClassName)
{
    Switch(ClassName)
    {
        Case "Random":
            return ZEDNameToClass(ZedNames[Rand(ZedNames.Length)]);
        Case "Cyst":
            return "KFGameContent.KFPawn_ZedClot_Cyst";
        Case "Alpha Clot":
            return "KFGameContent.KFPawn_ZedClot_Alpha";
        Case "Elite Alpha":
            return "KFGameContent.KFPawn_ZedClot_AlphaKing";        
        Case "Slasher":
            return "KFGameContent.KFPawn_ZedClot_Slasher";        
        Case "Crawler":
            return "KFGameContent.KFPawn_ZedCrawler";
        Case "Elite Crawler":
            return "KFGameContent.KFPawn_ZedCrawlerKing";        
        Case "Fleshpound":
            return "KFGameContent.KFPawn_ZedFleshpound";        
        Case "King Fleshpound":
            return "KFGameContent.KFPawn_ZedFleshpoundKing";
        Case "Quarter Pound":
            return "KFGameContent.KFPawn_ZedFleshpoundMini";        
        Case "Gorefast":
            return "KFGameContent.KFPawn_ZedGorefast";        
        Case "Hans":
            return "KFGameContent.KFPawn_ZedHans";
        Case "Husk":
            return "KFGameContent.KFPawn_ZedHusk";        
        Case "Patriarch":
            return "KFGameContent.KFPawn_ZedPatriarch";        
        Case "Scrake":
            return "KFGameContent.KFPawn_ZedScrake";        
        Case "Siren":
            return "KFGameContent.KFPawn_ZedSiren";        
        Case "Stalker":
            return "KFGameContent.KFPawn_ZedStalker";
        Case "Bloat":
            return "KFGameContent.KFPawn_ZedBloat";
        Case "Abomination":
        Case "King Bloat":
            return "KFGameContent.KFPawn_ZedBloat_King";
        Case "Matriarch":
            return "KFGameContent.KFPawn_ZedMatriarch";
        default:
            return ClassName;
    }
}

function InitWebAdmin( ClassicWebAdmin_UI UI )
{
    UI.AddSettingsPage("Main Classic Mode",Class,WebConfigs,WebAdminGetValue,WebAdminSetValue);
}

final function string ParseMapInfoStruct( MapTypeInfo Info )
{
    return Info.Name$","$Info.Type$","$Info.MaxMonsters;
}

final function string ParseReplacmentsStruct( TraderReplacements Info )
{
    return Info.Original$","$Info.Replacement;
}

final function TraderReplacements ParseReplacmentsString(string S)
{
    local TraderReplacements Res;
    local int                i;

    i = InStr(S,",");
    if( i==-1 )
        return Res;
    Res.Original = Left(S,i);
    S = Mid(S,i+1);
    i = InStr(S,",");
    if( i==-1 )
        return Res;
    Res.Replacement = Mid(S,i+1);
    return Res;
}

final function MapTypeInfo ParseMapInfoString(string S)
{
    local MapTypeInfo Res;
    local int         i;

    i = InStr(S,",");
    if( i==-1 )
        return Res;
    Res.Name = Left(S,i);
    S = Mid(S,i+1);
    i = InStr(S,",");
    if( i==-1 )
        return Res;
    Res.Type = Left(S,i);
    S = Mid(S,i+1);
    i = InStr(S,",");
    if( i==-1 )
        return Res;
    Res.MaxMonsters = byte(Mid(S,i+1));
    return Res;
}

function string WebAdminGetValue( name PropName, int ElementIndex )
{
    switch( PropName )
    {
    case 'RequirementScaling':
        return string(RequirementScaling);
    case 'ForcedMaxPlayers':
        return string(ForcedMaxPlayers);
    case 'StatAutoSaveWaves':
        return string(StatAutoSaveWaves);
    case 'MinPerkLevel':
        return string(MinPerkLevel);
    case 'MaxPerkLevel':
        return string(MaxPerkLevel);
    case 'GlobalMaxMonsters':
        return string(GlobalMaxMonsters);
    case 'bBroadcastPickups':
        return string(bBroadcastPickups);
    case 'bDisableGameplayChanges':
        return string(bDisableGameplayChanges);
    case 'bDisableGunslinger':
        return string(bDisableGunslinger);
    case 'bDisableSWAT':
        return string(bDisableSWAT);
    case 'bNoEDARs':
        return string(bNoEDARs);
    case 'bNoGasCrawler':
        return string(bNoGasCrawler);
    case 'bNoRioter':
        return string(bNoRioter);
    case 'bNoGorefiends':
        return string(bNoGorefiends);
    case 'bEnableTraderSpeed':
        return string(bEnableTraderSpeed);
    case 'bEnableCloseToTraderSpawns':
        return string(bEnableCloseToTraderSpawns);
    case 'bDisableUpgradeSystem':
        return string(bDisableUpgradeSystem);    
    case 'bEnabledVisibleSpectators':
        return string(bEnabledVisibleSpectators);
    case 'SpectatorRefireRate':
        return string(SpectatorRefireRate);
    case 'SpectatorZapDamage':
        return string(SpectatorZapDamage);
    case 'SpectatorHealAmount':
        return string(SpectatorHealAmount);
    case 'ZEDReplacmentTable':
        return ZEDReplacmentTable;
    case 'GlobalEventName':
        return string(GlobalEventName);
    case 'Perks':
        return (ElementIndex==-1 ? string(Perks.Length) : Perks[ElementIndex]);
    case 'CustomCharacters':
        return (ElementIndex==-1 ? string(CustomCharacters.Length) : CustomCharacters[ElementIndex]);
    case 'TraderInventory':
        return (ElementIndex==-1 ? string(TraderInventory.Length) : TraderInventory[ElementIndex]);
    case 'ServerMOTD':
        return Repl(ServerMOTD,"<LINEBREAK>",Chr(10));
    case 'MapTypes':
        return (ElementIndex==-1 ? string(MapTypes.Length) : ParseMapInfoStruct(MapTypes[ElementIndex]));
    case 'TraderWeaponReplacments':
        return (ElementIndex==-1 ? string(TraderWeaponReplacments.Length) : ParseReplacmentsStruct(TraderWeaponReplacments[ElementIndex]));
    }
}

final function UpdateReplacmentsArray( out array<TraderReplacements> Ar, int Index, const out string Value )
{
    if( Value=="#DELETE" )
        Ar.Remove(Index,1);
    else
    {
        if( Index>=Ar.Length )
            Ar.Length = Index+1;
        Ar[Index] = ParseReplacmentsString(Value);
    }
}

final function UpdateMapInfoArray( out array<MapTypeInfo> Ar, int Index, const out string Value )
{
    if( Value=="#DELETE" )
        Ar.Remove(Index,1);
    else
    {
        if( Index>=Ar.Length )
            Ar.Length = Index+1;
        Ar[Index] = ParseMapInfoString(Value);
    }
}

final function UpdateArray( out array<string> Ar, int Index, const out string Value )
{
    if( Value=="#DELETE" )
        Ar.Remove(Index,1);
    else
    {
        if( Index>=Ar.Length )
            Ar.Length = Index+1;
        Ar[Index] = Value;
    }
}

function WebAdminSetValue( name PropName, int ElementIndex, string Value )
{
    switch( PropName )
    {
    case 'RequirementScaling':
        RequirementScaling = float(Value);    
        break;
    case 'ForcedMaxPlayers':
        ForcedMaxPlayers = int(Value);        
        break;
    case 'StatAutoSaveWaves':
        StatAutoSaveWaves = int(Value);        
        break;
    case 'MinPerkLevel':
        MinPerkLevel = byte(Value);            
        break;
    case 'MaxPerkLevel':
        MaxPerkLevel = byte(Value);            
        break;
    case 'GlobalMaxMonsters':
        GlobalMaxMonsters = byte(Value);   
        SetupMapInfo();        
        break;    
    case 'bBroadcastPickups':
        bBroadcastPickups = bool(Value);    
        break;    
    case 'bDisableGameplayChanges':
        bDisableGameplayChanges = bool(Value);    
        break;
    case 'bDisableGunslinger':
        bDisableGunslinger = bool(Value);    
        break;
    case 'bDisableSWAT':
        bDisableSWAT = bool(Value);    
        break;
    case 'bNoEDARs':
        bNoEDARs = bool(Value);    
        break;
    case 'bNoGasCrawler':
        bNoGasCrawler = bool(Value);    
        break;
    case 'bNoRioter':
        bNoRioter = bool(Value);    
        break;
    case 'bNoGorefiends':
        bNoGorefiends = bool(Value);    
        break;
    case 'bEnableTraderSpeed':
        bEnableTraderSpeed = bool(Value);    
        break;
    case 'bEnableCloseToTraderSpawns':
        bEnableCloseToTraderSpawns = bool(Value);    
        break;
    case 'bDisableUpgradeSystem':
        bDisableUpgradeSystem = bool(Value);    
        break;
    case 'bEnabledVisibleSpectators':
        bEnabledVisibleSpectators = bool(Value);    
        break;
    case 'SpectatorRefireRate':
        SpectatorRefireRate = float(Value);    
        break;
    case 'SpectatorZapDamage':
        SpectatorZapDamage = float(Value);    
        break;
    case 'SpectatorHealAmount':
        SpectatorHealAmount = float(Value);    
        break;
    case 'ZEDReplacmentTable':
        ZEDReplacmentTable = Value;    
        break;
    case 'GlobalEventName':
        GlobalEventName = name(Value);
        SetupMapInfo();        
        break;
    case 'ServerMOTD':
        ServerMOTD = Repl(Value,Chr(13)$Chr(10),"<LINEBREAK>");     
        break;
    case 'Perks':
        UpdateArray(Perks,ElementIndex,Value);            
        break;
    case 'CustomCharacters':
        UpdateArray(CustomCharacters,ElementIndex,Value); 
        break;
    case 'TraderInventory':
        UpdateArray(TraderInventory,ElementIndex,Value); 
        break;    
    case 'TraderWeaponReplacments':
        UpdateReplacmentsArray(TraderWeaponReplacments, ElementIndex, Value); 
        break;
    case 'MapTypes':
        UpdateMapInfoArray(MapTypes, ElementIndex, Value);
        SetupMapInfo();
        break;
    default:
        return;
    }
    SaveConfig();
}

defaultproperties
{
    MusicReplicationInfoClass=class'MusicGRI'
    
    ZedNames.Add("Cyst")
    ZedNames.Add("Alpha Clot")
    ZedNames.Add("Elite Alpha")
    ZedNames.Add("Slasher")
    ZedNames.Add("Bloat")
    ZedNames.Add("Crawler")
    ZedNames.Add("Elite Crawler")
    ZedNames.Add("Fleshpound")
    ZedNames.Add("King Fleshpound")
    ZedNames.Add("Quarter Pound")
    ZedNames.Add("Gorefast")
    ZedNames.Add("Hans")
    ZedNames.Add("Husk")
    ZedNames.Add("Patriarch")
    ZedNames.Add("Scrake")
    ZedNames.Add("Siren")
    ZedNames.Add("Stalker")
    ZedNames.Add("Abomination")
    ZedNames.Add("King Bloat")
    
    WebConfigs.Add((PropType=0,PropName="RequirementScaling",UIName="Requirement Scaling",UIDesc="Scales the current perk requirments."))
    WebConfigs.Add((PropType=0,PropName="ForcedMaxPlayers",UIName="Server Max Players",UIDesc="A forced max players value of the server (0 = use standard KF2 setting)"))
    WebConfigs.Add((PropType=0,PropName="StatAutoSaveWaves",UIName="Stat Auto-Save Waves",UIDesc="How often should stats be auto-saved (1 = every wave, 2 = every second wave etc)"))
    WebConfigs.Add((PropType=0,PropName="MinPerkLevel",UIName="Min Perk Level",UIDesc="Minimum level for perks."))
    WebConfigs.Add((PropType=0,PropName="MaxPerkLevel",UIName="Max Perk Level",UIDesc="Maximum level for perks."))
    WebConfigs.Add((PropType=1,PropName="bBroadcastPickups",UIName="Broadcast Pickups",UIDesc="Broadcast a message when a player picks up another players weapons."))
    WebConfigs.Add((PropType=1,PropName="bDisableGameplayChanges",UIName="Disable Gameplay Changes",UIDesc="Disable most of the gameplay changes and enable a more KF2 like experience."))
    WebConfigs.Add((PropType=1,PropName="bDisableGunslinger",UIName="Disable Gunslinger Perk",UIDesc="Disables the Gunslinger perk from being added when bDisableGameplayChanges is true."))
    WebConfigs.Add((PropType=1,PropName="bDisableSWAT",UIName="Disable SWAT Perk",UIDesc="Disables the SWAT perk from being added when bDisableGameplayChanges is true."))
    WebConfigs.Add((PropType=1,PropName="bNoEDARs",UIName="Disable EDAR Spawns",UIDesc="Prevents EDARs from spawning in regular gameplay."))
    WebConfigs.Add((PropType=1,PropName="bNoGasCrawler",UIName="Disable Gas Crawler Spawns",UIDesc="Prevents Gas Crawlers from spawning in regular gameplay."))
    WebConfigs.Add((PropType=1,PropName="bNoRioter",UIName="Disable Rioter Spawns",UIDesc="Prevents Rioters from spawning in regular gameplay."))
    WebConfigs.Add((PropType=1,PropName="bNoGorefiends",UIName="Disable Gorefiend Spawns",UIDesc="Prevents Gorefiends from spawning in regular gameplay."))
    WebConfigs.Add((PropType=1,PropName="bEnableTraderSpeed",UIName="Enable Fast Movment During Trader Time",UIDesc="Enables moving much faster during trader time."))
    WebConfigs.Add((PropType=1,PropName="bDisableUpgradeSystem",UIName="Disable Upgrade System",UIDesc="Disables the weapon upgrade system."))
    WebConfigs.Add((PropType=1,PropName="bEnabledVisibleSpectators",UIName="Enable Visible Spectators",UIDesc="Enables the Visible Spectator system."))
    WebConfigs.Add((PropType=0,PropName="SpectatorRefireRate",UIName="Spectator Fire Rate",UIDesc="Sets the time that a sepctator can fire his projectile."))
    WebConfigs.Add((PropType=0,PropName="SpectatorZapDamage",UIName="Spectator Zap Damage",UIDesc="How much damage the Zap projectile from Spectators do."))
    WebConfigs.Add((PropType=0,PropName="SpectatorHealAmount",UIName="Spectator Heal Amount",UIDesc="How much the Spectator heal projectile will heal the player."))
    WebConfigs.Add((PropType=0,PropName="ZEDReplacmentTable",UIName="ZED Replacment Table",UIDesc="What table to use for replacing the ZED spawns."))
    WebConfigs.Add((PropType=0,PropName="GlobalMaxMonsters",UIName="Global Max Monsters",UIDesc="Make monsters for maps not present within the MapInfo array"))
    WebConfigs.Add((PropType=0,PropName="GlobalEventName",UIName="Global Event Name",UIDesc="Name of the event used for maps not present within the MapInfo array"))
    WebConfigs.Add((PropType=2,PropName="Perks",UIName="Perk Classes",UIDesc="List of perks players can play as (careful with removing them, because any perks removed will permanently delete the gained XP for every player for that perk)!",NumElements=-1))
    WebConfigs.Add((PropType=2,PropName="CustomCharacters",UIName="Custom Characters",UIDesc="List of custom characters for this server (prefix with * to mark as admin character).",NumElements=-1))
    WebConfigs.Add((PropType=2,PropName="TraderInventory",UIName="Custom Trader Inventory",UIDesc="List of custom inventory to add to trader (must be KFWeaponDefinition class).",NumElements=-1))
    WebConfigs.Add((PropType=2,PropName="TraderWeaponReplacments",UIName="Trader Inventory Replacments",UIDesc="Allows replacing items inside of the current trader inventory.",NumElements=-1))
    WebConfigs.Add((PropType=2,PropName="MapTypes",UIName="Map Types",UIDesc="Define the event type and max monsters for certain maps.",NumElements=-1))
    WebConfigs.Add((PropType=3,PropName="ServerMOTD",UIName="MOTD",UIDesc="Message of the Day"))
   
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedClot_Cyst', Replacment=class'KFClassicMode.ClassicPawn_ZedClot_Alpha'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedClot_Alpha', Replacment=class'KFClassicMode.ClassicPawn_ZedClot_Alpha'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedClot_AlphaKing', Replacment=class'KFClassicMode.ClassicPawn_ZedClot_Alpha'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedClot_Slasher', Replacment=class'KFClassicMode.ClassicPawn_ZedClot_Alpha'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedCrawler', Replacment=class'KFClassicMode.ClassicPawn_ZedCrawler'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedGorefast', Replacment=class'KFClassicMode.ClassicPawn_ZedGorefast'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedStalker', Replacment=class'KFClassicMode.ClassicPawn_ZedStalker'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedScrake', Replacment=class'KFClassicMode.ClassicPawn_ZedScrake'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedFleshpound', Replacment=class'KFClassicMode.ClassicPawn_ZedFleshpound'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedFleshpoundMini', Replacment=class'KFClassicMode.ClassicPawn_ZedScrake'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedBloat', Replacment=class'KFClassicMode.ClassicPawn_ZedBloat'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedSiren', Replacment=class'KFClassicMode.ClassicPawn_ZedSiren'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedHusk', Replacment=class'KFClassicMode.ClassicPawn_ZedHusk'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedPatriarch', Replacment=class'KFClassicMode.ClassicPawn_ZedPatriarch'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedHans', Replacment=class'KFClassicMode.ClassicPawn_ZedPatriarch'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedBloatKing', Replacment=class'KFClassicMode.ClassicPawn_ZedPatriarch'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedFleshpoundKing', Replacment=class'KFClassicMode.ClassicPawn_ZedPatriarch'))
    AIClassList.Add((Original=class'KFGameContent.KFPawn_ZedMatriarch', Replacment=class'KFClassicMode.ClassicPawn_ZedPatriarch'))
    
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Pistol_9mm', ReplacmentClass=class'KFClassicMode.ClassicWeap_Pistol_9mm'))
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Pistol_Dual9mm', ReplacmentClass=class'KFClassicMode.ClassicWeap_Pistol_Dual9mm'))
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Blunt_Crovel', ReplacmentClass=class'KFClassicMode.ClassicWeap_Blunt_Crovel'))
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_GrenadeLauncher_HX25', ReplacmentClass=class'KFClassicMode.ClassicWeap_GrenadeLauncher_HX25'))     
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Pistol_Colt1911', ReplacmentClass=class'KFClassicMode.ClassicWeap_Pistol_Colt1911'))           
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Pistol_Medic', ReplacmentClass=class'KFClassicMode.ClassicWeap_Pistol_Medic'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Rifle_Winchester1894', ReplacmentClass=class'KFClassicMode.ClassicWeap_Rifle_Winchester1894'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Shotgun_MB500', ReplacmentClass=class'KFClassicMode.ClassicWeap_Shotgun_MB500'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_SMG_MP7', ReplacmentClass=class'KFClassicMode.ClassicWeap_SMG_MP7'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Pistol_Flare', ReplacmentClass=class'KFClassicMode.ClassicWeap_Pistol_Flare'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Pistol_Deagle', ReplacmentClass=class'KFClassicMode.ClassicWeap_Pistol_Deagle'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_AssaultRifle_Bullpup', ReplacmentClass=class'KFClassicMode.ClassicWeap_AssaultRifle_Bullpup'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Thrown_C4', ReplacmentClass=class'KFClassicMode.ClassicWeap_Thrown_C4'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_GrenadeLauncher_M79', ReplacmentClass=class'KFClassicMode.ClassicWeap_GrenadeLauncher_M79'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_SMG_Medic', ReplacmentClass=class'KFClassicMode.ClassicWeap_SMG_Medic'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Shotgun_DragonsBreath', ReplacmentClass=class'KFClassicMode.ClassicWeap_Shotgun_DragonsBreath'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Rifle_CenterfireMB464', ReplacmentClass=class'KFClassicMode.ClassicWeap_Rifle_CenterfireMB464'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Bow_Crossbow', ReplacmentClass=class'KFClassicMode.ClassicWeap_Bow_Crossbow'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_SMG_MP5RAS', ReplacmentClass=class'KFClassicMode.ClassicWeap_SMG_MP5RAS'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Revolver_SW500', ReplacmentClass=class'KFClassicMode.ClassicWeap_Revolver_SW500'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Shotgun_Nailgun', ReplacmentClass=class'KFClassicMode.ClassicWeap_Shotgun_Nailgun'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Shotgun_DoubleBarrel', ReplacmentClass=class'KFClassicMode.ClassicWeap_Shotgun_DoubleBarrel'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Shotgun_HZ12', ReplacmentClass=class'KFClassicMode.ClassicWeap_Shotgun_HZ12'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Edged_Katana', ReplacmentClass=class'KFClassicMode.ClassicWeap_Edged_Katana'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_AssaultRifle_AK12', ReplacmentClass=class'KFClassicMode.ClassicWeap_AssaultRifle_AK12'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Shotgun_Medic', ReplacmentClass=class'KFClassicMode.ClassicWeap_Shotgun_Medic'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Shotgun_M4', ReplacmentClass=class'KFClassicMode.ClassicWeap_Shotgun_M4'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Rifle_M14EBR', ReplacmentClass=class'KFClassicMode.ClassicWeap_Rifle_M14EBR'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_SMG_P90', ReplacmentClass=class'KFClassicMode.ClassicWeap_SMG_P90'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_SMG_Mac10', ReplacmentClass=class'KFClassicMode.ClassicWeap_SMG_Mac10'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Flame_Flamethrower', ReplacmentClass=class'KFClassicMode.ClassicWeap_Flame_Flamethrower'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_AssaultRifle_M16M203', ReplacmentClass=class'KFClassicMode.ClassicWeap_AssaultRifle_M16M203'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_SMG_HK_UMP', ReplacmentClass=class'KFClassicMode.ClassicWeap_SMG_HK_UMP'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Edged_Zweihander', ReplacmentClass=class'KFClassicMode.ClassicWeap_Edged_Zweihander'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Shotgun_AA12', ReplacmentClass=class'KFClassicMode.ClassicWeap_Shotgun_AA12'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Shotgun_ElephantGun', ReplacmentClass=class'KFClassicMode.ClassicWeap_Shotgun_ElephantGun'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_AssaultRifle_SCAR', ReplacmentClass=class'KFClassicMode.ClassicWeap_AssaultRifle_SCAR'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_LMG_Stoner63A', ReplacmentClass=class'KFClassicMode.ClassicWeap_LMG_Stoner63A'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_AssaultRifle_Medic', ReplacmentClass=class'KFClassicMode.ClassicWeap_AssaultRifle_Medic'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_SMG_Kriss', ReplacmentClass=class'KFClassicMode.ClassicWeap_SMG_Kriss'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_RocketLauncher_RPG7', ReplacmentClass=class'KFClassicMode.ClassicWeap_RocketLauncher_RPG7'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_RocketLauncher_Seeker6', ReplacmentClass=class'KFClassicMode.ClassicWeap_RocketLauncher_Seeker6'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_HuskCannon', ReplacmentClass=class'KFClassicMode.ClassicWeap_HuskCannon'))            
    DefaultWeaponReplacements.Add((OriginalClass=class'KFGameContent.KFWeap_Rifle_M99', ReplacmentClass=class'KFClassicMode.ClassicWeap_Rifle_M99'))                      
}
