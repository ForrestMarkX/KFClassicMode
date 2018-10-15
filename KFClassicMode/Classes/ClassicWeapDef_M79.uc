class ClassicWeapDef_M79 extends KFWeapDef_M79;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_M79'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_GrenadeLauncher_M79"
    BuyPrice=1250
    AmmoPricePerMag=10
    EffectiveRange=75
}
