class ClassicPerk_Commando_Default extends ClassicPerk_Commando;

var const PerkSkill ZedTimeExtension;

simulated function ModifyDamageGiven( out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx )
{
    local KFWeapon KFW;
    local float TempDamage;

    Super.ModifyDamageGiven(InDamage, DamageCauser, MyKFPM, DamageInstigator, DamageType, HitZoneIdx);
    
    TempDamage = InDamage;

    if( DamageCauser != None )
    {
        KFW = GetWeaponFromDamageCauser( DamageCauser );
    }

    if( (KFW != none && IsWeaponOnPerk( KFW,, self.Class )) || (DamageType != None && IsDamageTypeOnPerk( DamageType )) )
    {
        if( IsRapidFireActive() )
        {
            TempDamage += InDamage * 0.03;
        }
    }

    if( KFW != none && !DamageCauser.IsA('KFProj_Grenade'))
    {
        if( IsBackupActive() && IsBackupWeapon( KFW ) )
        {
            TempDamage += InDamage * 0.85f;
        }
    }

    InDamage = FCeil(TempDamage);
}

simulated function bool IsProfessionalActive()
{
    return CurrentVetLevel == MaximumLevel;
}

simulated function bool IsBackupActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.25f);
}

simulated protected function bool IsRapidFireActive()
{
    return CouldRapidFireActive() && WorldInfo.TimeDilation < 1.f;
}

simulated function bool CouldRapidFireActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function ModifyWeaponSwitchTime( out float ModifiedSwitchTime )
{
    if( IsBackupActive() )
    {
        ModifiedSwitchTime -= ModifiedSwitchTime * class'KFPerk_Commando'.static.GetBackupWeaponSwitchModifier();
    }
}

simulated static function float GetBackupWeaponSwitchModifier()
{
    return 0.5f;
}

static simulated function bool Is9mm( KFWeapon KFW )
{
    return KFW != none && KFW.default.bIsBackupWeapon && !KFW.IsMeleeWeapon();
}

simulated function float GetZedTimeModifier( KFWeapon W )
{
    local name StateName;
    StateName = W.GetStateName();

    if( IsProfessionalActive() && (IsWeaponOnPerk( W,, self.class ) || IsBackupWeapon( W )) )
    {
        if( StateName == 'Reloading' ||
            StateName == 'AltReloading' )
        {
            return 1.f;
        }
        else if( StateName == 'WeaponPuttingDown' || StateName == 'WeaponEquipping' )
        {
            return 0.3f;
        }
    }

    if( CouldRapidFireActive() && (Is9mm(W) || IsWeaponOnPerk( W,, self.class )) && ZedTimeModifyingStates.Find( StateName ) != INDEX_NONE )
    {
        return 0.5f;
    }

    return 0.f;
}

simulated function DrawSpecialPerkHUD(Canvas C)
{
    local KFPawn_Monster KFPM;
    local vector ViewLocation, ViewDir;
    local float DetectionRangeSq, ThisDot;
    local float HealthBarLength, HealthbarHeight;

    if( CheckOwnerPawn() )
    {
        DetectionRangeSq = Square( GetPassiveValue(CloakedEnemyDetection, CurrentVetLevel) );

        HealthbarLength = FMin( 50.f * (float(C.SizeX) / 1024.f), 50.f );
        HealthbarHeight = FMin( 6.f * (float(C.SizeX) / 1024.f), 6.f );

        ViewLocation = OwnerPawn.GetPawnViewLocation();
        ViewDir = vector( OwnerPawn.GetViewRotation() );

        foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
        {
            if( !KFPM.CanShowHealth()
                || !KFPM.IsAliveAndWell()
                || `TimeSince(KFPM.Mesh.LastRenderTime) > 0.1f
                || VSizeSQ(KFPM.Location - ViewLocation) > DetectionRangeSq )
            {
                continue;
            }

            ThisDot = ViewDir dot Normal(KFPM.Location - ViewLocation);

            if( ThisDot > 0.f )
            {
                DrawZedHealthbar( C, KFPM, ViewLocation, HealthbarHeight, HealthbarLength );
            }
        }
    }
}

simulated static function float GetZedTimeExtension( byte Level )
{
    if( Level >= RANK_5_LEVEL )
    {
        return default.ZedTimeExtension.MaxValue;
    }
    else if( Level >= RANK_4_LEVEL )
    {
        return default.ZedTimeExtension.StartingValue + 4 * default.ZedTimeExtension.Increment;
    }
    else if( Level >= RANK_3_LEVEL )
    {
        return default.ZedTimeExtension.StartingValue + 3 * default.ZedTimeExtension.Increment;
    }
    else if( Level >= RANK_2_LEVEL )
    {
        return default.ZedTimeExtension.StartingValue + 2 * default.ZedTimeExtension.Increment;
    }
    else if( Level >= RANK_1_LEVEL )
    {
        return default.ZedTimeExtension.StartingValue + default.ZedTimeExtension.Increment;
    }

    return 1.0f;
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
    return Super(ClassicPerk_Base).GetWeaponDef(Level);
}

simulated function bool IsCallOutActive()
{
    return true;
}

simulated function bool HasNightVision()
{
    return true;
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
    ReplaceText(S,"%s",GetPercentStr(default.ReloadSpeed, Level));
    ReplaceText(S,"%a",GetPercentStr(default.Recoil, Level));
    ReplaceText(S,"%m",GetPercentStr(default.MagCapacity, Level));
    ReplaceText(S,"%b",GetPercentStr(default.SpareAmmo, Level));
    ReplaceText(S,"%c",Round(GetPassiveValue( default.CloakedEnemyDetection, Level ) / 100) $ "m");
    
    if( IsBackupActive() )
    {
        S = S $ "|Increased 9mm and knife damage with increased weapon switch speed";
    }
    
    if( IsRapidFireActive() )
    {
        S = S $ "|Shoot 3x faster and do 3% more damage in ZED Time";
    }
    
    if( IsProfessionalActive() )
    {
        S = S $ "|Reload and switch weapons in realtime during ZED Time";
    }
    
    SpawnDef = GetWeaponDef(Level);
    if( SpawnDef != None )
    {
        S = S $ "|Spawn with a " $ SpawnDef.static.GetItemName();
    }
    
    S = S $ "|Up to " $ int(GetZedTimeExtension(Level)) $ " Zed-Time Extension(s)";

    return S;
}

DefaultProperties
{
    PrimaryWeaponDef=class'KFWeapDef_AR15'
    SecondaryWeaponDef=class'KFWeapDef_9mm'
    KnifeWeaponDef=class'KFweapDef_Knife_Commando'
    GrenadeWeaponDef=class'KFWeapDef_Grenade_Commando'
    
    AutoBuyLoadOutPath=(class'KFWeapDef_AR15', class'KFWeapDef_Bullpup', class'KFWeapDef_AK12', class'KFWeapDef_SCAR', class'KFWeapDef_MedicRifleGrenadeLauncher')
    
       ZedTimeModifyingStates(0)="WeaponFiring"
       ZedTimeModifyingStates(1)="WeaponBurstFiring"
       ZedTimeModifyingStates(2)="WeaponSingleFiring"
    
    ZedTimeExtension=(Name="Zed Time Extension",Increment=1.f,Rank=0,StartingValue=1.f,MaxValue=6.f)
    CloakedEnemyDetection=(Name="Cloaked Enemy Detection Range",Increment=200.f,Rank=0,StartingValue=1000.f,MaxValue=6000.f)
    WeaponDamage=(Name="Weapon Damage",Increment=0.01,Rank=0,StartingValue=0.0f,MaxValue=0.25)
    ReloadSpeed=(Name="Reload Speed",Increment=0.02,Rank=0,StartingValue=0.0f,MaxValue=0.10)
    
    CustomLevelInfo="%d increase in assault rifle damage|%s faster reload speed with perked weapons|%a less recoil with perked weapons|%m more magazine capacity with perked weapons|Carry %b more ammo|Can see cloaked Stalkers at %c"
}
