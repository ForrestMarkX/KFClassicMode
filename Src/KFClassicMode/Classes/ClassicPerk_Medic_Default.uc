class ClassicPerk_Medic_Default extends ClassicPerk_Medic;

var const PerkSkill Armor;

var float SnarePower;
var float SnareSpeedModifier;

var float SelfHealingSurgePct;

simulated function bool IsHealingSurgeActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.25f);
}

simulated function bool GetHealingSpeedBoostActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function bool GetHealingDamageBoostActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function bool GetHealingShieldActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

function bool IsAirborneAgentActive()
{
    return CurrentVetLevel == MaximumLevel;
}

simulated function bool IsSlugActive()
{
    return CurrentVetLevel == MaximumLevel && WorldInfo.TimeDilation < 1.f;
}

function bool IsArmorRepairActive()
{
    return CurrentVetLevel >= int(MaximumLevel*0.25f);
}

function NotifyZedTimeStarted()
{
    if( IsAirborneAgentActive() && OwnerPawn != none && OwnerPawn.IsAliveAndWell() )
    {
        OwnerPawn.StartAirBorneAgentEvent();
    }
}

simulated function float GetSnareSpeedModifier()
{
    return IsSlugActive() ? SnareSpeedModifier : 1.f;
}

simulated function float GetSnarePowerModifier( optional class<DamageType> DamageType, optional byte HitZoneIdx )
{
    if( IsSlugActive() && DamageType != none && IsDamageTypeOnPerk( class<KFDamageType>(DamageType) ) )
    {
        return SnarePower;
    }

    return 0.f;
}

function bool RepairArmor( Pawn HealTarget )
{
    return IsArmorRepairActive();
}

simulated function float GetSelfHealingSurgePct()
{
    return SelfHealingSurgePct;
}

function ModifyHealth( out int InHealth )
{
    local float TempHealth;

    if( IsHealingSurgeActive() )
    {
        TempHealth = InHealth;
        TempHealth += InHealth * 0.25f;
        InHealth = Round( TempHealth );
    }
}

function ModifyArmor( out byte MaxArmor )
{
    local float TempArmor;

    TempArmor = MaxArmor;
    TempArmor *= GetPassiveValue( Armor, GetLevel() );
    MaxArmor = FCeil( TempArmor );
}

simulated function bool HasHeavyArmor()
{ 
    return false; 
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

    ReplaceText(S,"%d",GetPercentStr(default.HealerRecharge, Level));
    ReplaceText(S,"%s",GetPercentStr(default.HealPotency, Level));
    ReplaceText(S,"%a",GetPercentStr(default.MagCapacity, Level));
    ReplaceText(S,"%m",GetPercentStr(default.MovementSpeed, Level));
    ReplaceText(S,"%t",GetPercentStr(default.Armor, Level));
    ReplaceText(S,"%b",GetPercentStr(default.BloatBileResistance, Level));
    
    if( IsHealingSurgeActive() )
    {
        S = S $ "|Healing others will also heal you for "$int(GetSelfHealingSurgePct()*100.f)$"% of your total health";
    }
    
    if( IsArmorRepairActive() )
    {
        S = S $ "|Healing will restore a portion of the players armor";
    }
    
    if( GetHealingSpeedBoostActive() )
    {
        S = S $ "|Players you heal will gain a temporary boost in stats";
    }
    
    if( IsAirborneAgentActive() )
    {
        S = S $ "|Spawn a medic cloud during ZED Time";
    }
    
    if( IsSlugActive() )
    {
        S = S $ "|Attacks will slow down ZEDs during ZED Time";
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
    PrimaryWeaponDef=class'KFWeapDef_MedicPistol'
    SecondaryWeaponDef=class'KFWeapDef_9mm'
    KnifeWeaponDef=class'KFWeapDef_Knife_Medic'
    
    AutoBuyLoadOutPath=(class'KFWeapDef_MedicPistol', class'KFWeapDef_MedicSMG', class'KFWeapDef_MedicShotgun', class'KFWeapDef_MedicRifle', class'KFWeapDef_MedicRifleGrenadeLauncher')
    
    SnarePower=100
    SnareSpeedModifier=0.7
    SelfHealingSurgePct=0.1f
    
    HealerRecharge=(Name="Healer Recharge",Increment=0.08f,Rank=0,StartingValue=1.f,MaxValue=3.f)
    HealPotency=(Name="Healer Potency",Increment=0.02f,Rank=0,StartingValue=1.0f,MaxValue=1.5f)
    BloatBileResistance=(Name="Bloat Bile Resistance",Increment=0.02,Rank=0,StartingValue=0.f,MaxValue=0.5f)
    MovementSpeed=(Name="Movement Speed",Increment=0.004f,Rank=0,StartingValue=0.f,MaxValue=0.1f)
    Armor=(Name="Armor",Increment=0.03f,Rank=0,StartingValue=1.f,MaxValue=1.75f)
    
    CustomLevelInfo="%d faster syringe recharge rate|%s better healing capabilities|%a increase in perked weapon magazine capacity|%m faster overall movement speed|%t more armor|%b resistence to bloat bile"
}
