class ClassicPerk_Gunslinger_Default extends ClassicPerk_Base;

var const PerkSkill BulletResistance,ZedTimeReload,Recoil,MovementSpeed;
var array<Name> SpecialZedClassNames;

var array<Name> AdditionalOnPerkWeaponNames;
var array<Name> AdditionalOnPerkDTNames;

simulated function bool IsKnockEmDownActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.25f);
}

simulated function bool IsShootnMoveActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function bool IsPenetrationActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function bool IsFanfareActive()
{
    return CurrentVetLevel == MaximumLevel;
}

function float GetKnockdownPowerModifier( optional class<DamageType> DamageType, optional byte BodyPart, optional bool bIsSprinting=false )
{
    if( IsKnockEmDownActive() && HitShouldKnockdown( BodyPart ) && bIsSprinting )
    {
        return 4.1f;
    }

    return 0.f;
}

function float GetStumblePowerModifier( optional KFPawn KFP, optional class<KFDamageType> DamageType, optional out float CooldownModifier, optional byte BodyPart )
{
    if( IsKnockEmDownActive() && ( HitShouldStumble( BodyPart ) || CheckSpecialZedBodyPart( KFP.class, BodyPart )) )
    {
        return 4.1f;
    }

    return 0.f;
}

function bool CheckSpecialZedBodyPart( class<KFPawn> PawnClass, byte BodyPart )
{
    if( BodyPart == BP_Special && SpecialZedClassNames.Find( PawnClass.Name ) != INDEX_NONE )
    {
        return true;
    }

    return false;
}

simulated function float GetPenetrationModifier( byte Level, class<KFDamageType> DamageType, optional bool bForce  )
{
    if( (!IsPenetrationActive() && !bForce) || (DamageType == none || !IsDamageTypeOnPerk( Damagetype )) )
    {
        return 0;
    }

    return 1.f;
}

simulated function bool IgnoresPenetrationDmgReduction()
{
    return IsPenetrationActive();
}

simulated event float GetIronSightSpeedModifier( KFWeapon KFW )
{
    if( IsShootnMoveActive() && IsWeaponOnPerk( KFW,, self.class ) )
    {
        return 2.f;
    }

    return 1.f;
}

simulated function ModifyWeaponBopDamping( out float BobDamping, KFWeapon PawnWeapon )
{
    If( IsShootnMoveActive() && IsWeaponOnPerk( PawnWeapon,, self.class ) )
    {
        BobDamping *= 1.11f;
    }
}

simulated function bool GetIsUberAmmoActive( KFWeapon KFW )
{
    return IsWeaponOnPerk( KFW,, self.class ) && IsFanfareActive() && WorldInfo.TimeDilation < 1.f;
}

simulated function float GetZedTimeModifier( KFWeapon W )
{
    local name StateName;

    if( IsFanfareActive() && IsWeaponOnPerk( W,, self.class ) )
    {
        StateName = W.GetStateName();
        if( ZedTimeModifyingStates.Find( StateName ) != INDEX_NONE )
        {
            return 1.f;
        }

        if( StateName == 'Reloading' )
        {
            return 1.f;
        }
    }

    return 0.f;
}

function ModifyDamageTaken( out int InDamage, optional class<DamageType> DamageType, optional Controller InstigatedBy )
{
    local float TempDamage;

    Super.ModifyDamageTaken(InDamage, DamageType, InstigatedBy);
    if( InDamage <= 0 )
        return;

    TempDamage = InDamage;

    if( ClassIsChildOf(DamageType, class'KFDT_Ballistic') && TempDamage > 0 )
    {
        TempDamage -= InDamage * GetPassiveValue(BulletResistance, CurrentVetLevel);
    }

    InDamage = Round(TempDamage);
}

simulated function ModifySpeed( out float Speed )
{
    local float TempSpeed;

    TempSpeed = Speed;
    TempSpeed += Speed * GetPassiveValue(MovementSpeed, CurrentVetLevel);

    Speed = Round(TempSpeed);
}

simulated function ModifyRecoil( out float CurrentRecoilModifier, KFWeapon KFW )
{
    if( IsWeaponOnPerk( KFW,, self.class ) )
    {
        CurrentRecoilModifier -= CurrentRecoilModifier * GetPassiveValue(Recoil, CurrentVetLevel);
    }
}

simulated function float GetReloadRateScale( KFWeapon KFW )
{
    if( IsWeaponOnPerk( KFW,, self.class ) && WorldInfo.TimeDilation < 1.f )
    {
        return 1.f -  GetPassiveValue(ZedTimeReload, CurrentVetLevel);
    }

    return 1.f;
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

static function bool IsDamageTypeOnPerk( class<KFDamageType> KFDT )
{
	if( KFDT != none && default.AdditionalOnPerkDTNames.Find( KFDT.name ) != INDEX_NONE )
	{
		return true;
	}

	return super.IsDamageTypeOnPerk( KFDT );
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
    ReplaceText(S,"%s",GetPercentStr(default.BulletResistance, Level));
    ReplaceText(S,"%a",GetPercentStr(default.MovementSpeed, Level));
    ReplaceText(S,"%m",GetPercentStr(default.Recoil, Level));
    ReplaceText(S,"%b",GetPercentStr(default.ZedTimeReload, Level));
    
    if( IsKnockEmDownActive() )
    {
        S = S $ "|Weapons have a mucher higher chance to disable ZEDs";
    }
    
    if( IsShootnMoveActive() )
    {
        S = S $ "|Can move near full speed when in ironsights";
    }
    
    if( IsPenetrationActive() )
    {
        S = S $ "|Weapons can penetrate ZEDs";
    }
    
    if( IsFanfareActive() )
    {
        S = S $ "|Can shoot in realtime with unlimited ammo during ZED Time";
    }
    
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
        OnHUDIcons[i].PerkIcon = Texture2D(RepInfo.ReferencedObjects[163]);
        OnHUDIcons[i].StarIcon = Texture2D(RepInfo.ReferencedObjects[28]);
    }
}

DefaultProperties
{
    BasePerk=class'KFPerk_Gunslinger'
    
    PrimaryWeaponDef=class'KFWeapDef_Remington1858Dual'
    SecondaryWeaponDef=class'KFWeapDef_9mm'
    KnifeWeaponDef=class'KFWeapDef_Knife_Gunslinger'
    GrenadeWeaponDef=class'KFWeapDef_Grenade_Gunslinger'
    
    SpecialZedClassNames(0)="KFPawn_ZedFleshpound"
    
   	ZedTimeModifyingStates(0)="WeaponFiring"
   	ZedTimeModifyingStates(1)="WeaponBurstFiring"
   	ZedTimeModifyingStates(2)="WeaponSingleFiring"
   	ZedTimeModifyingStates(3)="WeaponSingleFireAndReload"
    ZedTimeModifyingStates(4)="Reloading"
    ZedTimeModifyingStates(5)="AltReloading"
    
   	AdditionalOnPerkWeaponNames(0)="KFWeap_Pistol_9mm"
   	AdditionalOnPerkWeaponNames(1)="KFWeap_Pistol_Dual9mm"
   	AdditionalOnPerkWeaponNames(2)="KFWeap_GrenadeLauncher_HX25"
   	AdditionalOnPerkDTNames(0)="KFDT_Ballistic_9mm"
   	AdditionalOnPerkDTNames(1)="KFDT_Ballistic_Pistol_Medic"
   	AdditionalOnPerkDTNames(2)="KFDT_Ballistic_Winchester"
   	AdditionalOnPerkDTNames(3)="KFDT_Ballistic_HX25Impact"
   	AdditionalOnPerkDTNames(4)="KFDT_Ballistic_HX25SubmunitionImpact"
    
    EXPActions(0)="Dealing Gunslinger weapon damage"
    EXPActions(1)="Killing Zeds with a Gunslinger weapon"
    
    AutoBuyLoadOutPath=(class'KFWeapDef_Remington1858', class'KFWeapDef_Remington1858Dual', class'KFWeapDef_Colt1911', class'KFWeapDef_Colt1911Dual',class'KFWeapDef_Deagle', class'KFWeapDef_DeagleDual', class'KFWeapDef_SW500', class'KFWeapDef_SW500Dual')
    
    WeaponDamage=(Name="Weapon Damage",Increment=0.01f,Rank=0,StartingValue=0.0f,MaxValue=0.25f)
    BulletResistance=(Name="Bullet Resistance",Increment=0.01f,Rank=0,StartingValue=0.05f,MaxValue=0.3f)
    MovementSpeed=(Name="Movement Speed",Increment=0.008f,Rank=0,StartingValue=0.0f,MaxValue=0.20f)
    Recoil=(Name="Recoil",Increment=0.01f,Rank=0,StartingValue=0.0f,MaxValue=0.25f)
    ZedTimeReload=(Name="Zed Time Reload",Increment=0.03f,Rank=0,StartingValue=0.f,MaxValue=0.75f)
    
    CustomLevelInfo="%d increase in pistol weapon damage|%s resistence to bullets|%a increase in movement speed|%m decrease in recoil with pistols|%b increased reload speed during ZED Time"
}