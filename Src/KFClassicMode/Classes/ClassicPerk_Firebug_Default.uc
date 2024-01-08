class ClassicPerk_Firebug_Default extends ClassicPerk_Firebug;

var const PerkSkill OwnFireResistance,StartingAmmo;

var float SnarePower;
var class<DamageType> SnareCausingDmgTypeClass;

function bool CouldBeZedShrapnel( class<KFDamageType> KFDT )
{
    return IsZedShrapnelActive() && IsDamageTypeOnPerk( KFDT );
}

simulated function bool IsFuseActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.25f);
}

simulated function bool IsRangeActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.25f);
}

simulated function bool IsZedShrapnelActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function bool IsNapalmActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function bool IsInfernoActive()
{
    return CanUseInferno() && WorldInfo.TimeDilation < 1.f;
}

simulated function bool CanUseInferno()
{
    return CurrentVetLevel == MaximumLevel;
}

simulated function bool GetIsUberAmmoActive( KFWeapon KFW )
{
    return IsWeaponOnPerk( KFW,, self.class ) && IsInfernoActive();
}

simulated function float GetZedTimeModifier( KFWeapon W )
{
    local name StateName;

    if( CanUseInferno() && IsWeaponOnPerk( W,, self.class ) )
    {
        StateName = W.GetStateName();
        if( ZedTimeModifyingStates.Find( StateName ) != INDEX_NONE )
        {
            return 0.9f;
        }
    }

    return 0.f;
}

simulated function float GetSnarePowerModifier( optional class<DamageType> DamageType, optional byte HitZoneIdx )
{
    if( IsInfernoActive() && IsDamageTypeOnPerk( class<KFDamageType>(DamageType) ) )
    {
        return default.SnarePower;
    }

    return 0.f;
}

function float GetDoTScalerAdditions(class<KFDamageType> KFDT)
{
    local float ScalarAdditions;

    if (IsDamageTypeOnPerk(KFDT))
    {
        if (IsFuseActive())
        {
            ScalarAdditions += 1.5f;
        }

        if (IsNapalmActive())
        {
            ScalarAdditions += 1.5f;
        }
    }

    return ScalarAdditions;
}

function ApplySkillsToPawn()
{
    Super.ApplySkillsToPawn();

    if( MyPRI != none )
    {
        MyPRI.bExtraFireRange = IsRangeActive();
        MyPRI.bSplashActive = true;
    }
}

simulated function ModifyDamageGiven( out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx )
{
    local KFWeapon KFW;
    local float TempDamage;
    
    Super.ModifyDamageGiven(InDamage, DamageCauser, MyKFPM, DamageInstigator, DamageType, HitZoneIdx);

    TempDamage = InDamage;
    
    if( DamageCauser != none )
    {
        KFW = GetWeaponFromDamageCauser( DamageCauser );
    }
    
    if( (KFW != none && IsWeaponOnPerk( KFW,, self.class )) || (DamageType != none && IsDamageTypeOnPerk( DamageType )) )
    {
        if( IsInfernoActive() )
        {
            TempDamage += InDamage * 0.5f;
        }
    }

    InDamage = Round( TempDamage );
}

function AddDefaultInventory( KFPawn P )
{
    Super(ClassicPerk_Base).AddDefaultInventory(P);
}

function ModifyDamageTaken( out int InDamage, optional class<DamageType> DamageType, optional Controller InstigatedBy )
{
    local float TempDamage;
    local PerkSkill UsedResistance;

    if( InDamage <= 0 )
    {
        return;
    }

    TempDamage = InDamage;

    if( ClassIsChildOf( DamageType, class'KFDT_Fire' ) )
    {
        UsedResistance = (InstigatedBy != none && InstigatedBy == OwnerPC) ? OwnFireResistance : FireResistance;
        TempDamage *= 1 - GetPassiveValue( UsedResistance, CurrentVetLevel );
    }

    InDamage = Round( TempDamage );
}


simulated function ModifyMagSizeAndNumber( KFWeapon KFW, out int MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
    Super(ClassicPerk_Base).ModifyMagSizeAndNumber(KFW, MagazineCapacity, WeaponPerkClass, bSecondary, WeaponClassname);
}

simulated function ModifyMaxSpareAmmoAmount( KFWeapon KFW, out int MaxSpareAmmo, optional const out STraderItem TraderItem, optional bool bSecondary=false )
{
    Super(ClassicPerk_Base).ModifyMaxSpareAmmoAmount(KFW, MaxSpareAmmo, TraderItem, bSecondary);
}

simulated function ModifySpareAmmoAmount( KFWeapon KFW, out int PrimarySpareAmmo, optional const out STraderItem TraderItem, optional bool bSecondary )
{
    local float TempSpareAmmoAmount;
    local array< class<KFPerk> > WeaponPerkClass;

    if( KFW == none )
    {
        WeaponPerkClass = TraderItem.AssociatedPerkClasses;
    }
    else
    {
        WeaponPerkClass = KFW.GetAssociatedPerkClasses();
    }

    if( IsWeaponOnPerk( KFW, WeaponPerkClass, self.class ) )
    {
        TempSpareAmmoAmount = PrimarySpareAmmo;
        TempSpareAmmoAmount *= 1 + GetStartingAmmoPercent( CurrentVetLevel );
        PrimarySpareAmmo = Round( TempSpareAmmoAmount );
    }
}

simulated static function float GetStartingAmmoPercent( int Level )
{
    return default.StartingAmmo.Increment * FFloor( float( Level ) / 5.f );
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
    return Super(ClassicPerk_Base).GetWeaponDef(Level);
}

simulated function float GetCostScaling(byte Level, optional STraderItem TraderItem, optional KFWeapon Weapon)
{
    return 1.f;
}

simulated static function array<PassiveInfo> GetPerkInfoStrings(int Level)
{
    return default.PassiveInfos;
}

simulated static function GetPassiveStrings( out array<string> PassiveValues, out array<string> Increments, byte Level )
{
    PassiveValues[0] = Round( GetPassiveValue( default.WeaponDamage, Level ) * 100 ) $ "%";
    PassiveValues[1] = Round( GetPassiveValue( default.WeaponReload, Level ) * 100 ) $ "%";
    PassiveValues[2] = ( Round( GetPassiveValue( default.FireResistance, Level ) * 100 ) + default.FireResistance.StartingValue ) $ "%";
    PassiveValues[3] = ( Round( GetPassiveValue( default.OwnFireResistance, Level ) * 100 ) + default.OwnFireResistance.StartingValue ) $ "%";
    PassiveValues[4] = Round( GetPassiveValue( default.StartingAmmo, Level ) * 100 ) $ "%";
    PassiveValues[5] = Round( GetPassiveValue( default.MagCapacity, Level ) * 100 ) $ "%";
    
    Increments[0] = "[" @ Left( string( default.WeaponDamage.Increment * 100 ), InStr(string(default.WeaponDamage.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[1] = "[" @ Left( string( default.WeaponReload.Increment * 100 ), InStr(string(default.WeaponReload.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[2] = "[" @ Left( string( default.FireResistance.Increment * 100 ), InStr(string(default.FireResistance.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[3] = "[" @ Left( string( default.OwnFireResistance.Increment * 100 ), InStr(string(default.OwnFireResistance.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[4] = "[" @ Left( string( default.StartingAmmo.Increment * 100 ), InStr(string(default.StartingAmmo.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[5] = "[" @ Left( string( default.MagCapacity.Increment * 100 ), InStr(string(default.MagCapacity.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    
    if( Level >= 6 )
    {
        PassiveValues[5] = "";
        Increments[5] = "";
    }
}

simulated function string GetCustomLevelInfo( byte Level )
{
    local string S;
    local class<KFWeaponDefinition> SpawnDef;

    S = default.CustomLevelInfo;

    ReplaceText(S,"%d",GetPercentStr(default.WeaponDamage, Level));
    ReplaceText(S,"%s",GetPercentStr(default.WeaponReload, Level));
    ReplaceText(S,"%a",GetPercentStr(default.FireResistance, Level));
    ReplaceText(S,"%o",GetPercentStr(default.OwnFireResistance, Level));
    ReplaceText(S,"%m",int(GetStartingAmmoPercent(Level)*100.f) $ "%");
    
    if( IsFuseActive() )
    {
        if( IsNapalmActive() )
            S = S $ "|Burn time is increased by 300%";
        else S = S $ "|Burn time is increased by 150%";
    }
    
    if( IsRangeActive() )
    {
        S = S $ "|Increased range on Caulk n' Burn, Flamethrower, and Microwave Gun";
    }
    
    if( IsZedShrapnelActive() )
    {
        S = S $ "|ZEDs have a chance to explode when killed by fire";
    }
    
    if( IsNapalmActive() )
    {
        S = S $ "|ZEDs on fire will set other ZEDs on fire from contact";
    }
    
    if( CanUseInferno() )
    {
        S = S $ "|Weapons have infinite ammo during ZED Time and fire in realtime";
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
    PrimaryWeaponDef=class'KFWeapDef_CaulkBurn'
    
    SecondaryWeaponPaths.Empty
    SecondaryWeaponPaths.Add(class'KFWeapDef_9mm')
    
    KnifeWeaponDef=class'KFWeapDef_Knife_Firebug'
    
    AutoBuyLoadOutPath=(class'KFWeapDef_CaulkBurn', class'KFWeapDef_DragonsBreath', class'KFWeapDef_FlameThrower', class'KFWeapDef_MicrowaveGun', class'KFWeapDef_MicrowaveRifle')
    
    SnarePower=100
    SnareCausingDmgTypeClass="KFDT_Fire_Ground"
    
    ZedTimeModifyingStates(0)="WeaponFiring"
       ZedTimeModifyingStates(1)="WeaponBurstFiring"
       ZedTimeModifyingStates(2)="WeaponSingleFiring"
       ZedTimeModifyingStates(3)="SprayingFire"
    ZedTimeModifyingStates(4)="HuskCannonCharge"
    
    WeaponDamage=(Name="Weapon Damage",Increment=0.008f,Rank=0,StartingValue=1.f,MaxValue=1.20) //1.25
    WeaponReload=(Name="Weapon Reload Speed",Increment=0.008f,Rank=0,StartingValue=0.f,MaxValue=0.20)
    FireResistance=(Name="Fire Resistance",Increment=0.02,Rank=0,StartingValue=0.3f,MaxValue=0.8f)
    OwnFireResistance=(Name="Own fire Resistance",Increment=0.03,Rank=0,StartingValue=0.25f,MaxValue=1.f)
    StartingAmmo=(Name="Starting Ammo",Increment=0.1,Rank=0,StartingValue=0.f,MaxValue=0.50)
    
    CustomLevelInfo="%d increase in fire damage|%s faster reload speed with perked weapons|%a resistence to fire damage|%o resistence to self fire damage|Carry %m more ammo for perked weapons"
}