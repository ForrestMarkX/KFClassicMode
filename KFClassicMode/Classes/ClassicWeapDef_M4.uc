class ClassicWeapDef_M4 extends KFWeapDef_M4;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_M4'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_M4"
    BuyPrice=2000
    AmmoPricePerMag=20
    EffectiveRange=15
}
