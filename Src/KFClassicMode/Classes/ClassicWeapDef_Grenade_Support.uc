class ClassicWeapDef_Grenade_Support extends KFWeapDef_Grenade_Support;

static function string GetItemLocalization(string KeyName)
{
    return class'KFWeapDef_Grenade_Support'.static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicProj_FragGrenade"
}
