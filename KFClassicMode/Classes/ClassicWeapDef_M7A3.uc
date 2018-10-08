class ClassicWeapDef_M7A3 extends KFWeapDef_MedicRifleGrenadeLauncher;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "M7A3 Medic Gun";
    case "ITEMCATEGORY":
        return class'KFWeapDef_MedicRifleGrenadeLauncher'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "An advanced Horzine prototype assault rifle. Modified to fire healing darts.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_M7A3"
    BuyPrice=2050
    AmmoPricePerMag=15
}
