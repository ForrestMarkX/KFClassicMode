class ClassicWeapDef_SW500 extends KFWeapDef_SW500;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "44 Magnum";
	case "ITEMCATEGORY":
		return class'KFWeapDef_SW500'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "44 Magnum pistol, the most 'powerful' handgun in the world. Do you feel lucky?";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_Revolver_SW500"
	BuyPrice=450
	AmmoPricePerMag=13
	EffectiveRange=65
}
