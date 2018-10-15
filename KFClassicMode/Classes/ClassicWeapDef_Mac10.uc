class ClassicWeapDef_Mac10 extends KFWeapDef_Mac10;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Mac10'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_SMG_Mac10"
    BuyPrice=500
    AmmoPricePerMag=10
    EffectiveRange=40
}