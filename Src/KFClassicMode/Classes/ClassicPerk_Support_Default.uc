class ClassicPerk_Support_Default extends ClassicPerk_Support;

var array<sSuppliedPawnInfo> SuppliedPawnList;
var    array<Name> AdditionalOnPerkDTNames;

static function bool IsDamageTypeOnPerk( class<KFDamageType> KFDT )
{
    if( KFDT != none && default.AdditionalOnPerkDTNames.Find( KFDT.name ) != INDEX_NONE )
    {
        return true;
    }

    return super.IsDamageTypeOnPerk( KFDT );
}

simulated function float GetZedTimeModifier( KFWeapon W )
{
    local name StateName;
    StateName = W.GetStateName();

    if( IsWeaponOnPerk( W,, self.class ) && CouldBarrageActive() && ZedTimeModifyingStates.Find( StateName ) != INDEX_NONE )
    {
        return 0.9f;
    }

    return 0.f;
}

function bool IsBarrageActive()
{
    return CouldBarrageActive() && WorldInfo.TimeDilation < 1.f;
}

function bool IsTightChokeActive()
{
    return CurrentVetLevel >= (MaximumLevel * 0.5f);
}

simulated function bool CouldBarrageActive()
{
    return CurrentVetLevel == MaximumLevel;
}

simulated function float GetTightChokeModifier()
{ 
    return IsTightChokeActive() ? 0.5f : Super.GetTightChokeModifier();
}

simulated function ResetSupplier()
{
    if( MyPRI != none && IsSupplierActive() )
    {
        if( SuppliedPawnList.Length > 0 )
        {
            SuppliedPawnList.Remove( 0, SuppliedPawnList.Length );
        }

        MyPRI.PerkSupplyLevel = IsResupplyActive() ? 2 : 1;

        if( InteractionTrigger != none )
        {
            InteractionTrigger.Destroy();
            InteractionTrigger = none;
        }

        if( CheckOwnerPawn() )
        {
            InteractionTrigger = Spawn( class'KFUsablePerkTrigger', OwnerPawn,, OwnerPawn.Location, OwnerPawn.Rotation,, true );
            InteractionTrigger.SetBase( OwnerPawn );
            InteractionTrigger.SetInteractionIndex( IMT_ReceiveAmmo );
            OwnerPC.SetPendingInteractionMessage();
        }
    }
    else if( InteractionTrigger != none )
    {
        InteractionTrigger.Destroy();
    }
}

simulated function Interact( KFPawn_Human KFPH )
{
    local KFWeapon KFW;
    local int Idx, MagCount;
    local KFPlayerController KFPC;
    local KFPlayerReplicationInfo UserPRI, OwnerPRI;
    local bool bCanSupplyAmmo, bCanSupplyArmor;
    local bool bReceivedAmmo, bReceivedArmor;
    local sSuppliedPawnInfo SuppliedPawnInfo;
    
    if( !IsSupplierActive() )
    {
        return;
    }

    bCanSupplyAmmo = true;
    bCanSupplyArmor = true;
    Idx = SuppliedPawnList.Find( 'SuppliedPawn', KFPH );
    if( Idx != INDEX_NONE )
    {
        bCanSupplyAmmo = !SuppliedPawnList[Idx].bSuppliedAmmo;
        bCanSupplyArmor = !SuppliedPawnList[Idx].bSuppliedArmor;
        if( !bCanSupplyAmmo && !bCanSupplyArmor )
        {
            return;
        }
    }

    if( bCanSupplyAmmo )
    {
        foreach KFPH.InvManager.InventoryActors( class'KFWeapon', KFW )
        {
            if( KFW.DenyPerkResupply() )
            {
                continue;
            }

            MagCount = Max( KFW.InitialSpareMags[0] / 1.5, 1 ); // 3, 1
            bReceivedAmmo = (KFW.AddAmmo( MagCount * KFW.MagazineCapacity[0] * (IsResupplyActive() ? 1.3f : 1.0f) ) > 0 ) ? true : bReceivedAmmo;

            if( KFW.CanRefillSecondaryAmmo() )
            {
                bReceivedAmmo = (KFW.AddSecondaryAmmo( Max(KFW.AmmoPickupScale[1] * (IsResupplyActive() ? 1.3f : 1.0f) * KFW.MagazineCapacity[1], 1) ) > 0) ? true : bReceivedAmmo;
            }
        }
    }
    
    if( bCanSupplyArmor && IsResupplyActive() && KFPH.Armor != KFPH.GetMaxArmor() )
    {
        KFPH.AddArmor( KFPH.MaxArmor * GetSkillValue( PerkSkills[ESupportResupply] ) );
        bReceivedArmor = true;
    }

    if( bReceivedArmor || bReceivedAmmo )
    {
        if( Idx == INDEX_NONE )
        {
            SuppliedPawnInfo.SuppliedPawn = KFPH;
            SuppliedPawnInfo.bSuppliedAmmo = bReceivedAmmo;
            SuppliedPawnInfo.bSuppliedArmor = bReceivedArmor;
            Idx = SuppliedPawnList.Length;
            SuppliedPawnList.AddItem( SuppliedPawnInfo );
        }
        else
        {
            SuppliedPawnList[Idx].bSuppliedAmmo = SuppliedPawnList[Idx].bSuppliedAmmo || bReceivedAmmo;
            SuppliedPawnList[Idx].bSuppliedArmor = SuppliedPawnList[Idx].bSuppliedArmor || bReceivedArmor;
        }

        if( Role == ROLE_Authority )
        {
            KFPC = KFPlayerController( KFPH.Controller );
            if( bReceivedAmmo )
            {
                OwnerPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', bReceivedArmor ? GMT_GaveAmmoAndArmorTo : GMT_GaveAmmoTo, KFPC.PlayerReplicationInfo );
                KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', bReceivedArmor ? GMT_ReceivedAmmoAndArmorFrom : GMT_ReceivedAmmoFrom, OwnerPC.PlayerReplicationInfo );
            }
            else if( bReceivedArmor )
            {
                OwnerPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_GaveArmorTo, KFPC.PlayerReplicationInfo );
                KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_ReceivedArmorFrom, OwnerPC.PlayerReplicationInfo );
            }

            UserPRI = KFPlayerReplicationInfo( KFPC.PlayerReplicationInfo );
            OwnerPRI = KFPlayerReplicationInfo( OwnerPC.PlayerReplicationInfo );
            if( UserPRI != none && OwnerPRI != none )
            {
                UserPRI.MarkSupplierOwnerUsed( OwnerPRI, SuppliedPawnList[Idx].bSuppliedAmmo, SuppliedPawnList[Idx].bSuppliedArmor );
            }
        }
    }
    else if( Role == ROLE_Authority )
    {
        KFPC = KFPlayerController( KFPH.Controller );
        if( IsResupplyActive() )
        {
            KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_AmmoAndArmorAreFull, OwnerPC.PlayerReplicationInfo );
        }
        else
        {
            KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_AmmoIsFull, OwnerPC.PlayerReplicationInfo );            
        }
    }
}

simulated function bool CanInteract( KFPawn_Human MyKFPH )
{
    local int Idx;

    if( IsSupplierActive() )
    {
        Idx = SuppliedPawnList.Find( 'SuppliedPawn', MyKFPH );
        if( Idx == INDEX_NONE )
        {
            return true;
        }

        return !SuppliedPawnList[Idx].bSuppliedAmmo;
    }
    
    return Super.CanInteract(MyKFPH);
}

function bool CanRepairDoors()
{
    return true;
}

simulated function bool IsSupplierActive()
{
    return true;
}

simulated function bool IsResupplyActive()
{
    return true;
}

function OnWaveStart()
{
    Super.OnWaveStart();
    ResetSupplier();
}

simulated function PlayerDied()
{
    Super.PlayerDied();

    if( InteractionTrigger != None )
    {
        InteractionTrigger.DestroyTrigger();
    }
}

simulated protected event PostSkillUpdate()
{
    Super(ClassicPerk_Base).PostSkillUpdate();
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
    return Super(ClassicPerk_Base).GetWeaponDef(Level);
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
    ReplaceText(S,"%s",GetPercentStr(default.WeldingProficiency, Level));
    ReplaceText(S,"%a",GetPercentStr(default.PenetrationPower, Level));
    ReplaceText(S,"%m",GetPercentStr(default.Ammo, Level));
    ReplaceText(S,"%t",string(int(GetPassiveValue( default.Weight, Level ))));

    if( IsBarrageActive() )
    {
        S = S $ "|Can fire in realtime during ZED Time";
    }
    
    if( IsTightChokeActive() )
    {
        S = S $ "|Decrease spread by up to 50%";
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
    PrimaryWeaponDef=class'KFWeapDef_MB500'
    
    SecondaryWeaponPaths.Empty
    SecondaryWeaponPaths.Add(class'KFWeapDef_9mm')
    
    KnifeWeaponDef=class'KFWeapDef_Knife_Support'
    GrenadeWeaponDef=class'KFWeapDef_Grenade_Support'
    
    InteractIcon=Texture2D'UI_World_TEX.Support_Supplier_HUD'
    
    AutoBuyLoadOutPath=(class'KFWeapDef_MB500', class'KFWeapDef_DoubleBarrel', class'KFWeapDef_M4', class'KFWeapDef_AA12')
    
    ZedTimeModifyingStates(0)="WeaponFiring"
       ZedTimeModifyingStates(1)="WeaponBurstFiring"
       ZedTimeModifyingStates(2)="WeaponSingleFiring"
       ZedTimeModifyingStates(3)="WeaponAltFiring"
    
    AdditionalOnPerkDTNames(0)="KFDT_Ballistic_Shotgun_Medic"
       AdditionalOnPerkDTNames(1)="KFDT_Ballistic_DragonsBreath"
       AdditionalOnPerkDTNames(2)="KFDT_Ballistic_NailShotgun"
    
    Ammo=(Name="Ammo",Increment=0.01f,Rank=0,StartingValue=0.0,MaxValue=0.25f)
    WeldingProficiency=(Name="Welding Proficiency",Increment=0.03f,Rank=0,StartingValue=1.f,MaxValue=1.75f)
    WeaponDamage=(Name="Shotgun Damage",Increment=0.01f,Rank=0,StartingValue=0.f,MaxValue=0.25f)
    PenetrationPower=(Name="Shotgun Penetration",Increment=0.20,Rank=0,StartingValue=0.0f,MaxValue=5.0f)
    Weight=(Name="Carry Weight Increase",Increment=1.f,Rank=0,StartingValue=0.f,MaxValue=5.f)
    
    CustomLevelInfo="%d increase in shotgun damage|%s increased welding speed|%a better shotgun penetration|%m increase in max ammo|%t extra carry weight block(s)"
}
