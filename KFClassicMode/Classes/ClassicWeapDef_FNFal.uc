class ClassicWeapDef_FNFal extends KFWeapDef_FNFal;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "FNFAL ACOG";
    case "ITEMCATEGORY":
        return class'KFWeapDef_FNFal'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "Classic NATO battle rifle. Has a high rate of fire and decent accuracy, with good power.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_FNFal"
    BuyPrice=2750
    AmmoPricePerMag=20
}
