class ClassicWeapDef_HK_UMP extends KFWeapDef_HK_UMP;

static function string GetItemLocalization( string KeyName )
{
	return class'KFWeapDef_HK_UMP'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_SMG_HK_UMP"
    BuyPrice=1100
    AmmoPricePerMag=10
    EffectiveRange=55
}