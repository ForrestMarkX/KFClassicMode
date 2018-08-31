class ClassicWeapDef_FlameThrower extends KFWeapDef_FlameThrower;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "FlameThrower";
	case "ITEMCATEGORY":
		return class'KFWeapDef_FlameThrower'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "A deadly experimental weapon designed by Horzine industries. It can fire streams of burning liquid which ignite on contact.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_Flame_Flamethrower"
	BuyPrice=750
	AmmoPricePerMag=30
	EffectiveRange=40
}
