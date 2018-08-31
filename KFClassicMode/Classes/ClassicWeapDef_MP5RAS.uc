class ClassicWeapDef_MP5RAS extends KFWeapDef_MP5RAS;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "MP5M";
	case "ITEMCATEGORY":
		return class'KFWeapDef_MP5RAS'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "MP5 sub machine gun. Modified to fire healing darts. Better damage and healing than MP7M with a larger mag.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_SMG_MP5RAS"
	BuyPrice=1375
	AmmoPricePerMag=10
	EffectiveRange=45
}