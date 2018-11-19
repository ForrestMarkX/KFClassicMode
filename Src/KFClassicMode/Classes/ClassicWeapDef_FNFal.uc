class ClassicWeapDef_FNFal extends KFWeapDef_FNFal;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "FNFAL ACOG";
    }
    
    return class'KFWeapDef_FNFal'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_FNFal"
    BuyPrice=2750
    AmmoPricePerMag=20
}
