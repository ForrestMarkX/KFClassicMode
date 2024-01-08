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
    return GetSeasonalCharacterArch(Monster, Info);
}

static function KFCharacterInfoBase GetSeasonalCharacterArch(KFPawn_Monster Monster, KFCharacterInfoBase Info)
{
    local KFEventHelper EventHelper;
    local SeasonalMonsterArchs ZEDArch;
    
    foreach default.ZEDArchList(ZEDArch)
    {
        if( Monster.IsA(ZEDArch.MonsterClass.Name) )
        {
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
    }
    
    return Info;
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
    //Always put ZEDs that extend the normal classes first
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedClot_AlphaKing', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Clot_AlphaKing_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Clot_AlphaKing_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Clot_AlphaKing_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Clot_AlphaKing_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedCrawlerKing', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_CrawlerKing_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_CrawlerKing_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_CrawlerKing_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_CrawlerKing_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedFleshpoundMini', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_FleshpoundMini_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_FleshpoundMini_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_FleshpoundMini_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_FleshpoundMini_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedGorefastDualBlade', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Gorefast2_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Gorefast2_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Gorefast2_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Gorefast2_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedBloatKing', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_BloatKing_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_BloatKing_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_BloatKing_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_BloatKing_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedFleshpoundKing', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_FleshpoundKing_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_FleshpoundKing_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_FleshpoundKing_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_FleshpoundKing_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedDAR_EMP', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_DAR_EMP_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_DAR_EMP_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_DAR_EMP_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_DAR_EMP_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedDAR_Laser', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_DAR_Laser_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_DAR_Laser_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_DAR_Laser_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_DAR_Laser_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedDAR_Rocket', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_DAR_Rocket_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_DAR_Rocket_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_DAR_Rocket_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_DAR_Rocket_Archetype'))
    
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedBloat', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Bloat_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Bloat_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Bloat_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Bloat_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedClot_Cyst', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Clot_Undev_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Clot_Undev_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Clot_Undev_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Clot_Undev_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedClot_Alpha', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Clot_Alpha_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Clot_Slasher_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Clot_Alpha_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Clot_Alpha_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedClot_Slasher', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Clot_Slasher_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Clot_Slasher_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Clot_Slasher_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Clot_Slasher_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedCrawler', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Crawler_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Crawler_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Crawler_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Crawler_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedFleshpound', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Fleshpound_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Fleshpound_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Fleshpound_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Fleshpound_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedGorefast', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Gorefast_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Gorefast_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Gorefast_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Gorefast_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedHusk', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Husk_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Husk_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Husk_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Husk_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedPatriarch', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Patriarch_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Patriarch_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Patriarch_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Patriarch_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedHans', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Hans_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Hans_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Hans_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Hans_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedMatriarch', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Matriarch_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Matriarch_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Matriarch_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Matriarch_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedScrake', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Scrake_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Scrake_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Scrake_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Scrake_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedSiren', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Siren_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Siren_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Siren_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Siren_Archetype'))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedStalker', Regular=KFCharacterInfo_Monster'ZED_ARCH.ZED_Stalker_Archetype', Summer=KFCharacterInfo_Monster'SUMMER_ZED_ARCH.ZED_Stalker_Archetype', Winter=KFCharacterInfo_Monster'XMAS_ZED_ARCH.ZED_Stalker_Archetype', Fall=KFCharacterInfo_Monster'HALLOWEEN_ZED_ARCH.ZED_Stalker_Archetype'))
}