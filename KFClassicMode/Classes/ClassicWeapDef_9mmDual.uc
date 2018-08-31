class ClassicWeapDef_9mmDual extends KFWeapDef_9mmDual;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "Dual 9mms";
	case "ITEMCATEGORY":
		return class'KFWeapDef_9mmDual'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "A pair of custom 9mm handguns.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_Dual9mm"
	BuyPrice=150
	AmmoPricePerMag=20
	EffectiveRange=35
}
