class ClassicWeapDef_MB500 extends KFWeapDef_MB500;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Shotgun";
    }
    
    return class'KFWeapDef_MB500'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_MB500"
    BuyPrice=500
    AmmoPricePerMag=20
    EffectiveRange=15
}
