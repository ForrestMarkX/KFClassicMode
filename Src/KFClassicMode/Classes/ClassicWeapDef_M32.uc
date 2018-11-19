class ClassicWeapDef_M32 extends KFWeapDef_M32;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_M32'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_GrenadeLauncher_M32"
    
    BuyPrice=4000
    AmmoPricePerMag=60
}
