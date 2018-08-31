class ClassicWeapDef_SCAR extends KFWeapDef_SCAR;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "SCARMK17";
	case "ITEMCATEGORY":
		return class'KFWeapDef_SCAR'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "Advanced tactical assault rifle. Equipped with an aimpoint sight.";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_SCAR"
	BuyPrice=2500
	AmmoPricePerMag=15
	EffectiveRange=70
}
