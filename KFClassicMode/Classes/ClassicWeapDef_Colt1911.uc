class ClassicWeapDef_Colt1911 extends KFWeapDef_Colt1911;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Colt1911'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_Colt1911"
    BuyPrice=350
    AmmoPricePerMag=16
    EffectiveRange=60
}
