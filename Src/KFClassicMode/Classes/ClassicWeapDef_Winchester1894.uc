class ClassicWeapDef_Winchester1894 extends KFWeapDef_Winchester1894;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Winchester1894'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Rifle_Winchester1894"
    BuyPrice=200
    AmmoPricePerMag=20
    EffectiveRange=90
}
