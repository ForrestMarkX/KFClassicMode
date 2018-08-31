class ClassicWeapDef_AA12 extends KFWeapDef_AA12;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "AA12 Shotgun";
	case "ITEMCATEGORY":
		return class'KFWeapDef_AA12'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "An advanced fully automatic shotgun.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_AA12"
	BuyPrice=4000
	AmmoPricePerMag=40
	EffectiveRange=20
}
