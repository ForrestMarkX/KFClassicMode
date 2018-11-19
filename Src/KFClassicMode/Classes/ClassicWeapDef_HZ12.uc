class ClassicWeapDef_HZ12 extends KFWeapDef_HZ12;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "HSG-1 Shotgun";
    }
    
    return class'KFWeapDef_HZ12'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_HZ12"
    BuyPrice=1250
    AmmoPricePerMag=30
    EffectiveRange=30
}