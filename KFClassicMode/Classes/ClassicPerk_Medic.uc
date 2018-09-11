class ClassicPerk_Medic extends ClassicPerk_Base;

var    const PerkSkill HealerRecharge;
var    const PerkSkill HealPotency;
var    const PerkSkill MagCapacity;
var    const PerkSkill MovementSpeed;
var    const PerkSkill ArmorQuality;
var    const PerkSkill BloatBileResistance;

function ModifyDamageTaken( out int InDamage, optional class<DamageType> DamageType, optional Controller InstigatedBy )
{
    local float TempDamage;

    if( InDamage <= 0 )
    {
        return;
    }

    TempDamage = InDamage;

    switch( DamageType.Name )
    {
        case 'KFDT_BloatPuke':
            TempDamage -= TempDamage * GetPassiveValue( BloatBileResistance, GetLevel() );
            FMax( TempDamage, 1.f );
        break;
    }

    InDamage = Round( TempDamage );
}

simulated function ModifyHealerRechargeTime( out float RechargeRate )
{
    local float HealerRechargeTimeMod;

    HealerRechargeTimeMod = 1 + GetPassiveValue( HealerRecharge, GetLevel() );
    RechargeRate /= HealerRechargeTimeMod;
}

function bool ModifyHealAmount( out float HealAmount )
{
    HealAmount *= (1 + GetPassiveValue( HealPotency, GetLevel() ));
    return false;
}

simulated function ModifyMagSizeAndNumber( KFWeapon KFW, out byte MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
    local float TempCapacity;

    TempCapacity = MagazineCapacity;

    if( IsWeaponOnPerk( KFW, WeaponPerkClass, self.class ) && (KFW == none || !KFW.bNoMagazine) && !bSecondary )
    {
        TempCapacity += MagazineCapacity * GetPassiveValue( MagCapacity, GetLevel() );
    }

    MagazineCapacity = Round( TempCapacity );
}

simulated function ModifySpeed( out float Speed )
{
    Speed += Speed * GetPassiveValue( MovementSpeed, GetLevel() );
}

simulated function int GetArmorDamageAmount( int AbsorbedAmt )
{
    return Max( Round(AbsorbedAmt * GetPassiveValue( ArmorQuality, GetLevel() )), 1 );
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
    if( Level >= 6 )
    {
        return class'ClassicWeapDef_MP7';
    }
    
    return None;
}

simulated static function GetPassiveStrings( out array<string> PassiveValues, out array<string> Increments, byte Level )
{
    PassiveValues[0] = Round((default.HealerRecharge.Increment * Level * 100) + default.HealerRecharge.StartingValue) $ "%";
    PassiveValues[1] = Round((default.HealPotency.Increment * Level * 100) + default.HealerRecharge.StartingValue) $ "%";
    PassiveValues[2] = Round((default.BloatBileResistance.Increment * Level * 100) + default.HealerRecharge.StartingValue) $ "%";
    PassiveValues[3] = Round(default.MagCapacity.Increment * Level * 100) $ "%";
    PassiveValues[4] = Round((default.MovementSpeed.Increment * Level * 100) + default.HealerRecharge.StartingValue) $ "%";
    PassiveValues[5] = Round(default.ArmorQuality.Increment * Level * 100) $ "%";

    Increments[0] = "[" @ Left( string( default.HealerRecharge.Increment * 100 ), InStr(string(default.HealerRecharge.Increment * 100), ".") + 2 )   $"% /" @ default.LevelString @"]";
    Increments[1] = "[" @ Left( string( default.HealPotency.Increment * 100 ), InStr(string(default.HealPotency.Increment * 100), ".") + 2 )  $"% /" @ default.LevelString @"]";
    Increments[2] = "[" @ Left( string( default.BloatBileResistance.Increment * 100 ), InStr(string(default.BloatBileResistance.Increment * 100), ".") + 2 ) $ "% /" @ default.LevelString @"]";
    Increments[3] = "[" @ left( string( default.MagCapacity.Increment * 100), 3) $ "% /" @ default.LevelString @"]";
    Increments[4] = "[" @ left( string( default.MovementSpeed.Increment * 100), 3) $ "% /" @ default.LevelString @"]";
    Increments[5] = "[" @ Left( string( default.ArmorQuality.Increment * 100 ), InStr(string(default.ArmorQuality.Increment * 100), ".") + 2 )  $"% /" @ default.LevelString @"]";
}

simulated static function string GetCustomLevelInfo( byte Level )
{
    local string S;
    local class<KFWeaponDefinition> SpawnDef;

    S = default.CustomLevelInfo;

    ReplaceText(S,"%d",GetPercentStr(default.HealerRecharge, Level));
    ReplaceText(S,"%s",GetPercentStr(default.HealPotency, Level));
    ReplaceText(S,"%a",GetPercentStr(default.MagCapacity, Level));
    ReplaceText(S,"%m",GetPercentStr(default.MovementSpeed, Level));
    ReplaceText(S,"%t",GetPercentStr(default.ArmorQuality, Level));
    ReplaceText(S,"%b",GetPercentStr(default.BloatBileResistance, Level));
    ReplaceText(S,"%w",GetPercentStr(default.WeaponDiscount, Level));
    
    SpawnDef = GetWeaponDef(Level);
    if( SpawnDef != None )
    {
        S = S $ "|Spawn with a " $ SpawnDef.static.GetItemName();
    }

    return S;
}

DefaultProperties
{
    BasePerk=class'KFPerk_FieldMedic'
    
    GrenadeWeaponDef=class'KFWeapDef_Grenade_Medic'
    
    EXPActions(0)="Dealing Field Medic weapon damage"
    EXPActions(1)="Healing teammates"
    
    PassiveInfos[0]=(Title="Syringe Recharge Rate")
    PassiveInfos[1]=(Title="Syringe Potency")
    PassiveInfos[2]=(Title="Bloat Bile Resistance")
    PassiveInfos[3]=(Title="Magazine Capacity")
    PassiveInfos[4]=(Title="Movement Speed")
    PassiveInfos[5]=(Title="Armor Bonus")
    
    HealerRecharge=(Name="Syringe Recharge Rate",Increment=0.5f,Rank=0,StartingValue=0.1f,MaxValue=2.5f)
    HealPotency=(Name="Syringe Potency",Increment=0.25f,Rank=0,StartingValue=0.1f,MaxValue=0.75f)
    MagCapacity=(Name="Magazine Capacity",Increment=0.05f,Rank=0,StartingValue=0.f,MaxValue=1.0f)
    MovementSpeed=(Name="Movement Speed",Increment=0.05f,Rank=0,StartingValue=0.05f,MaxValue=0.2f)
    ArmorQuality=(Name="Armor Quality",Increment=0.125f,Rank=0,StartingValue=0.f,MaxValue=0.75f)
    BloatBileResistance=(Name="Bloat Bile Resistance",Increment=0.15f,Rank=0,StartingValue=0.1f,MaxValue=0.75f)
    
    CustomLevelInfo="%d faster syringe recharge rate|%s better healing capabilities|%a increase in perked weapon magazine capacity|%m faster overall movement speed|Armor absorbes %t more damage|%b resistence to bloat bile|%w discount on medic weapons"
}
