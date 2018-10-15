class ClassicWeapDef_RPG7 extends KFWeapDef_RPG7;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_RPG7'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_RocketLauncher_RPG7"
    BuyPrice=3000
    AmmoPricePerMag=30
    EffectiveRange=64
}
