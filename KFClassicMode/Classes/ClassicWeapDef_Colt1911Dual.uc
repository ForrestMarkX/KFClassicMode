class ClassicWeapDef_Colt1911Dual extends KFWeapDef_Colt1911Dual;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Dual M1911";
    case "ITEMCATEGORY":
        return class'KFWeapDef_Colt1911Dual'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "Dual M1911 match grade pistols. Dual 45's is double the fun.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_DualColt1911"
    BuyPrice=700
    AmmoPricePerMag=32
    EffectiveRange=60
}
