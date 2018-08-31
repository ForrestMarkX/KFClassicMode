class ClassicWeapDef_P90 extends KFWeapDef_P90;

static function string GetItemLocalization( string KeyName )
{
	return class'KFWeapDef_P90'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_SMG_P90"
	BuyPrice=900
	AmmoPricePerMag=10
	EffectiveRange=45
}
