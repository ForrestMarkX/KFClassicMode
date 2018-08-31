class ClassicPostGameContainer_PlayerXP extends KFGFxPostGameContainer_PlayerXP;

function GFxObject MakePerkXPObject(PerkXPGain PerkXPObject)
{
	local GFxObject TempGFxObject;
	local ClassicPlayerController KFPC; 
	local ClassicPerk_Base PerkClass;

	KFPC = ClassicPlayerController(GetPC());
	PerkClass = KFPC.PerkManager.FindPerk(PerkXPObject.PerkClass);

	TempGFxObject = CreateObject("Object");

	TempGFxObject.SetFloat("startXP", 		PerkXPObject.StartXPPercentage);	
	TempGFxObject.SetFloat("finishXP", 		Min(KFPC.GetPerkLevelProgressPercentage(PerkXPObject.PerkClass), 100 ));	
	TempGFxObject.SetFloat("xpDelta", 		PerkXPObject.XPDelta);	
	TempGFxObject.SetInt("perkLevel", 		PerkXPObject.StartLevel);	
	TempGFxObject.SetInt("finishLevel", 	KFPC.GetPerkLevelFromPerkList(PerkXPObject.PerkClass));	
	TempGFxObject.SetString("perkName", 	class<ClassicPerk_Base>(PerkXPObject.PerkClass).static.GetPerkName());
	TempGFxObject.SetString("perkIcon",		"img://"$PathName(PerkClass.static.GetCurrentPerkIcon(PerkClass.GetLevel())));
	TempGFxObject.SetString("objective1", 	PerkXPObject.PerkClass.default.EXPAction1);
	TempGFxObject.SetInt("objective1Value", PerkXPObject.XPDelta - PerkXPObject.SecondaryXPGain	);
	TempGFxObject.SetString("objective2", 	PerkXPObject.PerkClass.default.EXPAction2);
	TempGFxObject.SetInt("objective2Value", PerkXPObject.SecondaryXPGain );

	ItemCount++;

	return TempGFxObject;
}

DefaultProperties
{
}