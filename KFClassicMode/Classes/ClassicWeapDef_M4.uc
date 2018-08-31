class ClassicWeapDef_M4 extends KFWeapDef_M4;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "Combat Shotgun";
	case "ITEMCATEGORY":
		return class'KFWeapDef_M4'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "A military tactical shotgun with semi automatic fire capability. Holds up to 6 shells.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_M4"
	BuyPrice=2000
	AmmoPricePerMag=20
	EffectiveRange=15
}
