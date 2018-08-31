class ClassicWeapDef_HX25 extends KFWeapDef_HX25;

static function string GetItemLocalization(string KeyName)
{
	return class'KFWeapDef_HX25'.static.GetItemLocalization(KeyName);
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_GrenadeLauncher_HX25"
}
