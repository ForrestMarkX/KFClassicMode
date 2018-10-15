class ClassicWeapDef_Colt1911Dual extends KFWeapDef_Colt1911Dual;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Colt1911Dual'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_DualColt1911"
    BuyPrice=700
    AmmoPricePerMag=32
    EffectiveRange=60
}
