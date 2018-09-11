class ClassicWeapDef_CenterfireMB464 extends KFWeapDef_CenterfireMB464;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_CenterfireMB464'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Rifle_CenterfireMB464"
    BuyPrice=1500
    AmmoPricePerMag=20
    EffectiveRange=95
}
