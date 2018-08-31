class ClassicWeapDef_Mac10 extends KFWeapDef_Mac10;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "MAC-10";
	case "ITEMCATEGORY":
		return class'KFWeapDef_Mac10'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "A highly compact machine pistol. Can be fired in semi or full auto.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_SMG_Mac10"
	BuyPrice=500
	AmmoPricePerMag=10
	EffectiveRange=40
}