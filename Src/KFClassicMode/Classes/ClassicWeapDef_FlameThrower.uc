class ClassicWeapDef_FlameThrower extends KFWeapDef_FlameThrower;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_FlameThrower'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Flame_Flamethrower"
    BuyPrice=750
    AmmoPricePerMag=30
    EffectiveRange=40
}
