class ClassicWeapDef_MKB42 extends KFWeapDef_MKB42;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "MKb42";
    }
    
    return class'KFWeapDef_MKB42'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_MKB42"
    BuyPrice=1100
    AmmoPricePerMag=30
}
