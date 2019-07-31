class ClassicPerk_Demolitionist extends ClassicPerk_Base;

var const PerkSkill ExplosiveResistance;
var const PerkSkill ExplosiveAmmo;
var const PerkSkill AOERadius;

function AddDefaultInventory( KFPawn P )
{
    local float GrenadeCountMod;
    
    Super.AddDefaultInventory(P);
    
    GrenadeCountMod = FCeil(default.MaxGrenadeCount * (1.f + (GetPassiveValue(ExplosiveAmmo, CurrentVetLevel)) * 4));
    MaxGrenadeCount = GrenadeCountMod;
}

function ModifyDamageTaken( out int InDamage, optional class<DamageType> DamageType, optional Controller InstigatedBy )
{
    local float TempDamage;

    if( InDamage <= 0 )
    {
        return;
    }

    TempDamage = InDamage;

    if( ClassIsChildOf( DamageType, class'KFDT_Explosive' ) )
    {
        TempDamage *= 1 - GetPassiveValue( ExplosiveResistance, CurrentVetLevel );
    }

    InDamage = Round( TempDamage );
}

simulated function ModifyMaxSpareAmmoAmount( KFWeapon KFW, out int MaxSpareAmmo, optional const out STraderItem TraderItem, optional bool bSecondary=false )
{
    local array< class<KFPerk> > WeaponPerkClass;
    local bool bUsesAmmo;

    if( KFW == none )
    {
        WeaponPerkClass = TraderItem.AssociatedPerkClasses;
        bUsesAmmo = TraderItem.WeaponDef.static.UsesAmmo();
    }
    else
    {
        WeaponPerkClass = KFW.GetAssociatedPerkClasses();
        bUsesAmmo = KFW.UsesAmmo();
    }

    if( bUsesAmmo && IsWeaponOnPerk( KFW, WeaponPerkClass, self.class ) )
    {
        if( KFWeap_Thrown_C4(KFW) != None )
            MaxSpareAmmo += MaxSpareAmmo * Min(CurrentVetLevel, 6);
        else MaxSpareAmmo += MaxSpareAmmo * GetPassiveValue( ExplosiveAmmo, CurrentVetLevel );
    }
}

simulated function float GetAoERadiusModifier()
{ 
    return 1 + GetPassiveValue( AOERadius, CurrentVetLevel );
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
    if( Level == 5 )
    {
        return class'ClassicWeapDef_HX25';
    }
    else if( Level >= 6 )
    {
        return class'ClassicWeapDef_M79';
    }
    
    return None;
}

simulated protected event PostSkillUpdate()
{
    MaxGrenadeCount = FCeil(default.MaxGrenadeCount + ( default.MaxGrenadeCount * GetPassiveValue( ExplosiveAmmo, CurrentVetLevel ) ));
    Super.PostSkillUpdate();
}

simulated static function GetPassiveStrings( out array<string> PassiveValues, out array<string> Increments, byte Level )
{
    PassiveValues[0] = Round( GetPassiveValue( default.WeaponDamage, Level ) * 100 ) $ "%";
    PassiveValues[1] = Round( ( GetPassiveValue( default.ExplosiveResistance, Level ) * 100 ) + default.ExplosiveResistance.StartingValue ) $ "%";
    PassiveValues[2] = Round( GetPassiveValue( default.ExplosiveAmmo, Level ) * 100 ) $ "%";
    PassiveValues[3] = Round( GetPassiveValue( default.AOERadius, Level ) * 100 ) $ "%";

    Increments[0] = "[" @ Round(default.WeaponDamage.Increment * 100) $ "% /" @ default.LevelString @ "]";
    Increments[1] = "[" @ Round(default.ExplosiveResistance.Increment * 100) $ "% /" @ default.LevelString @ "]";
    Increments[2] = "[" @ Round(default.ExplosiveAmmo.Increment * 100) @ "/" @ default.LevelString @ "]";
    Increments[3] = "[" @ Round(default.AOERadius.Increment * 100) $ "% /" @ default.LevelString @ "]";
}

simulated function string GetCustomLevelInfo( byte Level )
{
    local string S;
    local class<KFWeaponDefinition> SpawnDef;

    S = default.CustomLevelInfo;

    ReplaceText(S,"%d",GetPercentStr(default.WeaponDamage, Level));
    ReplaceText(S,"%s",GetPercentStr(default.ExplosiveResistance, Level));
    ReplaceText(S,"%a",GetPercentStr(default.ExplosiveAmmo, Level));
    ReplaceText(S,"%m",GetPercentStr(default.AOERadius, Level));
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
        OnHUDIcons[i].PerkIcon = Texture2D(RepInfo.ReferencedObjects[63]);
        OnHUDIcons[i].StarIcon = Texture2D(RepInfo.ReferencedObjects[28]);
    }
}

DefaultProperties
{
    BasePerk=class'KFPerk_Demolitionist'
    
    EXPActions(0)="Dealing Demolitionist weapon damage"
    EXPActions(1)="Killing Fleshpounds with Demolitionist weapons"
    
    PassiveInfos[0]=(Title="Perk Weapon Damage")
    PassiveInfos[1]=(Title="Explosive Resistance")
    PassiveInfos[2]=(Title="Extra Explosive Ammo")
    PassiveInfos[3]=(Title="Explosive AOE Radius")

    WeaponDamage=(Name="Explosive Weapon Damage",Increment=0.1f,Rank=0,StartingValue=0.f,MaxValue=1.65f)
    ExplosiveResistance=(Name="Explosive Damage Resistance",Increment=0.1f,Rank=0,StartingValue=0.25f,MaxValue=1.f)
    ExplosiveAmmo=(Name="Spare Ammo",Increment=0.05f,Rank=0,StartingValue=0.f,MaxValue=2.f)
    AOERadius=(Name="AOE Radius",Increment=0.05f,Rank=0,StartingValue=0.f,MaxValue=1.f)
    
    CustomLevelInfo="%d increased damage with explosive weapons|%s resistence to explosive damage|Carry %a more explosive weapon ammo|%m increase in explosive damage radius|%w discount on explosive weapons"
}
