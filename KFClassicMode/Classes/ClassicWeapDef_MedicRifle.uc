class ClassicWeapDef_MedicRifle extends KFWeapDef_MedicRifle;

static function string GetItemLocalization(string KeyName)
{
	return class'KFWeapDef_MedicRifle'.static.GetItemLocalization(KeyName);
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_Medic"
}
