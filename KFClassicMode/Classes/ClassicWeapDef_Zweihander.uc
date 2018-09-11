class ClassicWeapDef_Zweihander extends KFWeapDef_Zweihander;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Zweihander";
    case "ITEMCATEGORY":
        return class'KFWeapDef_Zweihander'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "A medieval zweihander sword.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Edged_Zweihander"
    BuyPrice=3000
    EffectiveRange=3
}
