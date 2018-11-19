class ClassicPerk_Firebug extends ClassicPerk_Base;

var const PerkSkill    WeaponDamage;
var const PerkSkill    WeaponReload;
var const PerkSkill    FireResistance;
var const PerkSkill    SpareAmmo;
var const PerkSkill    MagCapacity;

var PassiveInfo ArmorInfo;

function AddDefaultInventory( KFPawn P )
{
    Super.AddDefaultInventory(P);
    
    if ( CurrentVetLevel >= 6 )
    {
        KFPawn_Human(P).GiveMaxArmor();
    }
}

simulated function ModifyDamageGiven( out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx )
{
    local KFWeapon KFW;
    local float TempDamage;

    TempDamage = InDamage;

    if( DamageCauser != none )
    {
        KFW = GetWeaponFromDamageCauser( DamageCauser );
    }

    if( (KFW != none && IsWeaponOnPerk( KFW,, self.class )) || (DamageType != none && IsDamageTypeOnPerk( DamageType )) )
    {
        TempDamage += InDamage * GetPassiveValue( WeaponDamage, CurrentVetLevel);
    }

    InDamage = Round( TempDamage );
}

simulated function float GetReloadRateScale(KFWeapon KFW)
{
    if( IsWeaponOnPerk( KFW,, self.class ) )
    {
        return 1.f - GetPassiveValue( WeaponReload, CurrentVetLevel );
    }

    return 1.f;
}

function ModifyDamageTaken( out int InDamage, optional class<DamageType> DamageType, optional Controller InstigatedBy )
{
    local float TempDamage;

    if( InDamage <= 0 )
    {
        return;
    }

    TempDamage = InDamage;

    if( ClassIsChildOf( DamageType, class'KFDT_Fire' ) )
    {
        TempDamage *= 1 - GetPassiveValue( FireResistance, CurrentVetLevel );
    }

    InDamage = Round( TempDamage );
}

simulated function ModifyMaxSpareAmmoAmount( KFWeapon KFW, out int MaxSpareAmmo, optional const out STraderItem TraderItem, optional bool bSecondary=false )
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
        TempSpareAmmoAmount = MaxSpareAmmo;
        TempSpareAmmoAmount *= 1 + GetPassiveValue( SpareAmmo, CurrentVetLevel );
        MaxSpareAmmo = Round( TempSpareAmmoAmount );
    }
}

simulated function ModifyMagSizeAndNumber( KFWeapon KFW, out byte MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
    local float TempCapacity;

    TempCapacity = MagazineCapacity;

    if( IsWeaponOnPerk( KFW, WeaponPerkClass, self.class ) )
    {
        TempCapacity += MagazineCapacity * GetPassiveValue( MagCapacity, CurrentVetLevel );
    }

    MagazineCapacity = Round(TempCapacity);
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
    if( Level >= 5 )
    {
        return class'ClassicWeapDef_FlameThrower';
    }
    
    return None;
}

simulated static function array<PassiveInfo> GetPerkInfoStrings(int Level)
{
    local array<PassiveInfo> Infos;
    
    Infos = default.PassiveInfos;
    if( Level >= 6 )
    {
        Infos.AddItem(default.ArmorInfo);
    }
    
    return Infos;
}

simulated static function GetPassiveStrings( out array<string> PassiveValues, out array<string> Increments, byte Level )
{
    PassiveValues[0] = Round( GetPassiveValue( default.WeaponDamage, Level ) * 100 ) $ "%";
    PassiveValues[1] = Round( GetPassiveValue( default.WeaponReload, Level ) * 100 ) $ "%";
    PassiveValues[2] = ( Round( GetPassiveValue( default.FireResistance, Level ) * 100 ) + default.FireResistance.StartingValue ) $ "%";
    PassiveValues[3] = Round( GetPassiveValue( default.SpareAmmo, Level ) * 100 ) $ "%";
    PassiveValues[4] = Round( GetPassiveValue( default.MagCapacity, Level ) * 100 ) $ "%";
    
    Increments[0] = "[" @ Left( string( default.WeaponDamage.Increment * 100 ), InStr(string(default.WeaponDamage.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[1] = "[" @ Left( string( default.WeaponReload.Increment * 100 ), InStr(string(default.WeaponReload.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[2] = "[" @ Left( string( default.FireResistance.Increment * 100 ), InStr(string(default.FireResistance.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[3] = "[" @ Left( string( default.SpareAmmo.Increment * 100 ), InStr(string(default.SpareAmmo.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[4] = "[" @ Left( string( default.MagCapacity.Increment * 100 ), InStr(string(default.MagCapacity.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    
    if( Level >= 6 )
    {
        PassiveValues[5] = "";
        Increments[5] = "";
    }
}

simulated static function string GetCustomLevelInfo( byte Level )
{
    local string S;
    local class<KFWeaponDefinition> SpawnDef;

    S = default.CustomLevelInfo;

    ReplaceText(S,"%d",GetPercentStr(default.WeaponDamage, Level));
    ReplaceText(S,"%s",GetPercentStr(default.WeaponReload, Level));
    ReplaceText(S,"%a",GetPercentStr(default.FireResistance, Level));
    ReplaceText(S,"%m",GetPercentStr(default.SpareAmmo, Level));
    ReplaceText(S,"%b",GetPercentStr(default.MagCapacity, Level));
    ReplaceText(S,"%w",GetPercentStr(default.WeaponDiscount, Level));
    
    SpawnDef = GetWeaponDef(Level);
    if( Level >= 6 )
    {
        if( SpawnDef != None )
        {
            S = S $ "|Spawn with a " $ SpawnDef.static.GetItemName() $ " and Body Armor";
        }
        else
        {
            S = S $ "|Spawn with Body Armor";
        }
    }
    else if( SpawnDef != None )
    {
        S = S $ "|Spawn with a " $ SpawnDef.static.GetItemName();
    }

    return S;
}

DefaultProperties
{
    BasePerk=class'KFPerk_Firebug'
    
    EXPActions(0)="Dealing Firebug weapon damage"
    EXPActions(1)="Killing Crawlers with Firebug weapons"
    
    GrenadeWeaponDef=class'KFWeapDef_Grenade_Firebug'
    
    PassiveInfos(0)=(Title="Fire Damage")
    PassiveInfos(1)=(Title="Reload Speed")
    PassiveInfos(2)=(Title="Fire Resistance")
    PassiveInfos(3)=(Title="Spare Ammo")
    PassiveInfos(4)=(Title="Magazine Capacity")
    
    WeaponDamage=(Name="Weapon Damage",Increment=0.1f,Rank=0,StartingValue=0.f,MaxValue=2.f)
    WeaponReload=(Name="Weapon Reload Speed",Increment=0.008f,Rank=0,StartingValue=0.f,MaxValue=0.2f)
    FireResistance=(Name="Fire Resistance",Increment=0.1f,Rank=0,StartingValue=0.5f,MaxValue=1.f)
    SpareAmmo=(Name="Spare Ammo",Increment=0.1f,Rank=0,StartingValue=0.f,MaxValue=1.f)
    MagCapacity=(Name="Magazine Capacity",Increment=0.1f,Rank=0,StartingValue=0.f,MaxValue=1.f)
    
    ArmorInfo=(Title="Spawn with a combat vest",Description="You spawn with full armor")
    
    CustomLevelInfo="%d increase in fire damage|%s faster reload speed with perked weapons|%a resistence to fire damage|Carry %m more ammo for perked weapons|%b increase in magazine capacity for perked weapons|%w discount on flame weapons"
}