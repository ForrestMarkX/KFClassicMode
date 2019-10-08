class ClassicPerk_Sharpshooter_Default extends ClassicPerk_Sharpshooter;

var const PerkSkill WeaponSwitchSpeed;
var float CameraViewShakeScale;

static function bool IsDamageTypeOnPerk( class<KFDamageType> KFDT )
{
    if( KFDT != none && default.AdditionalOnPerkDTNames.Find( KFDT.name ) != INDEX_NONE )
    {
        return true;
    }

    return super.IsDamageTypeOnPerk( KFDT );
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

    return super.IsWeaponOnPerk( W, WeaponPerkClass, InstigatorPerkClass, WeaponClassName );
}

function float GetStunPowerModifier( optional class<DamageType> DamageType, optional byte HitZoneIdx )
{
    if( IsDamageTypeOnPerk(class<KFDamageType>(DamageType)) )
    {
        if( HitZoneIdx == HZI_Head && GetZTStunActive() )
        {
            return 4.f;
        }
    }

    return 0.f;
}

simulated function bool IsZTStunActive()
{
    return CurrentVetLevel == MaximumLevel;
}

simulated function bool GetZTStunActive()
{
    return IsZTStunActive() && WorldInfo.TimeDilation < 1.f;
}

simulated function bool GetIsHeadShotComboActive()
{ 
    return CurrentVetLevel >= (MaximumLevel * 0.5f); 
}

simulated function ModifyWeaponSwitchTime( out float ModifiedSwitchTime )
{
    ModifiedSwitchTime *= (1.f - GetPassiveValue(WeaponSwitchSpeed, CurrentVetLevel));
}

simulated function float GetCameraViewShakeModifier( KFWeapon OwnerWeapon )
{
    return static.GetCameraViewShakeScale();
}

simulated final static function float GetCameraViewShakeScale()
{
    return default.CameraViewShakeScale;
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
    ReplaceText(S,"%s",GetPercentStr(default.FireSpeed, Level));
    ReplaceText(S,"%a",GetPercentStr(default.ReloadSpeed, Level));
    ReplaceText(S,"%m",GetPercentStr(default.Recoil, Level));
    ReplaceText(S,"%w",GetPercentStr(default.WeaponSwitchSpeed, Level));
    
    if( GetIsHeadShotComboActive() )
    {
        S = S $ "|Getting headshots increases perked weapon damage";
    }
    
    if( IsZTStunActive() )
    {
        S = S $ "|Headshots have a chance to trigger ZED Time, can stun any ZED during that time";
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
    PrimaryWeaponDef=class'KFWeapDef_Winchester1894'
    SecondaryWeaponDef=class'KFWeapDef_9mm'
    KnifeWeaponDef=class'KFWeapDef_Knife_Sharpshooter'
    GrenadeWeaponDef=class'KFWeapDef_Grenade_Sharpshooter'
    
    AutoBuyLoadOutPath=(class'KFWeapDef_Winchester1894', class'KFWeapDef_Crossbow', class'KFWeapDef_M14EBR', class'KFWeapDef_RailGun', class'KFWeapDef_M99')
    
    AdditionalOnPerkWeaponNames(0)="KFWeap_Pistol_9mm"
       AdditionalOnPerkWeaponNames(1)="KFWeap_Pistol_Dual9mm"
       AdditionalOnPerkWeaponNames(2)="KFWeap_Revolver_Rem1858"
       AdditionalOnPerkWeaponNames(3)="KFWeap_Revolver_SW500"
    AdditionalOnPerkDTNames(0)="KFDT_Ballistic_9mm"
    AdditionalOnPerkDTNames(1)="KFDT_Ballistic_SW500"
    AdditionalOnPerkDTNames(2)="KFDT_Ballistic_Rem1858"
    
    CameraViewShakeScale=0.5
    HeadshotDamageMultipliers.Empty
    
    WeaponDamage=(Name="Headshot Damage",Increment=0.01f,Rank=0,StartingValue=0.0f,MaxValue=0.25f)
    Recoil=(Name="Recoil",Increment=0.01f,Rank=0,StartingValue=0.0f,MaxValue=0.25f)
    WeaponSwitchSpeed=(Name="Weapon Switch Speed",Increment=0.02f,Rank=0,StartingValue=0.0f,MaxValue=0.50f)
    
    CustomLevelInfo="%d increase in headshot damage|%s faster firing speed with perked weapons|%a faster reload speed with perked weapons|%m reduced recoil with perked weapons|%w faster weapon switch speed"
}
