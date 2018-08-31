class ClassicPerksContainer_Skills extends KFGFxPerksContainer_Skills;

function UpdateSkills( class<KFPerk> PerkClass, const out byte SelectedSkills[`MAX_PERK_SKILLS] );
function UpdateTierUnlockState(class<KFPerk> PerkClass);
function GFxObject GetSkillObject(byte TierIndex, byte SkillIndex, bool bShouldUnlock, class<KFPerk> PerkClass);

defaultproperties()
{
}
