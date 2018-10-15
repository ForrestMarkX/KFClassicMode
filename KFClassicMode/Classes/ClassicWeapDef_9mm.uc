class ClassicWeapDef_9mm extends KFWeapDef_9mm;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_9mm'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_9mm"
    AmmoPricePerMag=10
    EffectiveRange=35
}
