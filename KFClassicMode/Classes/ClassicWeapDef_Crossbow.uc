class ClassicWeapDef_Crossbow extends KFWeapDef_Crossbow;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Crossbow'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Bow_Crossbow"
    BuyPrice=800
    AmmoPricePerMag=20
    EffectiveRange=100
}
