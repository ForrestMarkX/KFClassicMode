class ClassicWeapDef_DoubleBarrel extends KFWeapDef_DoubleBarrel;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Hunting Shotgun";
    case "ITEMCATEGORY":
        return class'KFWeapDef_DoubleBarrel'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "A double barreled shotgun used by big game hunters.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_DoubleBarrel"
    BuyPrice=750
    AmmoPricePerMag=15
    EffectiveRange=12
}
