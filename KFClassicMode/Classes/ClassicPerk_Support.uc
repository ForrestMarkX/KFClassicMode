class ClassicPerk_Support extends ClassicPerk_Base;

var const PerkSkill	Weight;
var const PerkSkill	SupportDamage;
var const PerkSkill	WeldingProficiency;
var const PerkSkill	PenetrationPower;
var const PerkSkill	Ammo;

simulated protected event PostSkillUpdate()
{
	local float GrenadeCountMod;
	
	GrenadeCountMod = FCeil(default.MaxGrenadeCount * (1.f + (GetPassiveValue(Ammo, CurrentVetLevel)) * 4));
	MaxGrenadeCount = GrenadeCountMod;
	
	Super.PostSkillUpdate();
}

function ApplyWeightLimits()
{
	local KFInventoryManager KFIM;

	KFIM = KFInventoryManager(OwnerPawn.InvManager);
	if( KFIM != none )
	{
		KFIM.MaxCarryBlocks = KFIM.default.MaxCarryBlocks + int(GetPassiveValue( Weight, CurrentVetLevel ));
		CheckForOverWeight( KFIM );
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

	if( ((KFW != none && IsWeaponOnPerk( KFW,, self.class )) || (DamageType != none && IsDamageTypeOnPerk( DamageType ))) && !ClassIsChildOf( DamageType, class'KFDT_Explosive' )  )
	{		
		TempDamage += InDamage * GetPassiveValue( SupportDamage, CurrentVetLevel );
	}

	InDamage = Round( TempDamage );
}

simulated function ModifyWeldingRate( out float FastenRate, out float UnfastenRate )
{
	local float WeldingModifier;

	WeldingModifier = GetPassiveValue( WeldingProficiency, CurrentVetLevel );
	FastenRate *= WeldingModifier;
	UnFastenRate *= WeldingModifier;
}

simulated function float GetPenetrationModifier( byte Level, class<KFDamageType> DamageType, optional bool bForce  )
{
    if( !bForce && (DamageType == none || !IsDamageTypeOnPerk( Damagetype )) )
    {
        return 0;
    }

    return GetPassiveValue( PenetrationPower, CurrentVetLevel );
}

simulated function ModifyMaxSpareAmmoAmount( KFWeapon KFW, out int MaxSpareAmmo, optional const out STraderItem TraderItem, optional bool bSecondary=false )
{
	local float TempMaxSpareAmmoAmount;
	local array< class<KFPerk> > WeaponPerkClass;

	if(KFW == none)
	{
		WeaponPerkClass = TraderItem.AssociatedPerkClasses;
	}
	else
	{
		WeaponPerkClass = KFW.GetAssociatedPerkClasses();
	}
	
	if( IsWeaponOnPerk( KFW, WeaponPerkClass, self.class ) && MaxSpareAmmo > 0 )
	{
		TempMaxSpareAmmoAmount = MaxSpareAmmo;
		TempMaxSpareAmmoAmount += MaxSpareAmmo * GetPassiveValue( Ammo, CurrentVetLevel );

		MaxSpareAmmo = Round( TempMaxSpareAmmoAmount );
	}
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
	if( Level == 5 )
	{
		return class'ClassicWeapDef_MB500';
	}
	else if( Level >= 6 )
	{
		return class'ClassicWeapDef_DoubleBarrel';
	}
	
	return None;
}

simulated static function GetPassiveStrings( out array<string> PassiveValues, out array<string> Increments, byte Level )
{
	PassiveValues[0] = Round( (GetPassiveValue( default.WeldingProficiency, Level ) - 1) * 100) $ "%";
	PassiveValues[1] = Round( GetPassiveValue( default.SupportDamage, Level ) * 100) $ "%";
	PassiveValues[2] = Round( GetPassiveValue( default.PenetrationPower, Level ) * 100) $ "%";
	PassiveValues[3] = Round( GetPassiveValue( default.Ammo, Level ) * 100) $ "%";
	PassiveValues[4] = "";

	Increments[0] = "[" @ Left( string( default.WeldingProficiency.Increment * 100 ), InStr(string(default.WeldingProficiency.Increment * 100), ".") + 2 )	$ "% /" @ default.LevelString @ "]";
	Increments[1] = "[" @ Left( string( default.SupportDamage.Increment * 100 ), InStr(string(default.SupportDamage.Increment * 100), ".") + 2 )			$ "% /" @ default.LevelString @ "]";
	Increments[2] = "[" @ Left( string( default.PenetrationPower.Increment * 100 ), InStr(string(default.PenetrationPower.Increment * 100), ".") + 2 )	$ "% /" @ default.LevelString @ "]";
	Increments[3] = "[" @ Left( string( default.Ammo.Increment * 100 ), InStr(string(default.Ammo.Increment * 100), ".") + 2 )								$ "% /" @ default.LevelString @ "]";
	Increments[4] = "";
}

simulated static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local class<KFWeaponDefinition> SpawnDef;

	S = default.CustomLevelInfo;

	ReplaceText(S,"%d",GetPercentStr(default.SupportDamage, Level));
	ReplaceText(S,"%s",GetPercentStr(default.WeldingProficiency, Level));
	ReplaceText(S,"%a",GetPercentStr(default.PenetrationPower, Level));
	ReplaceText(S,"%m",GetPercentStr(default.Ammo, Level));
	ReplaceText(S,"%t",string(int(GetPassiveValue( default.Weight, Level ))));
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
	BasePerk=class'KFPerk_Support'
	
	EXPActions(0)="Dealing Support weapon damage"
	EXPActions(1)="Welding doors"
	
	PassiveInfos(0)=(Title="Welding Proficiency")
	PassiveInfos(1)=(Title="Shotgun Damage")
	PassiveInfos(2)=(Title="Shotgun Penetration")
	PassiveInfos(3)=(Title="Ammo")
	PassiveInfos(4)=(Title="Increased Weight Capacity")
	
	Weight=(Name="Carry Weight Increase",Increment=1.5f,Rank=0,StartingValue=0.f,MaxValue=25.0f)
	SupportDamage=(Name="Weapon Damage",Increment=0.2f,Rank=0,StartingValue=0.f,MaxValue=2.0f)
	WeldingProficiency=(Name="Welding Speed",Increment=0.25f,Rank=0,StartingValue=1.f,MaxValue=2.5f)
	PenetrationPower=(Name="Penetration Power",Increment=0.08f,Rank=0,StartingValue=1.f,MaxValue=2.5f)
	Ammo=(Name="Spare Ammo",Increment=0.05f,Rank=0,StartingValue=0.f,MaxValue=1.0f)
	
	CustomLevelInfo="%d increase in shotgun damage|%s increased welding speed|%a better shotgun penetration|%m increase in max ammo|%t extra carry weight block(s)|%w discount on shotguns"
}
