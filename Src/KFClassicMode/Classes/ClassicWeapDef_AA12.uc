class ClassicWeapDef_AA12 extends KFWeapDef_AA12;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_AA12'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_AA12"
    BuyPrice=4000
    AmmoPricePerMag=40
    EffectiveRange=20
}
