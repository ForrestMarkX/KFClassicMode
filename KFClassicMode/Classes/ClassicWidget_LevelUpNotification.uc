class ClassicWidget_LevelUpNotification extends KFGFxWidget_LevelUpNotification;

function ShowLevelUpNotification(Class<KFPerk> PerkClass, byte PerkLevel, bool bTierUnlocked)
{
	ShowAchievementNotification(LevelUpString, class<ClassicPerk_Base>(PerkClass).static.GetPerkName(), TierUnlockedString, "img://"$PathName(class<ClassicPerk_Base>(PerkClass).static.GetCurrentPerkIcon(PerkLevel)), bTierUnlocked, PerkLevel);
}