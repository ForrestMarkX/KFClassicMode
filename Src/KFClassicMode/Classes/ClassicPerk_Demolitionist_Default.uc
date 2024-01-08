class ClassicPerk_Demolitionist_Default extends ClassicPerk_Demolitionist;

var array<KFPawn_Human> SuppliedPawnList;
var bool bUsedSacrifice;

var array<name> PassiveExtraAmmoIgnoredClassNames;
var array<name> ExtraAmmoIgnoredClassNames;
var array<name> OnlySecondaryAmmoWeapons;

simulated function bool ShouldRandSirenResist()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function bool CanExplosiveWeld()
{
    return true;
}

simulated function bool ShouldSacrifice()
{
    return (CurrentVetLevel > int(MaximumLevel * 0.25f) ? true : false) && !bUsedSacrifice;
}

function NotifyPerkSacrificeExploded()
{
    bUsedSacrifice = true;
}

simulated static function int GetExtraAmmo( int Level )
{
    return default.ExplosiveAmmo.Increment * FFloor( float( Level ) / 5.f );
}

simulated function Interact( KFPawn_Human KFPH )
{
    local KFInventoryManager KFIM;
    local KFPlayerController KFPC;
    local KFPlayerReplicationInfo OwnerPRI, UserPRI;
    local bool bReceivedGrenades;

    if( SuppliedPawnList.Find( KFPH ) != INDEX_NONE )
    {
        return;
    }

    KFIM = KFInventoryManager(KFPH.InvManager);
    if( KFIM != None )
    {
        bReceivedGrenades = KFIM.AddGrenades( 1 );
    }

    if( bReceivedGrenades )
    {
        SuppliedPawnList.AddItem( KFPH );

        KFPC = KFPlayerController(KFPH.Controller);
        if( KFPC != none )
        {
            OwnerPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_GaveGrenadesTo, KFPC.PlayerReplicationInfo );
            KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_ReceivedGrenadesFrom, OwnerPC.PlayerReplicationInfo );

            UserPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
            OwnerPRI = KFPlayerReplicationInfo(OwnerPC.PlayerReplicationInfo);
            if( UserPRI != none && OwnerPRI != none )
            {
                UserPRI.MarkSupplierOwnerUsed( OwnerPRI );
            }
        }
    }
    else
    {
        KFPC = KFPlayerController(KFPH.Controller);
        if( KFPC != None )
        {
            KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_AmmoIsFull, OwnerPC.PlayerReplicationInfo );
        }
    }
}

simulated function bool CanInteract( KFPawn_HUman MyKFPH )
{
    return SuppliedPawnList.Find( MyKFPH ) == INDEX_NONE;
}

simulated function ResetSupplier()
{
    if( MyPRI != None )
    {
        if( SuppliedPawnList.Length > 0 )
        {
            SuppliedPawnList.Remove( 0, SuppliedPawnList.Length );
        }

        MyPRI.PerkSupplyLevel = 1;

        if( InteractionTrigger != none )
        {
            InteractionTrigger.Destroy();
            InteractionTrigger = none;
        }

        if( CheckOwnerPawn() )
        {
            InteractionTrigger = Spawn( class'KFUsablePerkTrigger', OwnerPawn,, OwnerPawn.Location, OwnerPawn.Rotation,, true );
            InteractionTrigger.SetBase( OwnerPawn );
            InteractionTrigger.SetInteractionIndex( IMT_ReceiveGrenades );
            OwnerPC.SetPendingInteractionMessage();
        }
    }
    else if( InteractionTrigger != None )
    {
        InteractionTrigger.Destroy();
    }
}

static function PrepareExplosive( Pawn ProjOwner, KFProjectile Proj, optional float AuxRadiusMod = 1.0f, optional float AuxDmgMod = 1.0f )
{
    local KFPlayerReplicationInfo InstigatorPRI;
    local KFPlayerController KFPC;
    local KFPerk InstigatorPerk;

    if( ProjOwner != none )
    {
        if( Proj.bWasTimeDilated )
        {
            InstigatorPRI = KFPlayerReplicationInfo( ProjOwner.PlayerReplicationInfo );
            if( InstigatorPRI != none )
            {
                if( InstigatorPRI.bNukeActive && class'KFPerk_Demolitionist'.static.ProjectileShouldNuke(Proj) )
                {
                    Proj.ExplosionTemplate = class'KFPerk_Demolitionist'.static.GetNukeExplosionTemplate();
                    Proj.ExplosionTemplate.Damage = Proj.default.ExplosionTemplate.Damage * class'KFPerk_Demolitionist'.static.GetNukeDamageModifier() * AuxDmgMod;
                    Proj.ExplosionTemplate.DamageRadius = Proj.default.ExplosionTemplate.DamageRadius * class'KFPerk_Demolitionist'.static.GetNukeRadiusModifier() * AuxRadiusMod;
                    Proj.ExplosionTemplate.DamageFalloffExponent = Proj.default.ExplosionTemplate.DamageFalloffExponent;
                }
                else if( InstigatorPRI.bConcussiveActive && Proj.AltExploEffects != none )
                {
                    Proj.ExplosionTemplate.ExplosionEffects = Proj.AltExploEffects;
                    Proj.ExplosionTemplate.ExplosionSound = class'KFPerk_Demolitionist'.static.GetConcussiveExplosionSound();
                }
            }
        }

        if( ProjOwner.Role == ROLE_Authority )
        {
            KFPC = KFPlayerController( ProjOwner.Controller );
            if( KFPC != none )
            {
                InstigatorPerk = KFPC.GetPerk();
                Proj.ExplosionTemplate.DamageRadius *= InstigatorPerk.GetAoERadiusModifier() * AuxRadiusMod;
            }
        }
    }
}

function ApplySkillsToPawn()
{
    Super.ApplySkillsToPawn();

    if( MyPRI != None )
    {
        MyPRI.bNukeActive = IsNukeActive();
    }
}

simulated function float GetZedTimeModifier( KFWeapon W )
{
    local name StateName;

    StateName = W.GetStateName();
    if( IsProfessionalActive() && IsWeaponOnPerk( W,, self.class ) )
    {
        if( ZedTimeModifyingStates.Find( StateName ) != INDEX_NONE || W.HasAlwaysOnZedTimeResist() )
        {
            return 0.9f;
        }
    }

    return 0.f;
}

simulated function bool IsNukeActive()
{
    return CurrentVetLevel > int(MaximumLevel * 0.5f) ? true : false;
}

simulated function bool IsProfessionalActive()
{
    return CurrentVetLevel == MaximumLevel ? true : false;
}

simulated function bool ShouldNeverDud()
{
    return (IsNukeActive() || IsProfessionalActive()) && WorldInfo.TimeDilation < 1.f;
}

function AddDefaultInventory( KFPawn P )
{
    Super(ClassicPerk_Base).AddDefaultInventory(P);
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
    return Super(ClassicPerk_Base).GetWeaponDef(Level);
}

simulated protected event PostSkillUpdate()
{
    Super(ClassicPerk_Base).PostSkillUpdate();
}

simulated function ModifyMaxSpareAmmoAmount( KFWeapon KFW, out int MaxSpareAmmo, optional const out STraderItem TraderItem, optional bool bSecondary=false )
{
    Super(ClassicPerk_Base).ModifyMaxSpareAmmoAmount(KFW, MaxSpareAmmo, TraderItem, bSecondary);
}

simulated function ModifySpareAmmoAmount( KFWeapon KFW, out int PrimarySpareAmmo, optional const out STraderItem TraderItem, optional bool bSecondary=false )
{
    local array< class<KFPerk> > WeaponPerkClass;
    local bool bUsesAmmo;
    local name WeaponClassName;

    if( KFW == none )
    {
        WeaponPerkClass = TraderItem.AssociatedPerkClasses;
        bUsesAmmo = TraderItem.WeaponDef.static.UsesAmmo();
        WeaponClassName = TraderItem.ClassName;
    }
    else
    {
        WeaponPerkClass = KFW.GetAssociatedPerkClasses();
        bUsesAmmo = KFW.UsesAmmo();
        WeaponClassName = KFW.class.Name;
    }

    if( bUsesAmmo )
    {
        GivePassiveExtraAmmo( PrimarySpareAmmo, KFW, WeaponPerkClass, WeaponClassName, bSecondary );
    }
}

simulated function GivePassiveExtraAmmo( out int PrimarySpareAmmo, KFWeapon KFW, array< class<KFPerk> > WeaponPerkClass, name WeaponClassName, optional bool bSecondary=false )
{
    if( ShouldGiveOnlySecondaryAmmo( WeaponClassName ) && !bSecondary )
    {
        return;
    }

    if( IsWeaponOnPerk( KFW, WeaponPerkClass, self.Class ) && PassiveExtraAmmoIgnoredClassNames.Find( WeaponClassName ) == INDEX_NONE )
    {
        PrimarySpareAmmo += GetExtraAmmo( CurrentVetLevel );
    }
}

simulated function bool ShouldGiveOnlySecondaryAmmo( name WeaponClassName )
{
    return OnlySecondaryAmmoWeapons.Find( WeaponClassName ) != INDEX_NONE;
}

simulated function float GetCostScaling(byte Level, optional STraderItem TraderItem, optional KFWeapon Weapon)
{
    return 1.f;
}

simulated function string GetCustomLevelInfo( byte Level )
{
    local string S;
    local class<KFWeaponDefinition> SpawnDef;

    S = default.CustomLevelInfo;

    ReplaceText(S,"%d",GetPercentStr(default.WeaponDamage, Level));
    ReplaceText(S,"%s",GetPercentStr(default.ExplosiveResistance, Level));
    ReplaceText(S,"%a",int(GetExtraAmmo(Level)*100.f) $ "%");
    ReplaceText(S,"%m",GetPercentStr(default.AOERadius, Level));
    
    if( ShouldSacrifice() )
    {
        S = S $ "|When low on health causes an explosion";
    }
    
    if( ShouldRandSirenResist() )
    {
        S = S $ "|Grenades are resistent to siren screams";
    }
    
    if( IsNukeActive() )
    {
        S = S $ "|Explosives cause a nuke during ZED Time";
    }
    
    if( IsProfessionalActive() )
    {
        S = S $ "|Can fire in realtime and never dud during ZED Time";
    }
    
    SpawnDef = GetWeaponDef(Level);
    if( SpawnDef != None )
    {
        S = S $ "|Spawn with a " $ SpawnDef.static.GetItemName();
    }

    return S;
}

DefaultProperties
{
    PassiveExtraAmmoIgnoredClassNames(0)="KFProj_DynamiteGrenade"
    ExtraAmmoIgnoredClassNames(0)="KFProj_DynamiteGrenade"
    ExtraAmmoIgnoredClassNames(1)="KFWeap_Thrown_C4"
    OnlySecondaryAmmoWeapons(0)="KFWeap_AssaultRifle_M16M203"
    
       ZedTimeModifyingStates(0)="WeaponFiring"
       ZedTimeModifyingStates(1)="WeaponBurstFiring"
       ZedTimeModifyingStates(2)="WeaponSingleFiring"
       ZedTimeModifyingStates(3)="Reloading"
       ZedTimeModifyingStates(4)="WeaponSingleFireAndReload"
       ZedTimeModifyingStates(5)="FiringSecondaryState"
       ZedTimeModifyingStates(6)="AltReloading"
    ZedTimeModifyingStates(7)="WeaponThrowing"
    ZedTimeModifyingStates(8)="HuskCannonCharge"
    
    PrimaryWeaponDef=class'KFWeapDef_HX25'
    
    SecondaryWeaponPaths.Empty
    SecondaryWeaponPaths.Add(class'KFWeapDef_9mm')
    
    KnifeWeaponDef=class'KFWeapDef_Knife_Demo'
    GrenadeWeaponDef=class'KFWeapDef_Grenade_Demo'
    
    InteractIcon=Texture2D'UI_World_TEX.Demolitionist_Supplier_HUD'
    
    AutoBuyLoadOutPath=(class'KFWeapDef_HX25', class'KFWeapDef_M79', class'KFWeapDef_M16M203', class'KFWeapDef_RPG7', class'KFWeapDef_M32')
    
    WeaponDamage=(Name="Explosive Damage",Increment=0.01f,Rank=0,StartingValue=0.f,MaxValue=0.25)
    ExplosiveResistance=(Name="Explosive Resistance",Increment=0.02f,Rank=0,StartingValue=0.1f,MaxValue=0.6f)
    ExplosiveAmmo=(Name="Explosive Ammo",Increment=1.f,Rank=0,StartingValue=0.0f,MaxValue=5.f)
    AOERadius=(Name="AOE Radius",Increment=0.05f,Rank=0,StartingValue=0.f,MaxValue=0.5f)
    
    CustomLevelInfo="%d increased damage with explosive weapons|%s resistence to explosive damage|Carry %a more explosive weapon ammo|%m increase in explosive damage radius"
}
