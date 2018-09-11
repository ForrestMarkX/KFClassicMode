class ClassicWeapDef_HuskCannon extends KFWeapDef_HuskCannon;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Husk Gun";
    case "ITEMCATEGORY":
        return class'KFWeapDef_HuskCannon'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "A fireball cannon ripped from the arm of a dead Husk. Does more damage when charged up.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_HuskCannon"
    BuyPrice=4000
    AmmoPricePerMag=50
    EffectiveRange=75
}
