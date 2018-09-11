class ClassicWeapDef_C4 extends KFWeapDef_C4;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Pipe Bomb";
    case "ITEMCATEGORY":
        return class'KFWeapDef_C4'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "An improvised proximity explosive. Blows up when enemies get close.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Thrown_C4"
    BuyPrice=1500
    AmmoPricePerMag=750
    EffectiveRange=15
}
