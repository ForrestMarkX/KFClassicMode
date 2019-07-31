class SAReplicationInfo extends ReplicationInfo;

struct HealthWatcher 
{
    var int Health;
    var int HeadHealth;
    var class<DamageType> DamageTypeClass;
    var KFPawn_Monster Monster;
};
var array<HealthWatcher> DamagedZeds;

var array<class<AchievementPack> > AchievementPackClasses;
var DataLink DataLnk;

var private bool Initialized, SignalFire, SignalReload, SignalFragToss, SignalSwing, HandledGameEnded;
var private array<AchievementPack> AchievementPacks;

function Destroyed() 
{
    local AchievementPack Ach;

    foreach AchievementPacks(Ach) 
    {
        Ach.Destroy();
    }
    AchievementPacks.Length = 0;

    Super.Destroyed();
}

function PostBeginPlay() 
{
    SetTimer(0.5, true, 'CheckMonsterHealth');
}

simulated function Tick(float DeltaTime) 
{
    local MatchInfo Info;
    local KFPawn OwnerPawn;
    local bool WeaponIsFiring, WeaponIsReloading, WeaponIsSwinging, TossingFrag;
    local class<AchievementPack> Ach;
    local AchievementPack Pack;
    local PlayerController LocalController;
    local Name WeaponState;

    if (!Initialized) 
    {
        if (Role == ROLE_Authority) 
        {
            foreach AchievementPackClasses(Ach) 
            {
                AddAchievementPack(Spawn(Ach, Owner));
            }

            DataLnk.RetrieveAchievementState(PlayerController(Owner).PlayerReplicationInfo.UniqueId, AchievementPacks);
        }
        
        LocalController = GetALocalPlayerController();
        if (LocalController != None) 
        {
            SetOwner(LocalController);
            foreach DynamicActors(class'AchievementPack', Pack) 
            {
                AddAchievementPack(Pack);
            }
        }

        Initialized = true;
    }

    if (Role == ROLE_Authority) 
    {
        if (Owner == None) 
        {
            Destroy();
            return;
        }

        OwnerPawn = KFPawn(Controller(Owner).Pawn);

        if (OwnerPawn != None && OwnerPawn.Weapon != None) 
        {
            WeaponState = OwnerPawn.Weapon.GetStateName();
            WeaponIsFiring = WeaponState == 'WeaponSingleFiring' || WeaponState == 'WeaponFiring' || WeaponState == 'WeaponBurstFiring' || WeaponState == 'SprayingFire';
            
            if (!SignalFire && WeaponIsFiring) 
            {
                foreach AchievementPacks(Pack) 
                {
                    Pack.firedWeapon(OwnerPawn.Weapon);
                }
                SignalFire = true;
            } 
            else if (SignalFire && !WeaponIsFiring) 
            {
                foreach AchievementPacks(Pack) 
                {
                    Pack.stoppedFiringWeapon(OwnerPawn.Weapon);
                }
                SignalFire = false;
            }

            WeaponIsSwinging = WeaponState == 'MeleeAttackBasic' || WeaponState == 'MeleeChainAttacking' || WeaponState == 'MeleeHeavyAttacking';
            if (!SignalSwing && WeaponIsSwinging) 
            {
                foreach AchievementPacks(Pack) 
                {
                    Pack.SwungWeapon(OwnerPawn.Weapon);
                }
                SignalSwing= true;
            } 
            else if (SignalSwing && !WeaponIsSwinging) 
            {
                SignalSwing= false;
            }

            WeaponIsReloading = OwnerPawn.Weapon.IsInState('Reloading');
            if (!SignalReload && WeaponIsReloading) 
            {
                foreach AchievementPacks(Pack) 
                {
                    Pack.reloadedWeapon(OwnerPawn.Weapon);
                }
                SignalReload= true;
            } 
            else if (SignalReload && !WeaponIsReloading) 
            {
                SignalReload= false;
            }

            TossingFrag = OwnerPawn.Weapon.IsInState('GrenadeFiring');
            if (!SignalFragToss && TossingFrag) 
            {
                foreach AchievementPacks(Pack) 
                {
                    Pack.TossedGrenade(OwnerPawn.GetPerk().GetGrenadeClass());
                }
                SignalFragToss= true;
            } 
            else if (SignalFragToss && !TossingFrag) 
            {
                SignalFragToss= false;
            }
        }

        if (!HandledGameEnded && WorldInfo.Game.GameReplicationInfo.bMatchIsOver) 
        {
            HandledGameEnded = true;
            Info.MapName = WorldInfo.GetMapName(true);
            Info.Difficulty = KFGameReplicationInfo(WorldInfo.Game.GameReplicationInfo).GameDifficulty;
            Info.Length = KFGameReplicationInfo(WorldInfo.Game.GameReplicationInfo).GameLength;

            if (WorldInfo.Game.IsA('KFGameInfo')) 
            {
                Info.Result = KFGameInfo(WorldInfo.Game).GetLivingPlayerCount() <= 0 ? SA_MR_LOST : SA_MR_WON;
            } 
            else 
            {
                Info.Result = SA_MR_UNKNOWN;
            }

            foreach AchievementPacks(Pack) 
            {
                Pack.MatchEnded(Info);
            }
        }
    }
}

function CheckMonsterHealth() 
{
    local int i, End, Damage;
    local AchievementPack Ach;
    local bool Headshot;

    End = DamagedZeds.Length;
    while(i < End) 
    {
        if (DamagedZeds[i].Health != DamagedZeds[i].Monster.Health) 
        {
            Headshot = DamagedZeds[i].Monster.HitZones[HZI_HEAD].GoreHealth != DamagedZeds[i].headHealth;
            Damage = DamagedZeds[i].Health - DamagedZeds[i].Monster.Health;
            foreach AchievementPacks(Ach) 
            {
                Ach.DamagedMonster(Damage, DamagedZeds[i].Monster, DamagedZeds[i].DamageTypeClass, Headshot);
            }

            DamagedZeds.Remove(i, 1);
            End--;
        } 
        else 
        {
            i++;
        }
    }
}

simulated function AddAchievementPack(AchievementPack Pack) 
{
    local int i;
    
    for(i= 0; i < AchievementPacks.Length; i++) 
    {
        if (AchievementPacks[i] == Pack)
            return;
    }
    AchievementPacks[AchievementPacks.Length]= Pack;
}

simulated function getAchievementPacks(out array<AchievementPack> Packs) 
{
    local int i;
    
    for(i= 0; i < AchievementPacks.Length; i++) 
    {
        Packs[i]= AchievementPacks[i];
    }
}

static function SAReplicationInfo findSAri(Controller RepOwner) 
{
    local SAReplicationInfo RepInfo;

    if (RepOwner == None)
        return None;

    foreach RepOwner.DynamicActors(class'SAReplicationInfo', RepInfo)
    {
        if (RepInfo.Owner == RepOwner) 
        {
            return RepInfo;
        }
    }
 
    return None;
}

defaultproperties 
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
}