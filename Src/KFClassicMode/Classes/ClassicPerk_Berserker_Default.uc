class ClassicPerk_Berserker_Default extends ClassicPerk_Berserker;

function AddVampireHealth( KFPlayerController KFPC, class<DamageType> DT )
{
    if( IsDamageTypeOnPerk( class<KFDamageType>(DT) ) && IsVampireActive() && KFPC.Pawn != none )
    {
        KFPC.Pawn.HealDamage( 4.f, KFPC, class'KFDT_Healing', false, false );
    }
}

function ApplySkillsToPawn()
{
    Super.ApplySkillsToPawn();

    if( OwnerPawn != None )
    {
        OwnerPawn.bMovesFastInZedTime = IsFastInZedTime();
    }
}

simulated function bool IsFastInZedTime()
{
    return CurrentVetLevel == MaximumLevel;
}

simulated function bool IsSpartanActive()
{
    return CurrentVetLevel == MaximumLevel && WorldInfo.TimeDilation < 1.f;
}

simulated function bool IsVampireActive()
{
    return CurrentVetLevel == int(MaximumLevel * 0.5f);
}

simulated function bool HasNightVision()
{
    return true;
}

simulated static function float GetZedTimeExtension( byte Level )
{
    return Super(KFPerk).GetZedTimeExtension(Level);
}

simulated static function array<PassiveInfo> GetPerkInfoStrings(int Level)
{
    return default.PassiveInfos;
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
    ReplaceText(S,"%s",GetPercentStr(default.DamageResistance, Level));
    ReplaceText(S,"%a",GetPercentStr(default.MeleeAttackSpeed, Level));
    ReplaceText(S,"%m",GetPercentStr(default.MeleeMovementSpeed, Level));
    ReplaceText(S,"%b",GetPercentStr(default.BloatBileResistance, Level));
    
    S = S $ "|Can't be grabbed by Clots";
    
    if( IsVampireActive() )
    {
        S = S $ "|Heals from killing ZEDs";
    }
    
    if( IsSpartanActive() )
    {
        S = S $ "|Move and attack in realtime during ZED Time";
    }
    
    SpawnDef = GetWeaponDef(Level);
    if( SpawnDef != None )
    {
        S = S $ "|Spawn with a " $ SpawnDef.static.GetItemName();
    }
    
    S = S $ "|Can't be grabbed by Clots";

    return S;
}

DefaultProperties
{
    PrimaryWeaponDef=class'KFWeapDef_Crovel'
    SecondaryWeaponDef=class'KFWeapDef_9mm'
    KnifeWeaponDef=class'KFweapDef_Knife_Berserker'
    GrenadeWeaponDef=class'KFWeapDef_Grenade_Berserker'
    
    AutoBuyLoadOutPath=(class'KFWeapDef_Crovel', class'KFWeapDef_Katana', class'KFWeapDef_Pulverizer', class'KFWeapDef_Eviscerator', class'KFWeapDef_AbominationAxe')
    
    WeaponDamage=(Name="Berserker Damage",Increment=0.01,Rank=0,StartingValue=0.f,MaxValue=0.25)
    DamageResistance=(Name="Damage Resistance",Increment=0.03f,Rank=0,StartingValue=0.f,MaxValue=0.15f)
}
