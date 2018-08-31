class ClassicWeapDef_Healer extends KFWeapDef_Healer;

static function string GetItemLocalization(string KeyName)
{
	return class'KFWeapDef_Healer'.static.GetItemLocalization(KeyName);
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_Healer_Syringe"
}
