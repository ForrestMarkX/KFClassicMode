class ClassicWeapDef_Katana extends KFWeapDef_Katana;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "Katana";
	case "ITEMCATEGORY":
		return class'KFWeapDef_Katana'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "An incredibly sharp katana sword.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_Edged_Katana"
	BuyPrice=2000
	EffectiveRange=2
}
