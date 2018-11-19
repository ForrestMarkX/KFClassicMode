class ClassicWeapDef_Thompson extends KFWeapDef_Thompson;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_Thompson'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_AssaultRifle_Thompson"
    
    BuyPrice=900
    AmmoPricePerMag=30
}
