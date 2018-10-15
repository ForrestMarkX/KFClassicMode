class ClassicWeapDef_SW500Dual extends KFWeapDef_SW500Dual;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_SW500Dual'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Revolver_DualSW500"
    BuyPrice=900
    AmmoPricePerMag=26
    EffectiveRange=65
}
