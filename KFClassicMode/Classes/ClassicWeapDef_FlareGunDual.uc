class ClassicWeapDef_FlareGunDual extends KFWeapDef_FlareGunDual;

static function string GetItemLocalization( string KeyName )
{
	switch( Caps(KeyName) )
	{
	case "ITEMNAME":
		return "Dual Flare Revolvers";
	case "ITEMCATEGORY":
		return class'KFWeapDef_FlareGunDual'.Static.GetItemLocalization(KeyName);
	case "ITEMDESCRIPTION":
		return "A pair of Flare Revolvers. Two classic wild west revolvers modified to shoot fireballs!";
	}
}

DefaultProperties
{
	WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_DualFlare"
	BuyPrice=1000
	AmmoPricePerMag=26
	EffectiveRange=65
}
