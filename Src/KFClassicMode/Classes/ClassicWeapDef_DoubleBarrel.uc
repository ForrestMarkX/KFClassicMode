class ClassicWeapDef_DoubleBarrel extends KFWeapDef_DoubleBarrel;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Hunting Shotgun";
    }
    
    return class'KFWeapDef_DoubleBarrel'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_DoubleBarrel"
    BuyPrice=750
    AmmoPricePerMag=15
    EffectiveRange=12
}
