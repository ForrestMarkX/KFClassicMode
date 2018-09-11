class ClassicWeapDef_Nailgun extends KFWeapDef_Nailgun;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Vlad the Impaler";
    case "ITEMCATEGORY":
        return class'KFWeapDef_Nailgun'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "The Black and Wrecker Vlad 9000 nail gun. Designed for putting barns together. Or nailing Zeds to them.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_Nailgun"
    BuyPrice=1500
    AmmoPricePerMag=30
    EffectiveRange=25
}
