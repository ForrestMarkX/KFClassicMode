class ClassicWeapDef_FlareGun extends KFWeapDef_FlareGun;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_FlareGun'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_Flare"
    BuyPrice=500
    AmmoPricePerMag=13
    EffectiveRange=65
}
