class ClassicWeapDef_Zweihander extends KFWeapDef_Zweihander;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Zweihander'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Edged_Zweihander"
    BuyPrice=3000
    EffectiveRange=3
}
