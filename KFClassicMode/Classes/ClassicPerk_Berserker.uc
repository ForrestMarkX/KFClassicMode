class ClassicPerk_Berserker extends ClassicPerk_Base;

var PassiveInfo ArmorInfo;

var	const PerkSkill BerserkerDamage;
var const PerkSkill	DamageResistance;
var const PerkSkill	MeleeAttackSpeed;
var const PerkSkill	MeleeMovementSpeed;
var	const PerkSkill BloatBileResistance;

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
	local KFWeapon MyKFWeapon;
	local float TempDamage;

	TempDamage = InDamage;

	if( DamageCauser != none )
	{
		if( DamageCauser.IsA( 'Weapon' ) )
		{
			MyKFWeapon = KFWeapon(DamageCauser);
		}
		else if( DamageCauser.IsA( 'Projectile' ) )
		{
			MyKFWeapon = KFWeapon(DamageCauser.Owner);
		}

		if( (MyKFWeapon != none && IsWeaponOnPerk( MyKFWeapon,, self.class )) || IsDamageTypeOnPerk( DamageType ) )
		{
			TempDamage += InDamage * GetPassiveValue( BerserkerDamage, CurrentVetLevel);
		}
	}

	InDamage = Round( TempDamage );
}

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
			TempDamage -= TempDamage * GetPassiveValue( BloatBileResistance, CurrentVetLevel );
			break;
		default:
			TempDamage -= TempDamage * GetPassiveValue( DamageResistance, CurrentVetLevel );
			break;
	}

	InDamage = Round(FMax(TempDamage, 1.f));
}

simulated function ModifyMeleeAttackSpeed( out float InDuration, KFWeapon KFW )
{
	if( KFW == none || !KFW.IsMeleeWeapon() )
	{
		return;
	}

	InDuration -= InDuration * GetPassiveValue( MeleeAttackSpeed, CurrentVetLevel );
}

simulated function ModifySpeed( out float Speed )
{
	local KFWeapon MyKFWeapon;
	local KFInventoryManager KFIM;

	MyKFWeapon = GetOwnerWeapon();
	if( MyKFWeapon == none && CheckOwnerPawn() )
	{
		KFIM = KFInventoryManager(OwnerPawn.InvManager);
		if( KFIM != none && KFIM.PendingWeapon != none )
		{
			MyKFWeapon = KFWeapon(KFIM.PendingWeapon);
		}
	}

	if( MyKFWeapon != none && MyKFWeapon.IsMeleeWeapon() )
	{
		Speed += Speed * GetPassiveValue( MeleeMovementSpeed, CurrentVetLevel );
	}
}

function bool CanNotBeGrabbed()
{
	return true;
}

simulated static function float GetZedTimeExtension( byte Level )
{
	return Min(Level, 4);
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

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
	if( Level == 5 )
	{
		return class'ClassicWeapDef_Crovel';
	}
	else if( Level >= 6 )
	{
		return class'ClassicWeapDef_Katana';
	}
	
	return None;
}

simulated static function GetPassiveStrings( out array<string> PassiveValues, out array<string> Increments, byte Level )
{
	PassiveValues[0] = Round(GetPassiveValue( default.BerserkerDamage, Level ) * 100) $ "%";
	PassiveValues[1] = Round(GetPassiveValue( default.DamageResistance, Level ) * 100) $ "%";
	PassiveValues[2] = Round(GetPassiveValue( default.MeleeAttackSpeed, Level ) * 100) $ "%";
	PassiveValues[3] = Round(GetPassiveValue( default.MeleeMovementSpeed, Level ) * 100) $ "%";
	PassiveValues[4] = "";

	Increments[0] = "[" @ Left( string( default.BerserkerDamage.Increment * 100 ), InStr(string(default.BerserkerDamage.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
	Increments[1] = "[" @ Left( string( default.DamageResistance.Increment * 100 ), InStr(string(default.DamageResistance.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
	Increments[2] = "[" @ Left( string( default.MeleeAttackSpeed.Increment * 100 ), InStr(string(default.MeleeAttackSpeed.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
	Increments[3] = "[" @ Left( string( default.MeleeMovementSpeed.Increment * 100 ), InStr(string(default.MeleeMovementSpeed.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
	Increments[4] = "";
	
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

	ReplaceText(S,"%d",GetPercentStr(default.BerserkerDamage, Level));
	ReplaceText(S,"%s",GetPercentStr(default.DamageResistance, Level));
	ReplaceText(S,"%a",GetPercentStr(default.MeleeAttackSpeed, Level));
	ReplaceText(S,"%m",GetPercentStr(default.MeleeMovementSpeed, Level));
	ReplaceText(S,"%b",GetPercentStr(default.BloatBileResistance, Level));
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
	
	S = S $ "|Can't be grabbed by Clots|Up to " $ int(GetZedTimeExtension(Level)) $ " Zed-Time Extension(s)";

	return S;
}

DefaultProperties
{
	BasePerk=class'KFPerk_Berserker'
	
	EXPActions(0)="Dealing Berserker weapon damage"
	EXPActions(1)="Killing Zeds near a player with a Berserker weapon"
	
	PassiveInfos(0)=(Title="Melee Weapon Damage")
	PassiveInfos(1)=(Title="Damage Resistance")
	PassiveInfos(2)=(Title="Melee Attack Speed")
	PassiveInfos(3)=(Title="Melee Movement Speed")
	PassiveInfos(4)=(Title="Clots cannot grab you")
	
	ArmorInfo=(Title="Spawn with a combat vest")
	
	BerserkerDamage=(Name="Melee Weapon Damage",Increment=0.2f,Rank=0,StartingValue=0.f,MaxValue=2.0f)
	DamageResistance=(Name="Damage Resistance",Increment=0.05f,Rank=0,StartingValue=0.f,MaxValue=0.8f)
	MeleeAttackSpeed=(Name="Melee Attack Speed",Increment=0.05f,Rank=0,StartingValue=0.f,MaxValue=0.25f)
	MeleeMovementSpeed=(Name="Melee Movement Speed",Increment=0.05f,Rank=0,StartingValue=0.f,MaxValue=0.3f)
	BloatBileResistance=(Name="Bloat Bile Resistance",Increment=0.15f,Rank=0,StartingValue=0.1f,MaxValue=0.85f)
	
	CustomLevelInfo="%d increase in melee weapon damage|%s resistence to all damage|%a increase in melee weapon attack speed|%m faster melee movement speed|%b resistence to Bloat Bile|%w discount on melee weapons"
}
