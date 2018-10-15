class ClassicWeapDef_FlareGunDual extends KFWeapDef_FlareGunDual;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_FlareGunDual'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_DualFlare"
    BuyPrice=1000
    AmmoPricePerMag=26
    EffectiveRange=65
}
