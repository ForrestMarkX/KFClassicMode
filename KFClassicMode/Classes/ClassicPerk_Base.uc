class ClassicPerk_Base extends KFPerk;

struct PassiveInfo
{
	var string Title;
	var string Description;
	var string IconPath;
};
var array<PassiveInfo> PassiveInfos;

struct PerkIconData 
{
	var Texture PerkIcon;
	var Texture StarIcon;
	var Color DrawColor;
};
var array<PerkIconData> OnHUDIcons;

var	const PerkSkill WeaponDiscount;
	
var class<KFPerk> BasePerk;
var array<string> EXPActions;
var string CustomLevelInfo, CustomPerkName;
var transient float NextAuthTime;
var ClassicPerkManager PerkManager;
var bool bClientAuthorized, bPerkNetReady;
var SoundCue PerkAchieved;
var string PerkAchievedName;

var int FirstLevelExp, // How much EXP needed for first level.
		LevelUpExpCost, // How much EXP needed for every level up.
		LevelUpIncCost, // How much EXP increase needed for each level up.
		MinimumLevel,
		MaximumLevel,
		CurrentVetLevel;
				
var int CurrentEXP, // Current amount of EXP user has.
		NextLevelEXP, // Experience needed for next level.
		LastLevelEXP; // Number of XP was needed for last level.
		
replication
{
	// Things the server should send to the client.
	if ( true )
		CurrentEXP,NextLevelEXP,LastLevelEXP,MinimumLevel,MaximumLevel,FirstLevelExp,LevelUpExpCost,LevelUpIncCost,CurrentVetLevel;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if( WorldInfo.NetMode==NM_Client )
	{
		SetTimer(0.01,false,'InitPerk');
		SetTimer(0.1,true,'GetPerkIcons');
	}
	
	PerkAchieved = SoundCue(DynamicLoadObject(PerkAchievedName, class'SoundCue'));
}

simulated function GetPerkIcons()
{
	local int i;
	
	for (i = 0; i < OnHUDIcons.Length; i++)
	{
		OnHUDIcons[i].PerkIcon = default.OnHUDIcons[i].PerkIcon;
		OnHUDIcons[i].StarIcon = default.OnHUDIcons[i].StarIcon;
	}
	
	if( OnHUDIcons[0].PerkIcon != None )
	{
		ClearTimer('GetPerkIcons');
	}
}

simulated function InitPerk()
{
	if( OwnerPC==None )
		OwnerPC = KFPlayerController(GetALocalPlayerController());
}

simulated function byte GetLevel()
{
	return CurrentVetLevel;
}

simulated function SetLevel( byte NewLevel )
{
	CurrentVetLevel = NewLevel;
}

function bool EarnedEXP( int EXP )
{
	local int Index;
	local KFGameEngine Engine;
	
	Engine = KFGameEngine(class'Engine'.static.GetEngine());
	
	bForceNetUpdate = true;
	CurrentEXP+=EXP;
	
	if( CurrentEXP >= NextLevelEXP && CurrentVetLevel < MaximumLevel )
	{
		LastLevelEXP = NextLevelEXP;
		NextLevelEXP = GetNeededExp(CurrentVetLevel + 1);
		
		SetLevel(CurrentVetLevel + 1);

		ClassicPlayerReplicationInfo(MyPRI).CurrentPerkLevel = CurrentVetLevel;
		
		PerkAchieved.VolumeMultiplier = (Engine.SFxVolumeMultiplier/100.f) * (Engine.MasterVolumeMultiplier/100.f);
		OwnerPC.ClientPlaySound(PerkAchieved);
		
		Index = OwnerPC.GetPerkIndexFromClass(Class);
		ClassicPlayerController(OwnerPC).SetPerkStaticLevel(Index, CurrentVetLevel);
		OwnerPC.PerkList[Index].PerkLevel = CurrentVetLevel;
		
		WorldInfo.Game.BroadcastLocalizedMessage(class'KFLevelUpNotification', CurrentVetLevel, MyPRI,,Class);
		
		PostLevelUp();
	}
	
	return true;
}

simulated final function float GetProgressPercent()
{
	return FClamp(float(CurrentEXP-LastLevelEXP) / FMax(float(NextLevelEXP-LastLevelEXP),1.f),0.f,1.f);
}

final function bool HasAnyProgress()
{
	return CurrentEXP>0;
}

function ApplySkillsToPawn()
{
	local KFInventoryManager KFIM;

	if( CheckOwnerPawn() && OwnerPawn.InvManager != none )
	{
		KFIM = KFInventoryManager(OwnerPawn.InvManager);
		if( KFIM.GrenadeCount > MaxGrenadeCount )
		{
			KFIM.GrenadeCount = MaxGrenadeCount;
		}
	}
	
	Super.ApplySkillsToPawn();
}

simulated function PostPerkUpdate(Pawn P)
{
	PostSkillUpdate();
	ApplySkillsToPawn();
}

// Data saving.
function SaveData( KFSaveDataBase Data )
{
	// Write current EXP.
	Data.SaveInt(CurrentEXP,2);
}

// Data loading.
function LoadData( KFSaveDataBase Data )
{
	CurrentEXP = Data.ReadInt(2);
}

final function int CalcLevelForExp( int InExp )
{
	local int i,a,b;

	// Fast method to calc level for a player.
	b = MaximumLevel+1;
	a = Min(MinimumLevel,b);
	while( true )
	{
		if( a==b || (a+1)==b )
		{
			if( a<MaximumLevel && InExp>=GetNeededExp(a) )
				++a;
			break;
		}
		i = a+((b-a)>>1);
		if( InExp<GetNeededExp(i) ) // Lower!
			b = i;
		else a = i; // Higher!
	}
	return Clamp(a,MinimumLevel,MaximumLevel);
}

// Initialize perk after stats have been loaded.
function SetInitialLevel()
{
	// Set to initial level player is on after configures has loaded.
	SetLevel(CalcLevelForExp(CurrentEXP));
	NextLevelEXP = GetNeededExp(CurrentVetLevel);
	LastLevelEXP = (CurrentVetLevel>MinimumLevel ? GetNeededExp(CurrentVetLevel-1) : 0);
}

function int GetNeededExp( int LevelNum )
{
	if( LevelNum<MinimumLevel || LevelNum>=MaximumLevel )
		return 0;
		
	LevelNum -= MinimumLevel;
	LevelNum = ( FirstLevelExp + (LevelNum*LevelUpExpCost) + ((LevelNum^2)*LevelUpIncCost) );
	
	return LevelNum;
}

simulated function bool HasNightVision()
{
	return false;
}

simulated function string GetPrimaryWeaponClassPath()
{
	local class<KFWeaponDefinition> Def;
	
	Def = GetWeaponDef(CurrentVetLevel);
	if( Def != None )
		return Def.default.WeaponClassPath;
		
	return "";
}
	
simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
	return default.PrimaryWeaponDef;
}
	
simulated static function class<KFWeaponDefinition> GetSecondaryDef(int Level)
{
	return default.SecondaryWeaponDef;
}

simulated static function class<KFWeaponDefinition> GetKnifeDef(int Level)
{
	return default.KnifeWeaponDef;
}

simulated static function class<KFWeaponDefinition> GetGrenadeDef(int Level)
{
	return default.GrenadeWeaponDef;
}

simulated static function array<PassiveInfo> GetPerkInfoStrings(int Level)
{	
	return default.PassiveInfos;
}

static simulated function bool IsWeaponOnPerk(KFWeapon W, optional array < class<KFPerk> > WeaponPerkClass, optional class<KFPerk> InstigatorPerkClass, optional name WeaponClassName)
{
	if( default.BasePerk == None )
	{
		return Super.IsWeaponOnPerk(W, WeaponPerkClass, InstigatorPerkClass, WeaponClassName);
	}
	
	if( W != None )
	{
		return W.static.AllowedForAllPerks() || W.static.GetWeaponPerkClass( InstigatorPerkClass ) == default.BasePerk;
	}
	else if( WeaponPerkClass.length > 0 )
	{
		return WeaponPerkClass.Find(default.BasePerk) != INDEX_NONE;
	}

	return false;
}

static function bool IsDamageTypeOnPerk(class<KFDamageType> KFDT)
{
	if( default.BasePerk == none )
	{
		return Super.IsDamageTypeOnPerk(KFDT);
	}
	
	if( KFDT != none )
	{
		return KFDT.default.ModifierPerkList.Find(default.BasePerk) > INDEX_NONE;
	}

	return false;
}

static function bool IsBackupDamageTypeOnPerk(class<DamageType> DT)
{
	if( default.BasePerk == none )
	{
		return Super.IsBackupDamageTypeOnPerk(DT);
	}
	
	if( DT != none )
	{
		return default.BasePerk.default.BackupWeaponDamageTypeNames.Find(DT.Name) > INDEX_NONE;
	}

	return false;
}

simulated function float GetCostScaling(byte Level, optional STraderItem TraderItem, optional KFWeapon Weapon)
{
	if( IsWeaponOnPerk( Weapon, TraderItem.AssociatedPerkClasses, self.Class ) )
	{
		return 1.f - GetPassiveValue( WeaponDiscount, Level );
	}
	
	return 1.f;
}

simulated function string GetGrenadeImagePath()
{
	return GetGrenadeDef(CurrentVetLevel).Static.GetImagePath();
}

simulated function class<KFWeaponDefinition> GetGrenadeWeaponDef()
{
	return GetGrenadeDef(CurrentVetLevel);
}

simulated static function string GetPerkName()
{
	if( default.BasePerk != None && default.BasePerk.default.PerkName != "" )
		return default.BasePerk.default.PerkName;
		
	if( default.CustomPerkName != "" )
		return default.CustomPerkName;
		
	return default.PerkName;
}

simulated static function byte GetPerkIconIndex( out byte Level )
{
	local byte MaxStars, Index;
	
	MaxStars = class'KFHUDInterface'.default.MaxPerkStars;
	Index = Min((Level-1)/MaxStars, default.OnHUDIcons.Length - 1);
	Level -= Index*MaxStars;
	
	return Index;
}

simulated static function Texture GetCurrentPerkIcon( byte Level )
{
	return default.OnHUDIcons[GetPerkIconIndex(Level)].PerkIcon;
}

simulated static function Texture GetCurrentPerkStarIcon( byte Level )
{
	return default.OnHUDIcons[GetPerkIconIndex(Level)].StarIcon;
}

simulated static function Color GetPerkColor( byte Level )
{
	return default.OnHUDIcons[GetPerkIconIndex(Level)].DrawColor;
}

simulated static function byte PreDrawPerk( Canvas C, byte Level, out Texture Icon, out Texture StarIcon )
{
	local byte Index;
	
	Index = GetPerkIconIndex(Level);
	
	Icon = default.OnHUDIcons[Index].PerkIcon;
	StarIcon = default.OnHUDIcons[Index].StarIcon;
	C.DrawColor = default.OnHUDIcons[Index].DrawColor;
		
	return Level;
}

static function string GetCustomLevelInfo( byte Level )
{
	return default.CustomLevelInfo;
}

static function string GetPercentStr( PerkSkill Skill, byte Level  )
{
	return Round(GetPassiveValue( Skill, Level ) * 100) $ "%";
}

simulated function bool HasHeavyArmor()
{ 
	return true; 
}

simulated event UpdatePerkBuild( const out byte InSelectedSkills[`MAX_PERK_SKILLS], class<KFPerk> PerkClass);
simulated event PackPerkBuild( out int NewPerkBuild, const out byte SelectedSkillsHolder[`MAX_PERK_SKILLS] );
simulated event PackSkill( out int NewPerkBuild, byte SkillIndex, int SkillFlag1, int SkillFlag2 );
simulated event SetPerkBuild( int NewPerkBuild );
simulated event GetUnpackedSkillsArray( Class<KFPerk> PerkClass, int NewPerkBuild,  out byte SelectedSkillsHolder[`MAX_PERK_SKILLS] );
simulated function UnpackSkill( byte PerkLevel, int NewPerkBuild, byte SkillTier, int SkillFlag1, int SkillFlag2, out byte SelectedSkillsHolder[`MAX_PERK_SKILLS] );

defaultproperties
{
	FirstLevelExp=7500
	LevelUpExpCost=9375
	LevelUpIncCost=1218
	
	MinimumLevel=-1
	MaximumLevel=-1
	
	ProgressStatID=1
	PerkBuildStatID=2
	
	bInitialized=true
	
	OnHUDIcons.Add((DrawColor=(R=255,G=15,B=15,A=255)))
	OnHUDIcons.Add((DrawColor=(R=255,G=255,B=0,A=255)))
	OnHUDIcons.Add((DrawColor=(R=0,G=255,B=0,A=255)))
	OnHUDIcons.Add((DrawColor=(R=0,G=125,B=255,A=255)))
	OnHUDIcons.Add((DrawColor=(R=178,G=0,B=255,A=255)))
	OnHUDIcons.Add((DrawColor=(R=255,G=0,B=128,A=255)))
	OnHUDIcons.Add((DrawColor=(R=95,G=0,B=0,A=255)))
	
	WeaponDiscount=(Name="Weapon Discount",Increment=0.1f,Rank=0,StartingValue=0.1f,MaxValue=0.9f)
	
	PerkAchievedName="KFClassicMode_Assets.Perks.PerkAchievedCue"
	
	SecondaryWeaponDef=class'ClassicWeapDef_9mm'
	GrenadeWeaponDef=class'ClassicWeapDef_Grenade_Support'
}