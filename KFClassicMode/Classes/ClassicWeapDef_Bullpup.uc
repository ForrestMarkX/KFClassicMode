class ClassicWeapDef_Bullpup extends KFWeapDef_Bullpup;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "Bullpup";
	case "ITEMCATEGORY":
		return class'KFWeapDef_Bullpup'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "Standard issue military rifle. Equipped with an integrated 2X scope.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_Bullpup"
	BuyPrice=400
	AmmoPricePerMag=10
	EffectiveRange=60
}
