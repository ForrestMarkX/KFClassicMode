class ClassicPerk_Sharpshooter extends ClassicPerk_Base;

var const PerkSkill FireSpeed;
var const PerkSkill ReloadSpeed;
var const PerkSkill Recoil;

struct HeadshotDamagetypes
{
    var    class<KFDamageType> DamageType;
    var    float HeadshotDamageMult;
};
var array<HeadshotDamagetypes> HeadshotDamageMultipliers;

var    array<Name>    AdditionalOnPerkWeaponNames;
var array<Name>    AdditionalOnPerkDTNames;

simulated function ModifyDamageGiven( out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx )
{
    local KFWeapon KFW;
    local float TempDamage;
    local int DamageTypeIdx;

    Super.ModifyDamageGiven(InDamage, DamageCauser, MyKFPM, DamageInstigator, DamageType, HitZoneIdx);
    
    TempDamage = InDamage;

    if( DamageCauser != none )
    {
        KFW = GetWeaponFromDamageCauser( DamageCauser );
    }

    if( (KFW != none && IsWeaponOnPerk( KFW,, self.class )) || (DamageType != none && IsDamageTypeOnPerk(DamageType)) )
    {
        if( MyKFPM != none && HitZoneIdx == HZI_HEAD )
        {
            DamageTypeIdx = HeadshotDamageMultipliers.Find('DamageType', DamageType);
            if( DamageTypeIdx != INDEX_NONE )
            {
                TempDamage *= HeadshotDamageMultipliers[DamageTypeIdx].HeadshotDamageMult;
            }
        }
    }

    InDamage = FCeil( TempDamage );
}

simulated function ModifyRateOfFire( out float InRate, KFWeapon KFW )
{
    if( IsWeaponOnPerk( KFW,, self.class ) )
    {
        InRate *= FMax(1 - GetPassiveValue(FireSpeed, CurrentVetLevel), 0.01);
    }
}

simulated function float GetReloadRateScale( KFWeapon KFW )
{    
    if( IsWeaponOnPerk( KFW,, self.class ) )
    {
        return 1.f - GetPassiveValue( ReloadSpeed, CurrentVetLevel );
    }
    
    return 1.f;
}

simulated function ModifyRecoil( out float CurrentRecoilModifier, KFWeapon KFW )
{
    if (IsWeaponOnPerk(KFW, , self.class))
    {
        CurrentRecoilModifier -= CurrentRecoilModifier * GetPassiveValue(Recoil, CurrentVetLevel);
    }    
}

static function bool IsDamageTypeOnPerk( class<KFDamageType> KFDT )
{
    if( KFDT != none && default.AdditionalOnPerkDTNames.Find( KFDT.name ) != INDEX_NONE )
    {
        return true;
    }

    return Super.IsDamageTypeOnPerk( KFDT );
}

static simulated function bool IsWeaponOnPerk( KFWeapon W, optional array < class<KFPerk> > WeaponPerkClass, optional class<KFPerk> InstigatorPerkClass, optional name WeaponClassName )
{
    if( W != none && default.AdditionalOnPerkWeaponNames.Find( W.class.name ) != INDEX_NONE )
    {
        return true;
    }
    else if (WeaponClassName != '' && default.AdditionalOnPerkWeaponNames.Find(WeaponClassName) != INDEX_NONE)
    {
        return true;
    }

    return Super.IsWeaponOnPerk( W, WeaponPerkClass, InstigatorPerkClass, WeaponClassName );
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
    if( Level == 5 )
    {
        return class'ClassicWeapDef_Winchester1894';
    }
    else if( Level >= 6 )
    {
        return class'ClassicWeapDef_Crossbow';
    }
    
    return None;
}

simulated static function GetPassiveStrings( out array<string> PassiveValues, out array<string> Increments, byte Level )
{
    PassiveValues[0] = Round((GetPassiveValue( default.WeaponDamage, Level ) + default.WeaponDamage.StartingValue) * 100) $ "%";
    PassiveValues[1] = Round(GetPassiveValue( default.FireSpeed, Level ) * 100) $ "%";
    PassiveValues[2] = Round(GetPassiveValue( default.ReloadSpeed, Level ) * 100) $ "%";
    PassiveValues[3] = Round(GetPassiveValue( default.Recoil, Level ) * 100) $ "%";

    Increments[0] = "[" @ Left( string( default.WeaponDamage.Increment * 100 ), InStr(string(default.WeaponDamage.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[1] = "[" @ Left( string( default.FireSpeed.Increment * 100 ), InStr(string(default.FireSpeed.Increment * 100), ".") + 2 )$ "% /" @ default.LevelString @ "]";
    Increments[2] = "[" @ Left( string( default.ReloadSpeed.Increment * 100 ), InStr(string(default.ReloadSpeed.Increment * 100), ".") + 2 )$ "% /" @ default.LevelString @ "]";
    Increments[3] = "[" @ Left( string( default.Recoil.Increment * 100 ), InStr(string(default.Recoil.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
}

simulated function string GetCustomLevelInfo( byte Level )
{
    local string S;
    local class<KFWeaponDefinition> SpawnDef;

    S = default.CustomLevelInfo;

    ReplaceText(S,"%d",GetPercentStr(default.WeaponDamage, Level));
    ReplaceText(S,"%s",GetPercentStr(default.FireSpeed, Level));
    ReplaceText(S,"%a",GetPercentStr(default.ReloadSpeed, Level));
    ReplaceText(S,"%m",GetPercentStr(default.Recoil, Level));
    ReplaceText(S,"%w",GetPercentStr(default.WeaponDiscount, Level));
    
    SpawnDef = GetWeaponDef(Level);
    if( SpawnDef != None )
    {
        S = S $ "|Spawn with a " $ SpawnDef.static.GetItemName();
    }

    return S;
}

simulated function GetPerkIcons(ObjectReferencer RepInfo)
{
    local int i;
    
    for (i = 0; i < OnHUDIcons.Length; i++)
    {
        OnHUDIcons[i].PerkIcon = Texture2D(RepInfo.ReferencedObjects[66]);
        OnHUDIcons[i].StarIcon = Texture2D(RepInfo.ReferencedObjects[28]);
    }
}

DefaultProperties
{
    BasePerk=class'KFPerk_Sharpshooter'
    
    AdditionalOnPerkWeaponNames(0)="ClassicWeap_Pistol_9mm"
    AdditionalOnPerkWeaponNames(1)="ClassicWeap_Pistol_Dual9mm"
    AdditionalOnPerkWeaponNames(2)="KFWeap_Revolver_Rem1858"
    AdditionalOnPerkWeaponNames(3)="ClassicWeap_Revolver_SW500"
    AdditionalOnPerkDTNames(0)="KFDT_Ballistic_9mm"
    AdditionalOnPerkDTNames(1)="KFDT_Ballistic_SW500"
    AdditionalOnPerkDTNames(2)="KFDT_Ballistic_Rem1858"
    
    HeadshotDamageMultipliers.Add((DamageType=class'KFDT_Piercing_Crossbow',HeadshotDamageMult=3.9f))
    HeadshotDamageMultipliers.Add((DamageType=class'KFDT_Ballistic_M14EBR',HeadshotDamageMult=2.15f))
    HeadshotDamageMultipliers.Add((DamageType=class'KFDT_Ballistic_Winchester',HeadshotDamageMult=1.9f))
    HeadshotDamageMultipliers.Add((DamageType=class'KFDT_Ballistic_M99',HeadshotDamageMult=2.15f))
    
    EXPActions(0)="Dealing Sharpshooter weapon damage"
    EXPActions(1)="Head shots with Sharpshooter weapons"
    
    PassiveInfos(0)=(Title="Headshot Damage")
    PassiveInfos(1)=(Title="Fire Speed")
    PassiveInfos(2)=(Title="Reload Speed")
    PassiveInfos(3)=(Title="Recoil")
    
    WeaponDamage=(Name="Sniper Weapon Damage",Increment=0.05,Rank=0,StartingValue=0.05,MaxValue=0.6f)
    FireSpeed=(Name="Fire Speed",Increment=0.01f,Rank=0,StartingValue=0.f,MaxValue=0.3f)
    ReloadSpeed=(Name="Reload Speed",Increment=0.025f,Rank=0,StartingValue=0.f,MaxValue=0.5f)
    Recoil=(Name="Recoil",Increment=0.1,Rank=0,StartingValue=0.f,MaxValue=0.5f)
    
    CustomLevelInfo="%d increase in headshot damage|%s faster firing speed with perked weapons|%a faster reload speed with perked weapons|%m reduced recoil with perked weapons|%w discount on sniper rifles"
}
