class ClassicWeapDef_SCAR extends KFWeapDef_SCAR;

static function string GetItemLocalization( string KeyName )
{
     return class'KFWeapDef_SCAR'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_SCAR"
    BuyPrice=2500
    AmmoPricePerMag=15
    EffectiveRange=70
}
