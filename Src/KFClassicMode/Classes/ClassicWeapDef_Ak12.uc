class ClassicWeapDef_AK12 extends KFWeapDef_AK12;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_AK12'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_AK12"
    BuyPrice=1000
    AmmoPricePerMag=10
    EffectiveRange=50
}
