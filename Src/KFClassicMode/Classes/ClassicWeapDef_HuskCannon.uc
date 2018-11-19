class ClassicWeapDef_HuskCannon extends KFWeapDef_HuskCannon;

static function string GetItemLocalization( string KeyName )
{
     return class'KFWeapDef_HuskCannon'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_HuskCannon"
    BuyPrice=4000
    AmmoPricePerMag=50
    EffectiveRange=75
}
