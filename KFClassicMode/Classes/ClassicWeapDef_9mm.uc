class ClassicWeapDef_9mm extends KFWeapDef_9mm;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "9mm Pistol";
	case "ITEMCATEGORY":
		return class'KFWeapDef_9mm'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "A 9mm handgun.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_9mm"
	AmmoPricePerMag=10
	EffectiveRange=35
}
