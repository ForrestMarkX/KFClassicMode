class ClassicWeapDef_Crovel extends KFWeapDef_Crovel;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Crovel'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Blunt_Crovel"
    BuyPrice=500
    EffectiveRange=3
}