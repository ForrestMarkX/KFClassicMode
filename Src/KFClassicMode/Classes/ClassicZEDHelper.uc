class ClassicZEDHelper extends Object
    abstract;
    
struct SeasonalMonsterArchs
{
    var class<KFPawn_Monster> MonsterClass;
    var KFCharacterInfoBase Regular, Summer, Winter, Fall, Spring;
};
var array<SeasonalMonsterArchs> ZEDArchList;
    
static function KFCharacterInfoBase GetCharacterArch(KFPawn_Monster Monster, KFCharacterInfoBase Info)
{
    local KFCharacterInfoBase SeasonalArch;
    
    if( KFZEDInterface(Monster) != None )
    {
        SeasonalArch = GetSeasonalCharacterArch(Monster);
        if( SeasonalArch != None )
            return SeasonalArch;
    }
    
    return Info;
}

static function KFCharacterInfoBase GetSeasonalCharacterArch(KFPawn_Monster Monster)
{
	local KFEventHelper EventHelper;
    local int Index;
    local SeasonalMonsterArchs ZEDArch;
    
    Index = default.ZEDArchList.Find('MonsterClass', Monster.Class);
    if( Index != INDEX_NONE )
	{
        ZEDArch = default.ZEDArchList[Index];
 
        EventHelper = class'KFEventHelper'.static.FindEventHelper(Monster.WorldInfo);
        if( EventHelper == None )
            return ZEDArch.Regular;
        
        switch( EventHelper.GetEventType() )
        {
            case EV_SUMMER:
                return ZEDArch.Summer != None ? ZEDArch.Summer : ZEDArch.Regular;
            case EV_WINTER:
                return ZEDArch.Winter != None ? ZEDArch.Winter : ZEDArch.Regular;
            case EV_FALL:
                return ZEDArch.Fall != None ? ZEDArch.Fall : ZEDArch.Regular;
            case EV_SPRING:
                return ZEDArch.Spring != None ? ZEDArch.Spring : ZEDArch.Regular;
            default:
                return ZEDArch.Regular;
        }
    }
	
	return None;
}

static function string GetSeasonalLocalizationSuffix()
{
	local KFEventHelper EventHelper;
	
	EventHelper = class'KFEventHelper'.static.FindEventHelper(class'WorldInfo'.static.GetWorldInfo());
	if( EventHelper == None )
		return "";
	
	switch( EventHelper.GetEventType() )
	{
		case EV_SUMMER:
			return "_Summer";
		case EV_WINTER:
			return "_Winter";
		case EV_FALL:
			return "_Fall";
		case EV_SPRING:
		case EV_NORMAL:
		default:
			return "";
	}
	
	return "";
}

static function bool CanZeroMovement(KFPawn_Monster Monster)
{
    return KFZEDAIInterface(Monster.Controller) == None || !KFZEDAIInterface(Monster.Controller).GetKeepMoving();
}

defaultproperties
{
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedBloat', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Bloat_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Bloat_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Bloat_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Bloat_Archetype'))
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedClot_Alpha', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Clot_Alpha_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Clot_Slasher_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Clot_Alpha_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Clot_Alpha_Archetype'))
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedCrawler', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Crawler_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Crawler_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Crawler_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Crawler_Archetype'))
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedFleshpound', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Fleshpound_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Fleshpound_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Fleshpound_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Fleshpound_Archetype'))
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedGorefast', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Gorefast_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Gorefast_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Gorefast_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Gorefast_Archetype'))
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedHusk', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Husk_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Husk_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Husk_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Husk_Archetype'))
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedPatriarch', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Patriarch_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Patriarch_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Patriarch_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Patriarch_Archetype'))
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedScrake', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Scrake_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Scrake_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Scrake_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Scrake_Archetype'))
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedSiren', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Siren_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Siren_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Siren_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Siren_Archetype'))
    ZEDArchList.Add((MonsterClass=class'ClassicPawn_ZedStalker', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Stalker_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Stalker_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Stalker_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Stalker_Archetype'))
}