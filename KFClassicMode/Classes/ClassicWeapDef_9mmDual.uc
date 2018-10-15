class ClassicWeapDef_9mmDual extends KFWeapDef_9mmDual;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_9mmDual'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_Dual9mm"
    BuyPrice=150
    AmmoPricePerMag=20
    EffectiveRange=35
}
