class ClassicWeapDef_SW500Dual extends KFWeapDef_SW500Dual;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Dual 44s";
    case "ITEMCATEGORY":
        return class'KFWeapDef_SW500Dual'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "A pair of 44 Magnum Pistols. Make my day!";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Revolver_DualSW500"
    BuyPrice=900
    AmmoPricePerMag=26
    EffectiveRange=65
}
