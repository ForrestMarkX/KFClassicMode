Class ClassicMode extends KFMutator
    config(ClassicMode);
    
`include(KFClassicMode\Globals.uci);

struct AIReplacementS
{
    var class<KFPawn_Monster>   Original, Replacment;
    var bool                    bCheckChildren;
    
    structdefaultproperties
    {
        bCheckChildren=false
    }
};

struct PickupReplacmentStruct
{
    var class<KFWeapon>   OriginalClass, ReplacmentClass;
};

struct ItemList
{
    var DroppedPickup             Pickup;
    var PlayerReplicationInfo     PRI;
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

var array<ItemList>                     DroppedItemsList;

var array<AIReplacementS>               AIClassList;

var array< class<ClassicPerk_Base> >    LoadedPerks;

var bool                                bGameHasEnded, bCheckedWave;
var int                                 LastWaveNum, NumWaveSwitches;

var ClassicPlayerStat                   ServerStatLoader;
    
var array<Object>                       ExternalObjs;

var transient KFMapInfo                 KFMI;

var array<FCustomTraderItem>            CustomItemList;
var KFGFxObject_TraderItems             CustomTrader;

var array<FCustomCharEntry>             CustomCharacterList;

var KFEventHelper                       EventHelper;

var array<FWebAdminConfigInfo>          WebConfigs;

var config float                        RequirementScaling;
var config int                          ForcedMaxPlayers, StatAutoSaveWaves;
var config byte                         MinPerkLevel, MaxPerkLevel;
var config array<string>                Perks, CustomCharacters;
var globalconfig byte                   GlobalMaxMonsters;
var globalconfig bool                   bBroadcastPickups, bDisableMusic;
var globalconfig array<MapTypeInfo>     MapTypes;
var globalconfig name                   GlobalEventName;
var globalconfig string                 ServerMOTD;
var config array<string>                TraderInventory;
var config array<PickupReplacmentStruct> PickupReplacments;
var config int                          iVersionNumber;

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
    local array<string>             DefaultInventory;
    local array<STraderItem>        SaleItems;
    local class<KFWeaponDefinition> WepDef;
    local class<ClassicPerk_Base>   LoadedPerk;
    local string                    S, MyPerk, Item, Character, DefPath;
    local xVotingHandler            MV;
    local MapTypeInfo               MapInfo;
    local STraderItem               TraderItem;
    local AIReplacementS            AI;
    local KFGameInfo                KFGI;
    local KFCharacterInfo_Human     CH;
    local ObjectReferencer          OR;
    local Object                    O;
    local int                       j;
    local bool                      bLock;
    local PickupReplacmentStruct    PickupReplacement;
    
    Super.PostBeginPlay();
    
    if( bDeleteMe ) // This was a duplicate instance of the mutator.
        return;
    
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
    
    KFGI = KFGameInfo(WorldInfo.Game);
    if( KFGI != None )
    {
        KFGI.GameConductorClass = class'ClassicGameConductor';
        KFGI.DialogManagerClass = class'ClassicDialogManager';
        KFGI.KFGFxManagerClass = class'ClassicMoviePlayer_Manager';
        KFGI.CustomizationPawnClass = class'ClassicPawn_Customization';
        KFGI.bDisableTeamCollision = false;
    }
    
    WorldInfo.Spawn(class'ClientPerkRepLink', self);
    EventHelper = WorldInfo.Spawn(class'KFEventHelper', self);
    
    if( MinPerkLevel > MaxPerkLevel )
    {
        MinPerkLevel = MaxPerkLevel;
    }
    
    SetTimer(1, false, 'SetupClassicSystems');
    SetTimer(1, true, 'CheckWave');
    SetTimer(1, true, 'CheckC4');  
    
    if( ServerMOTD=="" )
    {
        ServerMOTD = "Message of the Day";
    }
    
    foreach AIClassList(AI)
    {
        AI.Replacment.static.PreloadContent();
    }
    
    if( iVersionNumber <= 0 )
    {
        SaleItems = class'KFGameReplicationInfo'.default.TraderItems.SaleItems;
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
            
        iVersionNumber = 1;
        
        SaveConfig();
    }
    
    if( iVersionNumber <= 1 )
    {
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Pistol_9mm';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Pistol_9mm';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Pistol_Dual9mm';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Pistol_Dual9mm';
        PickupReplacments.AddItem(PickupReplacement);        
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Blunt_Crovel';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Blunt_Crovel';
        PickupReplacments.AddItem(PickupReplacement);        
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_GrenadeLauncher_HX25';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_GrenadeLauncher_HX25';
        PickupReplacments.AddItem(PickupReplacement);        
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Pistol_Colt1911';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Pistol_Colt1911';
        PickupReplacments.AddItem(PickupReplacement);        
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Pistol_Medic';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Pistol_Medic';
        PickupReplacments.AddItem(PickupReplacement);        
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Rifle_Winchester1894';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Rifle_Winchester1894';
        PickupReplacments.AddItem(PickupReplacement);        
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Shotgun_MB500';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Shotgun_MB500';
        PickupReplacments.AddItem(PickupReplacement);        
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_SMG_MP7';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_SMG_MP7';
        PickupReplacments.AddItem(PickupReplacement);    
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Pistol_Flare';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Pistol_Flare';
        PickupReplacments.AddItem(PickupReplacement);    
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Pistol_Deagle';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Pistol_Deagle';
        PickupReplacments.AddItem(PickupReplacement);    
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_AssaultRifle_Bullpup';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_AssaultRifle_Bullpup';
        PickupReplacments.AddItem(PickupReplacement);    
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Thrown_C4';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Thrown_C4';
        PickupReplacments.AddItem(PickupReplacement);    
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_GrenadeLauncher_M79';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_GrenadeLauncher_M79';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_SMG_Medic';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_SMG_Medic';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Shotgun_DragonsBreath';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Shotgun_DragonsBreath';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Rifle_CenterfireMB464';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Rifle_CenterfireMB464';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Bow_Crossbow';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Bow_Crossbow';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_SMG_MP5RAS';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_SMG_MP5RAS';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Revolver_SW500';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Revolver_SW500';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Shotgun_Nailgun';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Shotgun_Nailgun';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Shotgun_DoubleBarrel';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Shotgun_DoubleBarrel';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Shotgun_HZ12';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Shotgun_HZ12';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Edged_Katana';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Edged_Katana';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_AssaultRifle_AK12';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_AssaultRifle_AK12';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Shotgun_Medic';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Shotgun_Medic';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Shotgun_M4';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Shotgun_M4';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Rifle_M14EBR';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Rifle_M14EBR';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_SMG_P90';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_SMG_P90';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_SMG_Mac10';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_SMG_Mac10';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Flame_Flamethrower';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Flame_Flamethrower';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_AssaultRifle_M16M203';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_AssaultRifle_M16M203';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_SMG_HK_UMP';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_SMG_HK_UMP';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Edged_Zweihander';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Edged_Zweihander';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Shotgun_AA12';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Shotgun_AA12';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Shotgun_ElephantGun';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Shotgun_ElephantGun';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_AssaultRifle_SCAR';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_AssaultRifle_SCAR';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_LMG_Stoner63A';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_LMG_Stoner63A';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_AssaultRifle_Medic';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_AssaultRifle_Medic';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_SMG_Kriss';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_SMG_Kriss';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_RocketLauncher_RPG7';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_RocketLauncher_RPG7';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_RocketLauncher_Seeker6';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_RocketLauncher_Seeker6';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_HuskCannon';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_HuskCannon';
        PickupReplacments.AddItem(PickupReplacement);
        
        PickupReplacement.OriginalClass = class'KFGameContent.KFWeap_Rifle_M99';
        PickupReplacement.ReplacmentClass = class'KFClassicMode.ClassicWeap_Rifle_M99';
        PickupReplacments.AddItem(PickupReplacement);
        
        iVersionNumber = 2;
        
        SaveConfig();
    }
    
    if( iVersionNumber <= 2 )
    {
        bDisableMusic = false;
        iVersionNumber = 3;
        SaveConfig();    
    }
    
    if( iVersionNumber <= 3 )
    {
        TraderInventory.RemoveItem("KFGame.KFWeapDef_MKB42");
        TraderInventory.RemoveItem("KFGame.KFWeapDef_FNFal");
        TraderInventory.RemoveItem("KFGame.KFWeapDef_MedicRifleGrenadeLauncher");
        
        TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_MKB42");
        TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_FNFal");
        TraderInventory.AddItem("KFClassicMode.ClassicWeapDef_M7A3");
    
        iVersionNumber = 4;
        SaveConfig();    
    }
    
    foreach TraderInventory(Item)
    {
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
    
    KFMI = KFMapInfo(WorldInfo.GetMapInfo());
}

function InitMutator(string Options, out string ErrorMessage)
{
    local int i, j;
    
    Super.InitMutator( Options, ErrorMessage );
    
    SetTimer(0.1, false, nameOf(SetDifficultyInfo));
    
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
    
    if( WorldInfo.NetMode != NM_StandAlone )
    {
        SetTimer(0.1,false,'SpawnTeamChatProxies');
        SetTimer(0.125,false,'SetupWebAdmin');
    }
    
    if( !bDisableMusic )
    {
        WorldInfo.Game.Spawn(class'MusicGRI');
    }
}

function SpawnTeamChatProxies()
{
    local ClassicTeamChatProxy Proxy;
    local int i;
    
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
    local WebServer W;
    local WebAdmin A;
    local ClassicWebApp xW;
    local byte i;

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
    local string                     S, WeaponName, PlayerName;
    local bool                       Ret;
    local int                        SellPrice, Index;
    local byte                       ItemIndex;
    local KFGameReplicationInfo      GRI;
    local class<KFWeapon>            Weapon;
    local class<KFWeaponDefinition>  WeaponDef;
    local KFInventoryManager         InvMan;
    local PlayerController           PC;
    local PlayerReplicationInfo      PRI;
    local STraderItem                Item;
    
    Ret = Super.OverridePickupQuery(Other, ItemClass, Pickup, bAllowPickup);
    if( !bBroadcastPickups || Pickup.Instigator == None || Other == Pickup.Instigator || !Other.InvManager.HandlePickupQuery(ItemClass, Pickup) )
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
    else 
    {
        return Ret;
    }
        
    if( WeaponDef == None )
        return Ret;
        
    InvMan = KFInventoryManager( Other.InvManager );
    if( InvMan == None || !InvMan.CanCarryWeapon(Weapon) )
        return Ret;
        
    Index = DroppedItemsList.Find('Pickup', DroppedPickup(Pickup));
    if( Index != INDEX_NONE )
    {
        PRI = DroppedItemsList[Index].PRI;
        if( PRI != None )
        {
            PlayerName = PRI.GetHumanReadableName();
        }
        
        DroppedItemsList.Remove(Index, 1);
    }
        
    WeaponName = WeaponDef.static.GetItemName();
    SellPrice = InvMan.GetAdjustedSellPriceFor(Item);
    
    if( PlayerName == "" )
    {
        PlayerName = Pickup.Instigator.GetHumanReadableName();
        if( PlayerName == "" )
            return Ret;
    }

    S = "%p #{DEF}picked up %o's %w #{DEF}($%$#{DEF}).";
    S = Repl(S, "%p", "#{C00101}"$class'ClassicPlayerController'.static.StripColorMessage(Other.GetHumanReadableName()));
    S = Repl(S, "%o", "#{01C001}"$class'ClassicPlayerController'.static.StripColorMessage(PlayerName));
    S = Repl(S, "%w", "#{0160C0}"$WeaponName);
    S = Repl(S, "%$", "#{C0C001}"$SellPrice);
    
    foreach WorldInfo.AllControllers(class'PlayerController', PC)
    {
        PC.ClientMessage(S, 'Log');
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

    //KFGameReplicationInfo(WorldInfo.GRI).TraderDialogManagerClass = class'ClassicTraderDialogManager';
     
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
    
    SetupMapInfo();
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

function ScoreKill(Controller Killer, Controller Killed)
{
    if( KFPawn_Monster(Killed.Pawn)!=None && Killed.GetTeamNum()!=0 && Killer.bIsPlayer && Killer.GetTeamNum()==0 )
    {
        if( Killer.PlayerReplicationInfo!=None )
            BroadcastKillMessage(Killed.Pawn,Killer);
    }
    
    Super.ScoreKill(Killer, Killed);
}

final function BroadcastKillMessage( Pawn Killed, Controller Killer )
{
    local ClassicPlayerController E;

    if( Killer==None || Killer.PlayerReplicationInfo==None )
        return;

    if( KFPawn_Monster(Killed) != None && KFPawn_Monster(Killed).bLargeZed )
    {
        foreach WorldInfo.AllControllers(class'ClassicPlayerController',E)
        {
            E.ReceiveKillMessage(Killed.Class,true,Killer.PlayerReplicationInfo);
        }
    }
    else if( ClassicPlayerController(Killer)!=None )
        ClassicPlayerController(Killer).ReceiveKillMessage(Killed.Class);
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
    local KFProj_Thrown_C4 C4A;
    local int CurCount;
    local bool bZed;    
    local KFPawn_MOnster KFM;
    local KFWeap_Thrown_C4 C4WeaponOwner;
    
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
    if( KFGRI != None )
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
    local int     i, j;
    local bool    bShouldReplace;
    
    for( i=0; i<SpawnList.Length; i++ )
    {
        for( j=0; j<AIClassList.Length; j++ )
        {
            if( AIClassList[j].Replacment == None || AIClassList[j].Original == None )
                continue;
                
            if( AIClassList[j].bCheckChildren )
                bShouldReplace = ClassIsChildOf(SpawnList[i], AIClassList[j].Original);
            else bShouldReplace = (String(SpawnList[i].Name) == String(AIClassList[j].Original.Name));
                
            if( bShouldReplace )
                SpawnList[i] = AIClassList[j].Replacment;
        }
    }
}

function NotifyLogin(Controller NewPlayer)
{
    local ClassicPlayerReplicationInfo PRI;
    
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
        
    if( ClassicPlayerController(NewPlayer)!=None )
    {
        SendMOTD(ClassicPlayerController(NewPlayer));
        
        if( !bGameHasEnded )
            InitializePerks(ClassicPlayerController(NewPlayer));
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
    local ClassicPerkManager    PM;
    local ClassicPerk_Base      P;
    local int                   i;
    
    Other.OnSpectateChange = PlayerChangeSpec;
    
    PM = Other.PerkManager;
    PM.InitPerks();
     
    for( i=0; i<LoadedPerks.Length; ++i )
    {   
        P = Spawn(LoadedPerks[i],Other);
        if( P != None )
        {
            P.MinimumLevel = MinPerkLevel;
            P.MaximumLevel = MaxPerkLevel;
            
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
    local DroppedPickup Pickup;
    local KFPickupFactory_Item MapWeapon;
    local ItemList Item;
    
    if( BasicWebAdminUser(A) != None )
    {
        BasicWebAdminUser(A).PCClass = class'ClassicMessageSpectator';
        return true;
    }
    
    if( TeamChatProxy(A) != None && ClassicTeamChatProxy(A) == None )
    {
        return false;
    }
    
    Pickup = DroppedPickup(A);
    if( Pickup != None && Pickup.Instigator != None )
    {
        Item.Pickup = Pickup;
        Item.PRI = Pickup.Instigator.PlayerReplicationInfo;
        DroppedItemsList.AddItem(Item);
        
        return true;
    }
    
    MapWeapon = KFPickupFactory_Item(A);
    if( MapWeapon != None )
    {
        CheckPickupReplacment(MapWeapon);
        return true;
    }
    
    return KFMapObjective_RepairActors(A) == None || KFMapObjective_DoshHold(A) == None || KFMapObjective_AreaDefense(A) != None || KFMapObjective_ActivateTrigger(A) == None;
}

function CheckPickupReplacment(KFPickupFactory_Item Item)
{
    local int i, Index;
    
    for( i=0; i < PickupReplacments.Length; i++ )
    {
        Index = Item.ItemPickups.Find('ItemClass', PickupReplacments[i].OriginalClass);
        if( Index != INDEX_NONE )
        {
            Item.ItemPickups[Index].ItemClass = PickupReplacments[i].ReplacmentClass;
        }
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

final function MapTypeInfo ParseMapInfoString(string S)
{
    local MapTypeInfo Res;
    local int i;

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
        break;    
    case 'bBroadcastPickups':
        bBroadcastPickups = bool(Value);    
        break;
    case 'GlobalEventName':
        GlobalEventName = name(Value);        
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
    case 'MapTypes':
        UpdateMapInfoArray(MapTypes, ElementIndex, Value);
        break;
    default:
        return;
    }
    SaveConfig();
}

defaultproperties
{
    WebConfigs.Add((PropType=0,PropName="RequirementScaling",UIName="Requirement Scaling",UIDesc="Scales the current perk requirments."))
    WebConfigs.Add((PropType=0,PropName="ForcedMaxPlayers",UIName="Server Max Players",UIDesc="A forced max players value of the server (0 = use standard KF2 setting)"))
    WebConfigs.Add((PropType=0,PropName="StatAutoSaveWaves",UIName="Stat Auto-Save Waves",UIDesc="How often should stats be auto-saved (1 = every wave, 2 = every second wave etc)"))
    WebConfigs.Add((PropType=0,PropName="MinPerkLevel",UIName="Min Perk Level",UIDesc="Minimum level for perks."))
    WebConfigs.Add((PropType=0,PropName="MaxPerkLevel",UIName="Max Perk Level",UIDesc="Maximum level for perks."))
    WebConfigs.Add((PropType=1,PropName="bBroadcastPickups",UIName="Broadcast Pickups",UIDesc="Broadcast a message when a player picks up another players weapons."))
    WebConfigs.Add((PropType=0,PropName="GlobalMaxMonsters",UIName="Global Max Monsters",UIDesc="Make monsters for maps not present within the MapInfo array"))
    WebConfigs.Add((PropType=0,PropName="GlobalEventName",UIName="Global Event Name",UIDesc="Name of the event used for maps not present within the MapInfo array"))
    WebConfigs.Add((PropType=2,PropName="Perks",UIName="Perk Classes",UIDesc="List of perks players can play as (careful with removing them, because any perks removed will permanently delete the gained XP for every player for that perk)!",NumElements=-1))
    WebConfigs.Add((PropType=2,PropName="CustomCharacters",UIName="Custom Characters",UIDesc="List of custom characters for this server (prefix with * to mark as admin character).",NumElements=-1))
    WebConfigs.Add((PropType=2,PropName="TraderInventory",UIName="Custom Trader Inventory",UIDesc="List of custom inventory to add to trader (must be KFWeaponDefinition class).",NumElements=-1))
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
}
