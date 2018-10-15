class ClassicWeapDef_Katana extends KFWeapDef_Katana;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Katana'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Edged_Katana"
    BuyPrice=2000
    EffectiveRange=2
}
