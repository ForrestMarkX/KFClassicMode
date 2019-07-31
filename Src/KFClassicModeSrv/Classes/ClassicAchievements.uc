// Original system created by Scary Ghost. Fixed up and improved by Forrest Mark X
class ClassicAchievements extends KFMutator
    dependson(SAReplicationInfo)
    config(ClassicMode);

var() config array<string> AchievementPackClassnames;
var() config string DataLinkClassname;

var private array<class<AchievementPack> > LoadedAchievementPacks;
var private DataLink DataLnk;

function PostBeginPlay() 
{
    local class<AchievementPack> LoadedPack;    
    local array<string> UniqueClassnames;
    local string S;    
    local class<DataLink> DataLinkClass;
  
    if (AchievementPackClassnames.Length == 0) 
    {
        AchievementPackClassnames.AddItem(PathName(class'TestStandardAchievementPack'));
    }
    
    foreach AchievementPackClassnames(S) 
    {
        class'Arrays'.static.UniqueInsert(UniqueClassnames, S);
    }
    
    foreach UniqueClassnames(S) 
    {
        LoadedPack = class<AchievementPack>(DynamicLoadObject(S, class'Class'));
        if( LoadedPack != None )
        {
            LoadedAchievementPacks.AddItem(LoadedPack);
        }
    }

    if (Len(DataLinkClassname) == 0) 
    {
        DataLnk = New(None) class'FileDataLink';
        DataLinkClassname = PathName(dataLnk.class);
    } 
    else 
    {
        DataLinkClass = class<DataLink>(DynamicLoadObject(DataLinkClassname, class'Class'));
        if( DataLinkClass == None ) 
        {
            DataLnk = New(None) class'FileDataLink';
        } 
        else 
        {
            DataLnk = New(None) DataLinkClass;
        }
    }

    SaveConfig();
}

function bool CheckReplacement(Actor Other) 
{
    local PlayerReplicationInfo PRI;
    local SAReplicationInfo SARI;

    if (PlayerReplicationInfo(Other) != none && Other.Owner != None && Other.Owner.IsA('PlayerController') && PlayerController(Other.Owner).bIsPlayer) 
    {
        PRI = PlayerReplicationInfo(Other);

        SARI = Spawn(class'SAReplicationInfo', PRI.Owner);
        SARI.DataLnk = DataLnk;
        SARI.AchievementPackClasses= LoadedAchievementPacks;
    }
    
    return Super.CheckReplacement(Other);
}

function NetDamage(int OriginalDamage, out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
{
    local SAReplicationInfo SARI;
    local HealthWatcher Watcher;

    Super.NetDamage(OriginalDamage, Damage, Injured, instigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
    
    if( Injured.IsA('KFPawn_Monster') ) 
    {
        SARI = class'SAReplicationInfo'.static.FindSAri(instigatedBy);
        if( SARI != None ) 
        {
            Watcher.Health = Injured.Health;
            Watcher.Monster = KFPawn_Monster(Injured);
            Watcher.HeadHealth = Watcher.Monster.HitZones[HZI_HEAD].GoreHealth;
            Watcher.DamageTypeClass = DamageType;
            
            SARI.DamagedZeds.AddItem(Watcher);
        }
    }
}

function bool OverridePickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup, out byte bAllowPickup) 
{
    local SAReplicationInfo SARI;
    local array<AchievementPack> AchievementPacks;
    local AchievementPack Ach;
    local bool Ret;

    Ret = Super.OverridePickupQuery(Other, ItemClass, Pickup, bAllowPickup);
    
    if( !Ret || (Ret && bAllowPickup != 0) )
    {
        SARI = class'SAReplicationInfo'.static.FindSAri(Other.Controller);
        if( SARI != None ) 
        {
            SARI.GetAchievementPacks(AchievementPacks);
            
            foreach AchievementPacks(Ach) 
            {
                Ach.PickedUpItem(Pickup);
            }
        }
    }
    
    return Ret;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) 
{
    local SAReplicationInfo SARI;
    local array<AchievementPack> AchievementPacks;
    local AchievementPack Ach;

    if( !Super.PreventDeath(Killed, Killer, damageType, HitLocation) ) 
    {
        if (Killed.IsA('KFPawn_Human')) 
        {
            SARI = class'SAReplicationInfo'.static.findSAri(Killed.Controller);
            if( SARI != None ) 
            {
                SARI.getAchievementPacks(AchievementPacks);
                foreach AchievementPacks(Ach) 
                {
                    Ach.Died(Killer, damageType);
                }
            }
        }
        else if (Killer.IsA('KFPlayerController')) 
        {
            SARI = class'SAReplicationInfo'.static.findSAri(Killer);
            
            if( SARI != None ) 
            {
                SARI.getAchievementPacks(AchievementPacks);
                if (Killed.IsA('KFPawn_Monster')) 
                {
                    foreach AchievementPacks(Ach) 
                    {
                        Ach.KilledMonster(Killed, DamageType);
                    }
                }
            }
        }
        
        return false;
    }
    
    return true;
}

function ModifyNextTraderIndex(out byte NextTraderIndex) 
{
    local KFGameReplicationInfo GRI;
    local SAReplicationInfo SARI;
    local array<AchievementPack> Packs;
    local AchievementPack Ach;

    Super.ModifyNextTraderIndex(NextTraderIndex);

    GRI = KFGameReplicationInfo(WorldInfo.Game.GameReplicationInfo);

    if( GRI != None ) 
    {
        foreach DynamicActors(class'SAReplicationInfo', SARI) 
        {
            SARI.GetAchievementPacks(Packs);
            foreach Packs(Ach) 
            {
                Ach.WaveStarted(GRI.WaveNum, GRI.WaveMax);
            }
        }
    }
}

function NotifyLogout(Controller Exiting) 
{
    local SAReplicationInfo SARI;
    local array<AchievementPack> Packs;

    Super.NotifyLogout(Exiting);

    SARI = class'SAReplicationInfo'.static.FindSAri(Exiting);
    SARI.getAchievementPacks(Packs);
    
    DataLnk.SaveAchievementState(PlayerController(SARI.Owner).PlayerReplicationInfo.UniqueId, Packs);
}
