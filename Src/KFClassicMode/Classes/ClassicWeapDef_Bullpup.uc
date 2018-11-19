class ClassicWeapDef_Bullpup extends KFWeapDef_Bullpup;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Bullpup'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_Bullpup"
    BuyPrice=400
    AmmoPricePerMag=10
    EffectiveRange=60
}
