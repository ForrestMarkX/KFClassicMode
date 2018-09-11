class ClassicWeapDef_Deagle extends KFWeapDef_Deagle;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Handcannon";
    case "ITEMCATEGORY":
        return class'KFWeapDef_Deagle'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "50 Cal AE handgun. A powerful personal choice for personal defense.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_Deagle"
    BuyPrice=500
    AmmoPricePerMag=15
    EffectiveRange=60
}
