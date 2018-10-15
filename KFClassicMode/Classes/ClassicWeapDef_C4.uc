class ClassicWeapDef_C4 extends KFWeapDef_C4;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_C4'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Thrown_C4"
    BuyPrice=1500
    AmmoPricePerMag=750
    EffectiveRange=15
}
