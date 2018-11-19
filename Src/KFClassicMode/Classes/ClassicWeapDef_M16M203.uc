class ClassicWeapDef_M16M203 extends KFWeapDef_M16M203;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_M16M203'.static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_M16M203"
    BuyPrice=2750
    AmmoPricePerMag=10
    EffectiveRange=75
}
