class ClassicWeapDef_Stoner63A extends KFWeapDef_Stoner63A;

static function string GetItemLocalization( string KeyName )
{
	return class'KFWeapDef_Stoner63A'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_LMG_Stoner63A"
	BuyPrice=2750
	AmmoPricePerMag=15
	EffectiveRange=70
}
