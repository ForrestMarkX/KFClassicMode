class ClassicWeapDef_SW500 extends KFWeapDef_SW500;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_SW500'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Revolver_SW500"
    BuyPrice=450
    AmmoPricePerMag=13
    EffectiveRange=65
}
