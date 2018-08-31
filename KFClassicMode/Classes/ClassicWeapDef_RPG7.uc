class ClassicWeapDef_RPG7 extends KFWeapDef_RPG7;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "RPG";
	case "ITEMCATEGORY":
		return class'KFWeapDef_RPG7'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "Rocket-Propelled Grenade. Designed to punch through armored vehicles.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_RocketLauncher_RPG7"
	BuyPrice=3000
	AmmoPricePerMag=30
	EffectiveRange=64
}
